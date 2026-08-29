export function getActiveAccountLabel(accounts: unknown, provider: string): string | undefined {
	if (!accounts || typeof accounts !== "object" || Array.isArray(accounts)) return undefined;
	const providers = (accounts as Record<string, unknown>).providers;
	if (!providers || typeof providers !== "object" || Array.isArray(providers)) return undefined;
	const state = (providers as Record<string, unknown>)[provider];
	if (!state || typeof state !== "object" || Array.isArray(state)) return undefined;
	const active = (state as Record<string, unknown>).active;
	return typeof active === "string" && active.length > 0 ? active : undefined;
}
