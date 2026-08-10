/**
 * enforce.ts — Global enforcement extension for Pi
 *
 * Ports the Claude Code hooks from common/.claude/hooks/enforce/:
 *   - current-datetime.sh  → before_agent_start : inject date/time into system prompt
 *   - session-start.sh     → session_start       : inject meta-enforcement skill content
 *   - skills-check.sh      → input               : keyword-match → suggest relevant skills
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
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
      ".agents/skills/meta-enforcement/SKILL.md",
    );

    let skillContent: string;
    try {
      const raw = readFileSync(skillPath, "utf8");
      // Strip YAML frontmatter (everything between first --- pair)
      skillContent = raw.replace(/^---[\s\S]*?---\n/, "").trim();
    } catch {
      ctx.ui.notify(
        "enforce: meta-enforcement skill not found — skipping injection",
        "warning",
      );
      return;
    }

    pi.sendMessage(
      {
        customType: "enforce-meta",
        content: skillContent,
        display: false,
      },
      { triggerTurn: false },
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
        prompt,
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

    // dev-commit — committing code
    if (
      /^commit/.test(prompt) ||
      /lets commit/.test(prompt) ||
      /create a commit/.test(prompt) ||
      /commit (this|these|the)/.test(prompt)
    ) {
      matches.push("dev-commit — Commit format and strategy");
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
      matches.push("dev-audit — Audit code quality (ui, style, arch, docs)");
    }

    // dots skills — dotfiles management
    if (repo === "dots") {
      if (/add.*config|new.*config|remove.*config|delete.*config|symlink|unlink|dotfile/.test(prompt)) {
        matches.push("dots-manage — Add/remove config from dots");
      }
    }

    if (matches.length > 0) {
      const list = matches.map((m) => `  → ${m}`).join("\n");
      ctx.ui.notify(`Skills check — consider invoking:\n${list}`, "info");
    }

    return { action: "continue" };
  });
}
