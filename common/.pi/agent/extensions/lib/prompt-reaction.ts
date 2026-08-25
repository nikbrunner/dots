const PROMPT_REACTION_INSTRUCTION = `## Opening reaction

For the first assistant response after each user prompt:
- Before any tool call, write one short, natural sentence that shows what you understood and the direction you will take.
- If the request contains a material mistake, risk, or unclear assumption, use that sentence to push back briefly instead of agreeing.
- Continue the task immediately in the same response. Do not wait for confirmation merely because you reacted first.
- For a simple conversational prompt, let the direct answer itself serve as the reaction. Do not add a redundant preface.
- Avoid formulaic receipts such as "Prompt received" or "I understand your request."`;

export function addPromptReactionInstruction(systemPrompt: string): string {
	return `${systemPrompt}\n\n${PROMPT_REACTION_INSTRUCTION}`;
}
