// Note which repo a session's directory belongs to, so a worktree can still be
// traced back to its source repo after being deleted. The ledger it writes is
// read by `bic`. See tools/bic.
//
// session_start is the anchor because it always fires; session_shutdown is
// skipped on Ctrl+C and on a closed terminal. agent_end repeats the record for
// long sessions that outlive a worktree created mid-conversation. Recording is
// idempotent, so the duplication costs nothing.

import { spawn } from "node:child_process";

function record() {
  try {
    const child = spawn("bic", ["record", "-cwd", process.cwd()], {
      stdio: "ignore",
      detached: true,
    });
    child.on("error", () => {});
    child.unref();
  } catch {
    // A telemetry side-effect must never break the agent.
  }
}

export default function (pi) {
  pi.on("session_start", () => record());
  pi.on("agent_end", () => record());
}
