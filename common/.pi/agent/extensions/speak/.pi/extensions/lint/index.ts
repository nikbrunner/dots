/**
 * Lint Extension for Pi
 *
 * Runs ESLint and Prettier checks after every turn. Auto-fixes
 * issues and notifies the agent before returning to user.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function lintExtension(pi: ExtensionAPI) {
  // Run lint/format checks after each turn
  pi.on("turn_end", async (event, ctx) => {
    // Find all TypeScript files that were modified this turn
    const modifiedFiles = new Set<string>();

    for (const msg of event.message.content) {
      if (msg.type === "tool-result") {
        const path = (msg as { path?: string }).path;
        if (path && path.endsWith(".ts") && !path.includes("node_modules")) {
          modifiedFiles.add(path);
        }
      }
    }

    if (modifiedFiles.size === 0) return;

    const files = Array.from(modifiedFiles);

    // Run auto-fix (silently fixes formatting/lint issues)
    const result = await pi.exec("npm", ["run", "lint:fix", "--", ...files]);

    if (result.code === 0) {
      // Inject message so agent is aware
      ctx.sessionManager.appendMessage({
        role: "user",
        content: [
          {
            type: "text",
            text: `[Lint: auto-fixed issues in ${files.length} file(s): ${files.join(", ")}]`,
          },
        ],
        timestamp: Date.now(),
      });
    }
  });
}
