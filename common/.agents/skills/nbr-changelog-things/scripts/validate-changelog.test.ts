import { deepStrictEqual, strictEqual } from "node:assert/strict";
import test from "node:test";
import { parseArguments, validateChangelog } from "./validate-changelog.ts";
import type { ActivityReport } from "./collect-activity.ts";

const report: ActivityReport = {
    date: "2026-08-29",
    author: { name: "Nik Brunner", email: "nik@example.com" },
    repositories: [
        {
            repository: {
                key: "nikbrunner/notes",
                name: "notes",
                path: "/repos/nikbrunner/notes",
                url: "https://github.com/nikbrunner/notes"
            },
            commits: [
                {
                    type: "commit",
                    repository: {
                        key: "nikbrunner/notes",
                        name: "notes",
                        path: "/repos/nikbrunner/notes",
                        url: "https://github.com/nikbrunner/notes"
                    },
                    hash: "abc123456789",
                    shortHash: "abc1234",
                    subject: "feat: add changelog",
                    authoredAt: "2026-08-29T12:00:00+02:00",
                    url: "https://github.com/nikbrunner/notes/commit/abc123456789"
                }
            ],
            pullRequests: [
                {
                    type: "pull-request",
                    repository: {
                        key: "nikbrunner/notes",
                        name: "notes",
                        path: "/repos/nikbrunner/notes",
                        url: "https://github.com/nikbrunner/notes"
                    },
                    number: 42,
                    title: "Add changelog skill",
                    state: "merged",
                    url: "https://github.com/nikbrunner/notes/pull/42"
                }
            ],
            issues: []
        }
    ],
    errors: []
};

test("parses validator file arguments", () => {
    deepStrictEqual(parseArguments(["/tmp/note.md", "/tmp/activity.json"]), {
        notePath: "/tmp/note.md",
        reportPath: "/tmp/activity.json"
    });
});

test("accepts a complete repository-grouped changelog", () => {
    const note = `# 2026.08.29 - Sat

## Changelog

### nikbrunner/notes

- feat: add changelog [\`abc1234\`](https://github.com/nikbrunner/notes/commit/abc123456789)
- [Add changelog skill](https://github.com/nikbrunner/notes/pull/42)
`;

    deepStrictEqual(validateChangelog(note, report), {
        valid: true,
        errors: []
    });
});

test("rejects activity placed under the wrong repository", () => {
    const reportActivity = report.repositories[0];
    if (!reportActivity) throw new Error("Test report is missing notes activity");
    const notesActivity = { ...reportActivity, pullRequests: [] };
    const dotsActivity = {
        ...notesActivity,
        repository: {
            ...notesActivity.repository,
            key: "nikbrunner/dots",
            name: "dots",
            path: "/repos/nikbrunner/dots",
            url: "https://github.com/nikbrunner/dots"
        },
        commits: notesActivity.commits.map(commit => ({
            ...commit,
            repository: {
                ...commit.repository,
                key: "nikbrunner/dots",
                name: "dots",
                path: "/repos/nikbrunner/dots",
                url: "https://github.com/nikbrunner/dots"
            },
            subject: "feat: update dots",
            hash: "def123456789",
            shortHash: "def1234",
            url: "https://github.com/nikbrunner/dots/commit/def123456789"
        })),
        pullRequests: []
    };
    const swappedNote = `## Changelog

### nikbrunner/notes

- feat: update dots [\`def1234\`](https://github.com/nikbrunner/dots/commit/def123456789)

### nikbrunner/dots

- feat: add changelog [\`abc1234\`](https://github.com/nikbrunner/notes/commit/abc123456789)
`;
    const result = validateChangelog(swappedNote, { ...report, repositories: [notesActivity, dotsActivity] });

    strictEqual(result.valid, false);
    deepStrictEqual(result.errors, [
        "Missing commit abc1234: feat: add changelog",
        "Missing commit def1234: feat: update dots"
    ]);
});

test("rejects leftover legacy activity sections", () => {
    const emptyReport: ActivityReport = {
        date: report.date,
        repositories: [],
        errors: []
    };
    const result = validateChangelog("## Changelog\n\n## Dev Activity\n", emptyReport);

    strictEqual(result.valid, false);
    deepStrictEqual(result.errors, ["Legacy activity section remains: ## Dev Activity"]);
});

test("rejects duplicate changelog sections", () => {
    const note = "## Changelog\n\n## Changelog\n";
    const result = validateChangelog(note, report);

    strictEqual(result.valid, false);
    strictEqual(result.errors[0], "Expected exactly one ## Changelog section");
});

test("reports missing repository activity", () => {
    const result = validateChangelog("## Changelog\n", report);

    strictEqual(result.valid, false);
    deepStrictEqual(result.errors, ["Missing repository heading: nikbrunner/notes"]);
});
