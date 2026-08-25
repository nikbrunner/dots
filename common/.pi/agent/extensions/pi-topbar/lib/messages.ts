function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null;
}

export function extractAssistantText(message: unknown): string | undefined {
	if (!isRecord(message) || message.role !== "assistant" || !Array.isArray(message.content)) return undefined;

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
