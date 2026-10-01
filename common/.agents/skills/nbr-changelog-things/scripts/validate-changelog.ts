import { readFileSync } from "node:fs";
import type { ActivityReport, RepositoryActivity } from "./collect-activity.ts";

export interface ValidationResult {
    valid: boolean;
    errors: string[];
}

export interface ValidationArguments {
    notePath: string;
    reportPath: string;
}

function changelogHeadings(note: string): string[] {
    return note.match(/^## Changelog$/gm) ?? [];
}

function changelogBody(note: string): string {
    const heading = "## Changelog";
    const start = note.indexOf(heading) + heading.length;
    const nextHeading = note.indexOf("\n## ", start);
    return note.slice(start, nextHeading === -1 ? note.length : nextHeading);
}

function repositoryBody(section: string, key: string): string | undefined {
    const lines = section.split(/\r?\n/);
    const heading = `### ${key}`;
    const start = lines.findIndex(line => line.trim() === heading);
    if (start === -1) return undefined;

    const end = lines.findIndex((line, index) => index > start && line.startsWith("### "));
    return lines.slice(start + 1, end === -1 ? lines.length : end).join("\n");
}

function isOmittedCommit(subject: string): boolean {
    const normalized = subject.trim().toLowerCase();
    return normalized === "update routine dotfiles" ||
        normalized.startsWith("backup:") ||
        normalized.startsWith("vault backup:") ||
        normalized === "chore: backup" ||
        normalized === "wip" ||
        normalized === "--wip--" ||
        normalized.startsWith("wip on ") ||
        normalized.startsWith("index on ") ||
        /^(chore: )?ignore (local )?plan\.md\b/.test(normalized);
}

function hasVisibleActivity(activity: RepositoryActivity): boolean {
    return activity.commits.some(commit => !isOmittedCommit(commit.subject)) ||
        activity.pullRequests.length > 0 ||
        activity.issues.length > 0;
}

function validateRepository(section: string, activity: RepositoryActivity, errors: string[]): void {
    for (const commit of activity.commits) {
        if (isOmittedCommit(commit.subject)) continue;
        if (!section.includes(commit.subject) || !section.includes(commit.shortHash)) {
            errors.push(`Missing commit ${commit.shortHash}: ${commit.subject}`);
        } else if (commit.url && !section.includes(commit.url)) {
            errors.push(`Missing commit link ${commit.shortHash}: ${commit.url}`);
        }
    }

    for (const pullRequest of activity.pullRequests) {
        if (!section.includes(pullRequest.title) || !section.includes(pullRequest.url)) {
            errors.push(`Missing pull request #${pullRequest.number}: ${pullRequest.title}`);
        }
    }

    for (const issue of activity.issues) {
        if (!section.includes(issue.title) || !section.includes(issue.url)) {
            errors.push(`Missing issue #${issue.number}: ${issue.title}`);
        }
    }
}

export function validateChangelog(note: string, report: ActivityReport): ValidationResult {
    const headings = changelogHeadings(note);
    if (headings.length !== 1) {
        return {
            valid: false,
            errors: ["Expected exactly one ## Changelog section"]
        };
    }

    const errors: string[] = [];
    const section = changelogBody(note);
    for (const activity of report.repositories) {
        const repositorySection = repositoryBody(section, activity.repository.key);
        if (repositorySection === undefined) {
            if (hasVisibleActivity(activity)) {
                errors.push(`Missing repository heading: ${activity.repository.key}`);
            }
            continue;
        }
        validateRepository(repositorySection, activity, errors);
    }

    for (const legacyHeading of ["## Dev Activity", "## GitHub Activity"]) {
        if (new RegExp(`^${legacyHeading}$`, "m").test(note)) {
            errors.push(`Legacy activity section remains: ${legacyHeading}`);
        }
    }

    return { valid: errors.length === 0, errors };
}

export function parseArguments(args: readonly string[]): ValidationArguments {
    if (args.length !== 2 || args.some(argument => !argument.trim())) {
        throw new Error("Usage: validate-changelog.ts NOTE_PATH REPORT_PATH");
    }
    return { notePath: args[0], reportPath: args[1] };
}

function parseReport(json: string): ActivityReport {
    const parsed: unknown = JSON.parse(json);
    if (
        typeof parsed !== "object" ||
        parsed === null ||
        !Array.isArray((parsed as Record<string, unknown>).repositories) ||
        !Array.isArray((parsed as Record<string, unknown>).errors)
    ) {
        throw new Error("Activity report must contain repositories and errors arrays");
    }
    return parsed as ActivityReport;
}

export function main(args: readonly string[] = process.argv.slice(2)): void {
    const { notePath, reportPath } = parseArguments(args);
    const result = validateChangelog(readFileSync(notePath, "utf8"), parseReport(readFileSync(reportPath, "utf8")));
    console.log(JSON.stringify(result, null, 2));
    if (!result.valid) process.exitCode = 1;
}

if (process.argv[1]?.endsWith("validate-changelog.ts")) main();
