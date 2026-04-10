/**
 * Lint Extension for Pi
 *
 * Tracks modified TypeScript files during the turn and runs
 * ESLint and Prettier checks on agent_end.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function lintExtension(pi: ExtensionAPI) {
  const modifiedFiles = new Set<string>();

  // Track write/edit tool calls
  pi.on("tool_result", async (event) => {
    if (event.toolName === "write" || event.toolName === "edit") {
      const path = event.input.path as string;
      if (path && path.endsWith(".ts") && !path.includes("node_modules")) {
        modifiedFiles.add(path);
      }
    }
  });

  // Run lint and format checks on agent_end
  pi.on("agent_end", async (_event, ctx) => {
    if (modifiedFiles.size === 0) return;

    const files = Array.from(modifiedFiles);
    modifiedFiles.clear();

    // Run ESLint check
    const lintResult = await pi.exec("npm", ["run", "lint:check", "--", ...files]);
    if (lintResult.code !== 0) {
      ctx.ui.notify(`Lint issues:\n${lintResult.stderr}`, "warning");
    }

    // Run Prettier check
    const formatResult = await pi.exec("npm", ["run", "format:check", "--", ...files]);
    if (formatResult.code !== 0) {
      ctx.ui.notify(`Format issues:\n${formatResult.stderr}`, "warning");
    }
  });
}
