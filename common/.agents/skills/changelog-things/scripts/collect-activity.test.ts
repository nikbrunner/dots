import { deepStrictEqual, strictEqual, throws } from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";
import {
    collectActivity,
    collectGitHubActivity,
    collectLocalCommits,
    findGitRepositories,
    getAuthorIdentity,
    getRepositoryAuthorIdentity,
    groupActivity,
    normalizeGitHubRemote,
    parseArguments,
    parseGitHubItems,
    parseGitLog,
    type ActivityItem,
    type Repository
} from "./collect-activity.ts";

const notesRepository: Repository = {
    key: "nikbrunner/notes",
    name: "notes",
    path: "/repos/nikbrunner/notes",
    url: "https://github.com/nikbrunner/notes"
};

const dotsRepository: Repository = {
    key: "nikbrunner/dots",
    name: "dots",
    path: "/repos/nikbrunner/dots",
    url: "https://github.com/nikbrunner/dots"
};

test("normalizes GitHub SSH and HTTPS remotes", () => {
    strictEqual(normalizeGitHubRemote("git@github.com:nikbrunner/notes.git"), "https://github.com/nikbrunner/notes");
    strictEqual(normalizeGitHubRemote("https://github.com/nikbrunner/dots.git"), "https://github.com/nikbrunner/dots");
    strictEqual(normalizeGitHubRemote("https://gitlab.com/nikbrunner/notes.git"), undefined);
});

test("parses tab-separated Git log records", () => {
    const commits = parseGitLog("abc123456789\tabc1234\tfeat: add changelog\t2026-08-29T12:00:00+02:00\n", notesRepository);

    deepStrictEqual(commits, [
        {
            type: "commit",
            repository: notesRepository,
            hash: "abc123456789",
            shortHash: "abc1234",
            subject: "feat: add changelog",
            authoredAt: "2026-08-29T12:00:00+02:00",
            url: "https://github.com/nikbrunner/notes/commit/abc123456789"
        }
    ]);
});

test("discovers Git repositories recursively", () => {
    const root = mkdtempSync(join(tmpdir(), "changelog-repos-"));
    try {
        const notes = join(root, "group-a", "notes");
        const dots = join(root, "group-b", "dots");
        mkdirSync(notes, { recursive: true });
        mkdirSync(dots, { recursive: true });
        execFileSync("git", ["init", "--quiet", notes]);
        execFileSync("git", ["init", "--quiet", dots]);
        const cache = join(root, "cache", "sdists-v9");
        mkdirSync(cache, { recursive: true });
        writeFileSync(join(cache, ".git"), "");

        deepStrictEqual(findGitRepositories(root), [notes, dots].sort());
    } finally {
        rmSync(root, { recursive: true, force: true });
    }
});

test("reads the configured Git author identity", () => {
    const calls: string[][] = [];
    const run = (command: string, args: readonly string[]) => {
        calls.push([command, ...args]);
        return args.includes("user.email") ? "nik@example.com\n" : "Nik Brunner\n";
    };

    deepStrictEqual(getAuthorIdentity(run), {
        name: "Nik Brunner",
        email: "nik@example.com"
    });
    deepStrictEqual(calls, [
        ["git", "config", "--get", "user.name"],
        ["git", "config", "--get", "user.email"]
    ]);
});

test("uses a repository author identity and falls back to the global identity", () => {
    const fallback = { name: "Nik Brunner", email: "nik@example.com" };
    const run = (command: string, args: readonly string[], cwd?: string) => {
        if (args.includes("--local") && cwd === notesRepository.path) {
            return args.includes("user.name") ? "Repo Nik\n" : "repo@example.com\n";
        }
        return args.includes("user.name") ? `${fallback.name}\n` : `${fallback.email}\n`;
    };

    deepStrictEqual(getRepositoryAuthorIdentity(notesRepository.path, fallback, run), {
        name: "Repo Nik",
        email: "repo@example.com"
    });
    deepStrictEqual(
        getRepositoryAuthorIdentity("/repos/without-local-config", fallback, () => {
            throw new Error("missing local identity");
        }),
        fallback
    );
});

test("collects commits for the local calendar day and author", () => {
    const calls: Array<{ command: string; args: readonly string[]; cwd?: string }> = [];
    const run = (command: string, args: readonly string[], cwd?: string) => {
        calls.push({ command, args, cwd });
        return "abc123456789\tabc1234\tfeat: add changelog\t2026-08-29T12:00:00+02:00\n";
    };

    const commits = collectLocalCommits({
        repository: notesRepository,
        author: { name: "Nik Brunner", email: "nik@example.com" },
        date: "2026-08-29",
        run
    });

    strictEqual(commits.length, 1);
    strictEqual(calls.length, 1);
    deepStrictEqual(calls[0], {
        command: "git",
        args: [
            "log",
            "--all",
            "--author=nik@example.com",
            "--since=2026-08-29 00:00:00",
            "--until=2026-08-30 00:00:00",
            "--format=%H%x09%h%x09%s%x09%aI"
        ],
        cwd: notesRepository.path
    });
});

test("parses GitHub pull requests and issues into activity items", () => {
    const json = JSON.stringify([
        {
            repository: { nameWithOwner: "nikbrunner/notes" },
            title: "Add changelog skill",
            state: "MERGED",
            number: 42,
            url: "https://github.com/nikbrunner/notes/pull/42"
        }
    ]);

    deepStrictEqual(parseGitHubItems(json, "pullRequest"), [
        {
            type: "pull-request",
            repository: {
                key: "nikbrunner/notes",
                name: "notes",
                path: "",
                url: "https://github.com/nikbrunner/notes"
            },
            number: 42,
            title: "Add changelog skill",
            state: "merged",
            url: "https://github.com/nikbrunner/notes/pull/42"
        }
    ]);
});

test("rejects malformed GitHub activity records", () => {
    throws(
        () => parseGitHubItems(JSON.stringify([{ title: "missing repository" }]), "issue"),
        /Missing repository nameWithOwner/
    );
});

test("parses collector arguments", () => {
    deepStrictEqual(parseArguments(["--date", "2026-08-29", "--root", "/tmp/repos", "--github-user", "nikbrunner"]), {
        date: "2026-08-29",
        root: "/tmp/repos",
        githubUser: "nikbrunner"
    });
});

test("requests enough GitHub results for both activity searches", () => {
    const calls: Array<{ command: string; args: readonly string[] }> = [];
    const run = (command: string, args: readonly string[]) => {
        calls.push({ command, args });
        return "[]";
    };

    collectGitHubActivity({ user: "nikbrunner", date: "2026-08-29", run });

    strictEqual(calls.length, 2);
    for (const call of calls) {
        strictEqual(call.command, "gh");
        strictEqual(call.args.includes("--limit"), true);
        strictEqual(call.args[call.args.indexOf("--limit") + 1], "100");
    }
});

test("keeps local commits when a repository has no origin remote", () => {
    const root = mkdtempSync(join(tmpdir(), "changelog-local-"));
    try {
        const notes = join(root, "notes");
        mkdirSync(notes, { recursive: true });
        execFileSync("git", ["init", "--quiet", notes]);
        const run = (command: string, args: readonly string[]) => {
            if (command === "gh") throw new Error("not authenticated");
            if (args.includes("user.name")) return "Nik Brunner\n";
            if (args.includes("user.email")) return "nik@example.com\n";
            if (args.includes("remote.origin.url")) throw new Error("no origin");
            if (args[0] === "log") {
                return "abc123456789\tabc1234\tfeat: local work\t2026-08-29T12:00:00+02:00\n";
            }
            throw new Error("Unexpected command");
        };

        const report = collectActivity({
            date: "2026-08-29",
            root,
            githubUser: "nikbrunner",
            run
        });

        strictEqual(report.repositories[0]?.repository.name, "notes");
        strictEqual(report.repositories[0]?.commits[0]?.subject, "feat: local work");
        deepStrictEqual(report.errors, [{ source: "github", message: "not authenticated" }]);
    } finally {
        rmSync(root, { recursive: true, force: true });
    }
});

test("keeps local commits when GitHub collection fails", () => {
    const root = mkdtempSync(join(tmpdir(), "changelog-activity-"));
    try {
        const notes = join(root, "notes");
        mkdirSync(notes, { recursive: true });
        execFileSync("git", ["init", "--quiet", notes]);
        const run = (command: string, args: readonly string[], cwd?: string) => {
            if (command === "gh") throw new Error("not authenticated");
            if (args.includes("user.name")) return "Nik Brunner\n";
            if (args.includes("user.email")) return "nik@example.com\n";
            if (args.includes("remote.origin.url")) {
                return "git@github.com:nikbrunner/notes.git\n";
            }
            if (args[0] === "log") {
                return "abc123456789\tabc1234\tfeat: add changelog\t2026-08-29T12:00:00+02:00\n";
            }
            throw new Error(`Unexpected command in ${cwd ?? "global"}`);
        };

        const report = collectActivity({
            date: "2026-08-29",
            root,
            githubUser: "nikbrunner",
            run
        });

        strictEqual(report.repositories[0]?.commits.length, 1);
        deepStrictEqual(report.errors, [{ source: "github", message: "not authenticated" }]);
    } finally {
        rmSync(root, { recursive: true, force: true });
    }
});

test("groups all activity types by repository", () => {
    const items: ActivityItem[] = [
        {
            type: "commit",
            repository: notesRepository,
            hash: "abc123456789",
            shortHash: "abc1234",
            subject: "feat: add changelog",
            authoredAt: "2026-08-29T12:00:00+02:00",
            url: "https://github.com/nikbrunner/notes/commit/abc123456789"
        },
        {
            type: "pull-request",
            repository: notesRepository,
            number: 42,
            title: "Add changelog skill",
            state: "merged",
            url: "https://github.com/nikbrunner/notes/pull/42"
        },
        {
            type: "issue",
            repository: notesRepository,
            number: 43,
            title: "Document changelog workflow",
            state: "open",
            url: "https://github.com/nikbrunner/notes/issues/43"
        },
        {
            type: "commit",
            repository: dotsRepository,
            hash: "def123456789",
            shortHash: "def1234",
            subject: "chore: update tools",
            authoredAt: "2026-08-29T13:00:00+02:00",
            url: "https://github.com/nikbrunner/dots/commit/def123456789"
        }
    ];

    deepStrictEqual(groupActivity(items), [
        {
            repository: dotsRepository,
            commits: [items[3]],
            pullRequests: [],
            issues: []
        },
        {
            repository: notesRepository,
            commits: [items[0]],
            pullRequests: [items[1]],
            issues: [items[2]]
        }
    ]);
});
