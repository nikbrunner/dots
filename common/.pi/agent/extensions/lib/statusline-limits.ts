export interface UsageWindow {
	usedPercent?: number;
	resetAt?: number;
}

export interface CodexLimitSnapshot {
	provider?: string;
	weekly?: UsageWindow;
	fetchedAt?: number;
}

export function getCodexWeeklyWindow(
	snapshot: CodexLimitSnapshot | undefined,
	provider: string | undefined,
	fallback: CodexLimitSnapshot | undefined = undefined,
): UsageWindow | undefined {
	const current = snapshot !== undefined && snapshot.provider === provider && typeof snapshot.fetchedAt === "number"
		? snapshot.weekly
		: undefined;
	if (current) return current;

	return fallback !== undefined && fallback.provider === provider && typeof fallback.fetchedAt === "number"
		? fallback.weekly
		: undefined;
}
