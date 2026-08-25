export interface SummaryConfig {
	enabled: boolean;
	model: string;
	minIntervalMs: number;
	maxTokens: number;
}

interface SummaryProviderSlot {
	provider: string;
	summary?: Partial<SummaryConfig>;
}

interface FocusPromptInput {
	request: string;
	recentConversation: string[];
}

interface SummaryPromptInput {
	request: string;
	focus: string;
	lastResponse?: string;
	recentActivity: string[];
}

interface SummaryDelayInput {
	lastSummaryAt: number;
	now: number;
	minIntervalMs: number;
}

export function getConversationStateSummaryConfig(slots: readonly SummaryProviderSlot[]): SummaryConfig {
	const summary = slots.find((slot) => slot.provider === "conversation-state")?.summary;
	return {
		enabled: summary?.enabled ?? false,
		model: summary?.model ?? "",
		minIntervalMs: summary?.minIntervalMs ?? 60_000,
		maxTokens: summary?.maxTokens ?? 80,
	};
}

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null;
}

export function extractUserText(message: unknown): string | undefined {
	if (!isRecord(message) || message.role !== "user") return undefined;

	if (typeof message.content === "string") {
		const text = message.content.trim();
		return text || undefined;
	}

	if (!Array.isArray(message.content)) return undefined;
	const text = message.content
		.filter(
			(item): item is Record<string, unknown> =>
				isRecord(item) && item.type === "text" && typeof item.text === "string",
		)
		.map((item) => item.text as string)
		.join("\n")
		.trim();

	return text || undefined;
}

export function extractToolActivity(message: unknown): string | undefined {
	if (!isRecord(message) || message.role !== "toolResult" || typeof message.toolName !== "string") return undefined;
	return message.isError === true ? `tool: ${message.toolName} (error)` : `tool: ${message.toolName}`;
}

export function buildFocusPrompt({ request, recentConversation }: FocusPromptInput): string {
	const conversation = recentConversation.length > 0 ? recentConversation.join("\n") : "(none)";
	return [
		"Infer the user's underlying goal from the recent conversation and latest request.",
		"Return one concise goal phrase, not a verbatim request, progress update, or explanation.",
		`Latest request: ${request}`,
		`Recent conversation:\n${conversation}`,
	].join("\n\n");
}

export function shouldRefreshSummary(eventType: string): boolean {
	return eventType === "turn_end" || eventType === "agent_settled";
}

export function getSummaryDelay({ lastSummaryAt, now, minIntervalMs }: SummaryDelayInput): number {
	if (lastSummaryAt === 0) return 0;
	return Math.max(0, minIntervalMs - (now - lastSummaryAt));
}

export function buildSummaryPrompt({ request, focus, lastResponse, recentActivity }: SummaryPromptInput): string {
	const activity = recentActivity.length > 0 ? recentActivity.join("\n") : "(none)";
	return [
		"Write one short sentence describing the current progress and likely next step in this coding session.",
		"Do not rewrite or restate the Focus. Return only the progress sentence, with no label or quotation marks.",
		`Focus: ${focus}`,
		`Latest request: ${request}`,
		`Last response: ${lastResponse ?? "(none)"}`,
		`Recent activity:\n${activity}`,
	].join("\n\n");
}
