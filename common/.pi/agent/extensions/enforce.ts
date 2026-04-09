/**
 * enforce.ts — Global enforcement extension for Pi
 *
 * Ports the 5 Claude Code hooks from common/.claude/hooks/enforce/:
 *   - current-datetime.sh  → before_agent_start : inject date/time into system prompt
 *   - session-start.sh     → session_start       : inject meta-enforcement skill content
 *   - skills-check.sh      → input               : keyword-match → suggest relevant skills
 *   - semantic-commits.sh  → tool_call (bash)    : block non-semantic git commits
 *   - warn-any-type.sh     → tool_result         : warn on `: any` / `as any` in TS files
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { isToolCallEventType } from "@mariozechner/pi-coding-agent";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { homedir } from "node:os";

export default function (pi: ExtensionAPI) {
  // ─── 1. current-datetime: inject date/time before every agent turn ───────────

  pi.on("before_agent_start", async (event, _ctx) => {
    const now = new Date();
    const datetime = now.toLocaleString("en-US", {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
      timeZoneName: "short",
      weekday: "long",
    });

    return {
      systemPrompt:
        (event.systemPrompt ?? "") + `\n\nCurrent date/time: ${datetime}`,
    };
  });

  // ─── 2. session-start: inject meta-enforcement skill content ─────────────────

  pi.on("session_start", async (_event, ctx) => {
    const skillPath = resolve(
      homedir(),
      ".agents/skills/meta-enforcement/SKILL.md"
    );

    let skillContent: string;
    try {
      const raw = readFileSync(skillPath, "utf8");
      // Strip YAML frontmatter (everything between first --- pair)
      skillContent = raw.replace(/^---[\s\S]*?---\n/, "").trim();
    } catch {
      ctx.ui.notify(
        "enforce: meta-enforcement skill not found — skipping injection",
        "warning"
      );
      return;
    }

    pi.sendMessage(
      {
        customType: "enforce-meta",
        content: skillContent,
        display: false,
      },
      { triggerTurn: false }
    );
  });

  // ─── 3. skills-check: keyword-match prompt → suggest relevant skills ──────────

  pi.on("input", async (event, ctx) => {
    if (event.source !== "interactive") return { action: "continue" };

    const prompt = event.text.toLowerCase();
    const cwd = ctx.cwd;
    const repo = cwd.split("/").pop() ?? "";

    const matches: string[] = [];

    // dev-flow assess — explicit task start signals
    if (
      /^(implement|build|refactor|fix|add|create|migrate|remove|delete|update|upgrade) /.test(
        prompt
      ) ||
      /lets (start|begin|work on)/.test(prompt) ||
      /i want to (start|begin|work on)/.test(prompt) ||
      /can you (implement|build|fix|add|create)/.test(prompt)
    ) {
      matches.push("dev-flow — Orient and assess before implementation");
    }

    // dev-flow plan — explicit planning requests
    if (
      /^plan /.test(prompt) ||
      /write.*(prd|plan|spec)/.test(prompt) ||
      /break.*(down|into)/.test(prompt) ||
      /create.*(issues|tickets|tasks)/.test(prompt)
    ) {
      matches.push("dev-flow — Create a plan or PRD");
    }

    // dev-util-commit — committing code
    if (
      /^commit/.test(prompt) ||
      /lets commit/.test(prompt) ||
      /create a commit/.test(prompt) ||
      /commit (this|these|the)/.test(prompt)
    ) {
      matches.push("dev-util-commit — Commit format and strategy");
    }

    // dev-style-tdd — explicit TDD requests
    if (
      /use tdd/.test(prompt) ||
      /red.green.refactor/.test(prompt) ||
      /write.*tests? first/.test(prompt) ||
      /test.driven/.test(prompt)
    ) {
      matches.push("dev-style-tdd — TDD discipline and test strategy");
    }

    // dev-flow close — explicit close/ship requests
    if (
      /^(close|ship|finish|wrap up)/.test(prompt) ||
      /lets (close|ship|finish|wrap up)/.test(prompt) ||
      /create a pr/.test(prompt) ||
      /open a pr/.test(prompt) ||
      /merge (this|to)/.test(prompt)
    ) {
      matches.push("dev-flow — Verify, ship, and close");
    }

    // dev-audit — explicit audit/review requests
    if (
      /^(audit|review)/.test(prompt) ||
      /run.*(audit|review)/.test(prompt) ||
      /check.*(quality|conventions|a11y|accessibility)/.test(prompt)
    ) {
      matches.push(
        "dev-audit — Audit code quality (ui, style, arch, docs)"
      );
    }

    // dots skills — dotfiles management
    if (repo === "dots") {
      if (/add.*config|new.*config|symlink|dotfile/.test(prompt)) {
        matches.push("dots-add — Add config to dots");
      }
      if (/remove.*config|delete.*config|unlink/.test(prompt)) {
        matches.push("dots-remove — Remove config from dots");
      }
    }

    if (matches.length > 0) {
      const list = matches.map((m) => `  → ${m}`).join("\n");
      ctx.ui.notify(
        `Skills check — consider invoking:\n${list}`,
        "info"
      );
    }

    return { action: "continue" };
  });

  // ─── 4. semantic-commits: block git commits without semantic prefix ───────────

  pi.on("tool_call", async (event, _ctx) => {
    if (!isToolCallEventType("bash", event)) return;

    const command: string = event.input.command ?? "";
    const firstLine = command.split("\n")[0];

    if (!/^git commit/.test(firstLine.trim())) return;

    // Extract commit message from -m "..." or heredoc
    let msg = "";

    // Heredoc: find first non-blank line between heredoc delimiter and EOF
    if (command.includes("cat <<")) {
      const heredocMatch = command.match(
        /cat <<['"]?EOF['"]?\n([\s\S]*?)\n\s*EOF/
      );
      if (heredocMatch) {
        msg =
          heredocMatch[1]
            .split("\n")
            .find((l) => l.trim().length > 0)
            ?.trim() ?? "";
      }
    }

    // -m "msg" or -m 'msg'
    if (!msg) {
      const mMatch = firstLine.match(/-m\s+["'](.+?)["']/);
      if (mMatch) msg = mMatch[1];
    }

    // -m msg (no quotes)
    if (!msg) {
      const mBare = firstLine.match(/-m\s+([^"'\s]\S*)/);
      if (mBare) msg = mBare[1];
    }

    // Can't extract message — allow (might be amend, interactive, etc.)
    if (!msg) return;

    const semanticPrefix =
      /^\s*(feat|fix|refactor|chore|docs|style|test|ci|perf)(\(.+\))?(!)?:/;
    if (semanticPrefix.test(msg)) return;

    return {
      block: true,
      reason: `Commit message must start with a semantic prefix.\nValid: feat:, fix:, refactor:, chore:, docs:, style:, test:, ci:, perf:\nExample: feat(nvim): add telescope extension\nYour message: ${msg}`,
    };
  });

  // ─── 5. warn-any-type: warn on `: any` / `as any` in TS files ────────────────

  pi.on("tool_result", async (event, ctx) => {
    if (event.toolName !== "write" && event.toolName !== "edit") return;

    const input = event.input as Record<string, unknown>;
    const filePath: string =
      (input.file_path as string) ?? (input.path as string) ?? "";

    if (!/\.(ts|tsx)$/.test(filePath)) return;

    // For write: check full content. For edit: check new_string.
    const content: string =
      event.toolName === "write"
        ? (input.content as string) ?? ""
        : (input.new_string as string) ?? "";

    if (/:\s*any\b|as\s+any\b/.test(content)) {
      ctx.ui.notify(
        `TypeScript \`any\` detected in ${filePath.split("/").pop()}.\nPrefer proper types or \`unknown\` as a last resort.`,
        "warning"
      );
    }
  });
}
