import { execFileSync } from "node:child_process";
import { readdirSync } from "node:fs";
import { homedir } from "node:os";
import { basename, join } from "node:path";

export interface Repository {
    key: string;
    name: string;
    path: string;
    url?: string;
}

export interface AuthorIdentity {
    name: string;
    email: string;
}

export interface Commit {
    type: "commit";
    repository: Repository;
    hash: string;
    shortHash: string;
    subject: string;
    authoredAt: string;
    url?: string;
}

export interface PullRequest {
    type: "pull-request";
    repository: Repository;
    number: number;
    title: string;
    state: string;
    url: string;
}

export interface Issue {
    type: "issue";
    repository: Repository;
    number: number;
    title: string;
    state: string;
    url: string;
}

export type ActivityItem = Commit | PullRequest | Issue;

export interface RepositoryActivity {
    repository: Repository;
    commits: Commit[];
    pullRequests: PullRequest[];
    issues: Issue[];
}

export interface ActivityError {
    source: "git" | "github";
    repository?: string;
    message: string;
}

export interface ActivityReport {
    date: string;
    author?: AuthorIdentity;
    repositories: RepositoryActivity[];
    errors: ActivityError[];
}

export type CommandRunner = (command: string, args: readonly string[], cwd?: string) => string;

export interface LocalCommitOptions {
    repository: Repository;
    author: AuthorIdentity;
    date: string;
    run?: CommandRunner;
}

export interface GitHubOptions {
    user: string;
    date: string;
    run?: CommandRunner;
}

export interface CollectorOptions {
    date: string;
    root: string;
    githubUser: string;
    run?: CommandRunner;
}

export interface CollectorArguments {
    date: string;
    root: string;
    githubUser: string;
}

function runCommand(command: string, args: readonly string[], cwd?: string): string {
    return execFileSync(command, [...args], {
        cwd,
        encoding: "utf8",
        stdio: ["ignore", "pipe", "pipe"]
    });
}

function isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === "object" && value !== null && !Array.isArray(value);
}

function readString(record: Record<string, unknown>, key: string): string {
    const value = record[key];
    if (typeof value !== "string" || !value.trim()) {
        throw new Error(`Missing ${key}`);
    }
    return value.trim();
}

function readNumber(record: Record<string, unknown>, key: string): number {
    const value = record[key];
    if (typeof value !== "number" || !Number.isInteger(value)) {
        throw new Error(`Missing ${key}`);
    }
    return value;
}

export function normalizeGitHubRemote(remote: string): string | undefined {
    const value = remote.trim().replace(/\.git$/, "");
    const match = value.match(/github\.com[/:]([^/]+)\/([^/]+)$/i);

    return match ? `https://github.com/${match[1]}/${match[2]}` : undefined;
}

export function parseGitLog(output: string, repository: Repository): Commit[] {
    return output
        .split("\n")
        .filter(Boolean)
        .map(line => {
            const [hash, shortHash, subject, authoredAt] = line.split("\t");
            if (!hash || !shortHash || !subject || !authoredAt) {
                throw new Error(`Invalid Git log record: ${line}`);
            }

            return {
                type: "commit",
                repository,
                hash,
                shortHash,
                subject,
                authoredAt,
                ...(repository.url ? { url: `${repository.url}/commit/${hash}` } : {})
            };
        });
}

export function groupActivity(items: ActivityItem[]): RepositoryActivity[] {
    const groups = new Map<string, RepositoryActivity>();

    for (const item of items) {
        const existing = groups.get(item.repository.key) ?? {
            repository: item.repository,
            commits: [],
            pullRequests: [],
            issues: []
        };

        if (item.type === "commit") existing.commits.push(item);
        if (item.type === "pull-request") existing.pullRequests.push(item);
        if (item.type === "issue") existing.issues.push(item);
        groups.set(item.repository.key, existing);
    }

    return [...groups.values()].sort((left, right) => left.repository.key.localeCompare(right.repository.key));
}

function isGitRepository(directory: string): boolean {
    try {
        execFileSync("git", ["rev-parse", "--show-toplevel"], {
            cwd: directory,
            stdio: "ignore"
        });
        return true;
    } catch {
        return false;
    }
}

export function findGitRepositories(root: string): string[] {
    const repositories: string[] = [];

    function visit(directory: string): void {
        let entries;
        try {
            entries = readdirSync(directory, { withFileTypes: true });
        } catch {
            return;
        }

        if (entries.some(entry => entry.name === ".git") && isGitRepository(directory)) {
            repositories.push(directory);
        }

        for (const entry of entries) {
            if (!entry.isDirectory() || entry.name === ".git") continue;
            visit(join(directory, entry.name));
        }
    }

    visit(root);
    return repositories.sort();
}

export function getAuthorIdentity(run: CommandRunner = runCommand): AuthorIdentity {
    const name = run("git", ["config", "--get", "user.name"]).trim();
    const email = run("git", ["config", "--get", "user.email"]).trim();

    if (!name || !email) throw new Error("Git user.name and user.email are required");
    return { name, email };
}

function nextDate(date: string): string {
    const [year, month, day] = date.split("-").map(Number);
    const next = new Date(Date.UTC(year, month - 1, day + 1));
    return next.toISOString().slice(0, 10);
}

export function getRepositoryAuthorIdentity(
    path: string,
    fallback: AuthorIdentity,
    run: CommandRunner = runCommand
): AuthorIdentity {
    try {
        const name = run("git", ["config", "--local", "--get", "user.name"], path).trim();
        const email = run("git", ["config", "--local", "--get", "user.email"], path).trim();
        return name && email ? { name, email } : fallback;
    } catch {
        return fallback;
    }
}

export function collectLocalCommits({ repository, author, date, run = runCommand }: LocalCommitOptions): Commit[] {
    const output = run(
        "git",
        [
            "log",
            "--all",
            `--author=${author.email}`,
            `--since=${date} 00:00:00`,
            `--until=${nextDate(date)} 00:00:00`,
            "--format=%H%x09%h%x09%s%x09%aI"
        ],
        repository.path
    );

    return parseGitLog(output, repository);
}

function repositoryFromPath(path: string, run: CommandRunner): Repository {
    let remote = "";
    try {
        remote = run("git", ["config", "--get", "remote.origin.url"], path).trim();
    } catch {
        remote = "";
    }
    const url = normalizeGitHubRemote(remote);
    if (url) {
        const key = url.replace("https://github.com/", "");
        return { key, name: basename(key), path, url };
    }

    return { key: path, name: basename(path), path };
}

export function parseGitHubItems(json: string, type: "pullRequest"): PullRequest[];
export function parseGitHubItems(json: string, type: "issue"): Issue[];
export function parseGitHubItems(json: string, type: "pullRequest" | "issue"): ActivityItem[] {
    let parsed: unknown;
    try {
        parsed = JSON.parse(json) as unknown;
    } catch (error) {
        throw new Error(`Invalid GitHub JSON: ${error instanceof Error ? error.message : String(error)}`);
    }

    if (!Array.isArray(parsed)) throw new Error("GitHub response must be an array");

    return parsed.map(value => {
        if (!isRecord(value) || !isRecord(value.repository)) {
            throw new Error("Missing repository nameWithOwner");
        }

        const key = readString(value.repository, "nameWithOwner");
        const [owner, name] = key.split("/");
        if (!owner || !name) throw new Error("Invalid repository nameWithOwner");

        const repository: Repository = {
            key,
            name,
            path: "",
            url: `https://github.com/${key}`
        };
        const item = {
            repository,
            number: readNumber(value, "number"),
            title: readString(value, "title"),
            state: readString(value, "state").toLowerCase(),
            url: readString(value, "url")
        };

        return type === "pullRequest" ? { type: "pull-request" as const, ...item } : { type: "issue" as const, ...item };
    });
}

export function collectGitHubActivity({ user, date, run = runCommand }: GitHubOptions): ActivityItem[] {
    const common = [
        `--author=${user}`,
        `--created=${date}`,
        "--limit",
        "100",
        "--json",
        "repository,title,state,number,url"
    ];
    const pullRequests = parseGitHubItems(run("gh", ["search", "prs", ...common]), "pullRequest");
    const issues = parseGitHubItems(run("gh", ["search", "issues", ...common]), "issue");

    return [...pullRequests, ...issues];
}

function localDate(now: Date): string {
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, "0");
    const day = String(now.getDate()).padStart(2, "0");
    return `${year}-${month}-${day}`;
}

export function parseArguments(args: readonly string[], now = new Date()): CollectorArguments {
    const values: CollectorArguments = {
        date: localDate(now),
        root: join(homedir(), "repos"),
        githubUser: "nikbrunner"
    };

    for (let index = 0; index < args.length; index += 1) {
        const argument = args[index];
        const value = args[index + 1];
        if (!value) throw new Error(`Missing value for ${argument}`);

        if (argument === "--date") values.date = value;
        else if (argument === "--root") values.root = value;
        else if (argument === "--github-user") values.githubUser = value;
        else throw new Error(`Unknown option: ${argument}`);
        index += 1;
    }

    if (!/^\d{4}-\d{2}-\d{2}$/.test(values.date)) {
        throw new Error(`Invalid date: ${values.date}`);
    }
    return values;
}

export function collectActivity({ date, root, githubUser, run = runCommand }: CollectorOptions): ActivityReport {
    const items: ActivityItem[] = [];
    const errors: ActivityError[] = [];
    let author: AuthorIdentity | undefined;

    try {
        author = getAuthorIdentity(run);
    } catch (error) {
        errors.push({ source: "git", message: errorMessage(error) });
    }

    for (const path of findGitRepositories(root)) {
        try {
            const repository = repositoryFromPath(path, run);
            if (author) {
                const repositoryAuthor = getRepositoryAuthorIdentity(path, author, run);
                items.push(...collectLocalCommits({ repository, author: repositoryAuthor, date, run }));
            }
        } catch (error) {
            errors.push({ source: "git", repository: path, message: errorMessage(error) });
        }
    }

    try {
        items.push(...collectGitHubActivity({ user: githubUser, date, run }));
    } catch (error) {
        errors.push({ source: "github", message: errorMessage(error) });
    }

    return { date, ...(author ? { author } : {}), repositories: groupActivity(items), errors };
}

function errorMessage(error: unknown): string {
    return error instanceof Error ? error.message : String(error);
}

export function main(args: readonly string[] = process.argv.slice(2)): void {
    const options = parseArguments(args);
    console.log(JSON.stringify(collectActivity(options), null, 2));
}

if (process.argv[1]?.endsWith("collect-activity.ts")) main();
