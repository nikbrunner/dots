/**
 * Lint Extension for Pi
 *
 * Runs ESLint and Prettier checks BEFORE each turn. If there are lint errors,
 * injects them as a message so the agent is aware and can fix them.
 *
 * Configuration (environment variables):
 *   LINT_SCRIPT - npm script for lint checks (default: "lint:check")
 *   FORMAT_SCRIPT - npm script for format checks (default: "format")
 *   DISABLE_LINT - set to "true" to disable lint checks
 *   DISABLE_FORMAT - set to "true" to disable format checks
 *   LINT_ON_TURN_END - set to "true" to also run after turns (default: false)
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Text } from "@mariozechner/pi-tui";

// Configuration
const lintScript = process.env.LINT_SCRIPT ?? "lint:check";
const formatScript = process.env.FORMAT_SCRIPT ?? "format";
const disableLint = process.env.DISABLE_LINT === "true";
const disableFormat = process.env.DISABLE_FORMAT === "true";
const lintOnTurnEnd = process.env.LINT_ON_TURN_END === "true";

interface LintResult {
  passed: boolean;
  output: string;
  script: string;
}

async function runLintCheck(pi: ExtensionAPI, script: string): Promise<LintResult> {
  if (!script) {
    return { passed: true, output: "", script: "" };
  }

  const result = await pi.exec("npm", ["run", script]);
  return {
    passed: result.code === 0,
    output: result.stdout + result.stderr,
    script,
  };
}

function formatLintOutput(result: LintResult): string {
  if (result.passed) {
    return `✅ **${result.script}** passed`;
  }

  // Truncate output to avoid overwhelming (keep last 50 lines)
  const lines = result.output.split("\n");
  const truncated = lines.length > 50 ? lines.slice(-50) : lines;
  const truncatedOutput = truncated.join("\n");

  let formatted = `❌ **${result.script}** failed:\n\n\`\`\`\n${truncatedOutput}`;

  if (lines.length > 50) {
    formatted += `\n\n[Truncated: ${lines.length - 50} more lines]`;
  }

  formatted += "\n```";
  return formatted;
}

export default function lintExtension(pi: ExtensionAPI) {
  // Track last lint results for display
  let lastLintResults: LintResult[] = [];

  // Register custom message renderer for lint errors
  pi.registerMessageRenderer("lint-errors", (message, _options, theme) => {
    const lines: string[] = [];
    lines.push(theme.fg("error", "⚠️  Lint/Format Issues Detected"));
    lines.push(theme.fg("error", "─".repeat(40)));
    // Handle content being string or array
    const content = Array.isArray(message.content)
      ? message.content.map((c) => ("text" in c ? c.text : "")).join("")
      : message.content;
    lines.push(content);
    return new Text(lines.join("\n"), 0, 0);
  });

  // Check lint BEFORE the agent responds - this way agent sees errors immediately
  pi.on("before_agent_start", async (_event, ctx) => {
    const results: LintResult[] = [];

    if (!disableLint && lintScript) {
      const lintResult = await runLintCheck(pi, lintScript);
      results.push(lintResult);
    }

    if (!disableFormat && formatScript) {
      const formatResult = await runLintCheck(pi, formatScript);
      results.push(formatResult);
    }

    if (results.length === 0) {
      return;
    }

    lastLintResults = results;
    const allPassed = results.every((r) => r.passed);

    if (allPassed) {
      return;
    }

    // Build error message
    const errorMessages = results
      .filter((r) => !r.passed)
      .map(formatLintOutput)
      .join("\n\n");

    // Inject as a message so the agent SEES and CAN ADDRESS the errors
    return {
      message: {
        customType: "lint-errors" as const,
        content: [{ type: "text" as const, text: errorMessages }],
        display: true,
        details: {
          failedScripts: results.filter((r) => !r.passed).map((r) => r.script),
        },
      },
    };
  });

  // Also run after turn for visibility (optional)
  if (lintOnTurnEnd) {
    pi.on("turn_end", async (_event, ctx) => {
      if (!ctx.hasUI || lastLintResults.length === 0) {
        return;
      }

      const allPassed = lastLintResults.every((r) => r.passed);
      if (allPassed) {
        ctx.ui.notify("Lint & format checks passed", "info");
      } else {
        const failedCount = lastLintResults.filter((r) => !r.passed).length;
        ctx.ui.notify(
          `Lint/format issues (${failedCount} check${failedCount > 1 ? "s" : ""} failed)`,
          "warning",
        );
      }
    });
  }

  // Manual command to run lint
  pi.registerCommand("lint", {
    description: "Run lint and format checks",
    handler: async (_args, ctx) => {
      if (ctx.hasUI) {
        ctx.ui.notify("Running lint checks...", "info");
      }

      const results: LintResult[] = [];

      if (!disableLint && lintScript) {
        const lintResult = await runLintCheck(pi, lintScript);
        results.push(lintResult);
      }

      if (!disableFormat && formatScript) {
        const formatResult = await runLintCheck(pi, formatScript);
        results.push(formatResult);
      }

      const allPassed = results.every((r) => r.passed);

      if (allPassed) {
        if (ctx.hasUI) {
          ctx.ui.notify("All checks passed!", "info");
        }
        return;
      }

      const errorMessages = results
        .filter((r) => !r.passed)
        .map(formatLintOutput)
        .join("\n\n");

      pi.sendMessage(
        {
          customType: "lint-errors",
          content: errorMessages,
          display: true,
        },
        { triggerTurn: false },
      );

      if (ctx.hasUI) {
        ctx.ui.notify(`Lint check failed - see errors above`, "error");
      }
    },
  });
}
