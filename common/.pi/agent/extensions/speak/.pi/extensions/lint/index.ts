/**
 * Lint Extension for Pi
 *
 * Runs ESLint and Prettier checks after every turn. Auto-fixes
 * issues and notifies the agent before returning to user.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function lintExtension(pi: ExtensionAPI) {
  // Run lint/format checks after each turn
  pi.on("turn_end", async (_event, ctx) => {
    const lintResult = await pi.exec("npm", ["run", "lint:check"]);

    if (lintResult.code === 0) {
      ctx.ui.notify("Lint checks passed", "info");
    } else {
      ctx.ui.notify("Lint checks failed", "error");
      // TODO: make the agent aware of the lint errors
      // console.log is probably not the best way to do this
      console.log(lintResult.stderr);
    }

    const formatResult = await pi.exec("npm", ["run", "format"]);

    if (formatResult.code === 0) {
      ctx.ui.notify("Ran formatting checks", "info");
    } else {
      ctx.ui.notify("Formatting checks failed", "error");
      // TODO: make the agent aware of the formatting errors
      // console.log is probably not the best way to do this
      console.log(formatResult.stderr);
    }
  });
}
