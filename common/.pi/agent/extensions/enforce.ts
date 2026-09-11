import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
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

  pi.on("input", async (event, ctx) => {
    if (event.source !== "interactive" || !ctx.hasUI) {
      return { action: "continue" };
    }

    const prompt = event.text.toLowerCase();
    const matches: string[] = [];

    if (
      /^(implement|build|refactor|fix|add|migrate|remove|delete|update|upgrade) /.test(prompt) ||
      /^can you (implement|build|fix|add) /.test(prompt)
    ) {
      matches.push("Project/language conventions for the code being changed");
    }

    if (
      /^(use tdd|red.green.refactor|write tests? first|test.driven)(\s|[.,:;!?]|$)/.test(prompt) ||
      /^(implement|build|fix) .* (using|with) tdd(\s|[.,:;!?]|$)/.test(prompt)
    ) {
      matches.push("dev-style-tdd — Requested test-first work");
    }

    if (
      /^(audit|review)(\s|$)/.test(prompt) ||
      /^run (an? )?(audit|review)(\s|$)/.test(prompt) ||
      /^check .*(quality|conventions|a11y|accessibility)/.test(prompt)
    ) {
      matches.push("dev-audit — Requested review scope");
    }

    if (/^(commit|lets commit|let's commit|create a commit)(\s|$)/.test(prompt)) {
      matches.push("dev-commit — Requested commit work");
    }

    if (matches.length > 0) {
      const list = matches.map((m) => `  → ${m}`).join("\n");
      ctx.ui.notify(`Skills to consider for this step:\n${list}`, "info");
    }

    return { action: "continue" };
  });
}
