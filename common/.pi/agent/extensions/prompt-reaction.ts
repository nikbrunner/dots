import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { addPromptReactionInstruction } from "./lib/prompt-reaction";

export default function promptReactionExtension(pi: ExtensionAPI): void {
	pi.on("before_agent_start", (event) => ({
		systemPrompt: addPromptReactionInstruction(event.systemPrompt),
	}));
}
