export interface OpenRouterPricing {
	prompt: number;
	completion: number;
}

export interface UsageLike {
	input: number;
	output: number;
	cacheRead: number;
	cacheWrite: number;
	cost: { total: number; [key: string]: unknown };
}

export interface SessionEntriesSource {
	getEntries(): ReadonlyArray<{
		type: string;
		message?: { role?: string; provider?: string; model?: string; responseModel?: string; usage?: UsageLike };
		usage?: UsageLike;
	}>;
}

export const OPENROUTER_MODELS_URL = "https://openrouter.ai/api/v1/models";

export function parseOpenRouterPricing(payload: unknown): Map<string, OpenRouterPricing> {
	const pricing = new Map<string, OpenRouterPricing>();
	const data = (payload as { data?: unknown } | null)?.data;
	if (!Array.isArray(data)) return pricing;
	for (const model of data) {
		if (!model || typeof model !== "object") continue;
		const { id, pricing: rates } = model as { id?: unknown; pricing?: unknown };
		if (typeof id !== "string" || !rates || typeof rates !== "object") continue;
		const { prompt, completion } = rates as { prompt?: unknown; completion?: unknown };
		const promptRate = typeof prompt === "string" ? Number(prompt) : prompt;
		const completionRate = typeof completion === "string" ? Number(completion) : completion;
		if (typeof promptRate !== "number" || !Number.isFinite(promptRate)) continue;
		if (typeof completionRate !== "number" || !Number.isFinite(completionRate)) continue;
		// OpenRouter marks dynamically-priced models (e.g. openrouter/auto) with -1 rates.
		if (promptRate <= 0 || completionRate <= 0) continue;
		pricing.set(id, { prompt: promptRate, completion: completionRate });
	}
	return pricing;
}

/** OpenRouter bills all prompt-side tokens (including cached) at the model's prompt rate. */
export function openrouterUsageCost(pricing: OpenRouterPricing, usage: UsageLike): number {
	const promptTokens = usage.input + usage.cacheRead + usage.cacheWrite;
	return promptTokens * pricing.prompt + usage.output * pricing.completion;
}

export interface CostAdjustment {
	estimated: number;
	live: number;
}

/**
 * Delta between pi's catalog-rate estimate and OpenRouter's live pricing for
 * assistant messages of openrouter models present in the pricing table.
 */
export function openrouterCostAdjustment(
	entries: ReadonlyArray<{
		type: string;
		message?: { role?: string; provider?: string; model?: string; responseModel?: string; usage?: UsageLike };
		usage?: UsageLike;
	}>,
	pricing: Map<string, OpenRouterPricing>,
): CostAdjustment {
	let estimated = 0;
	let live = 0;
	for (const entry of entries) {
		const message = entry.message;
		if (entry.type !== "message" || message?.role !== "assistant" || message.provider !== "openrouter") continue;
		const usage = message.usage;
		if (!usage) continue;
		// With routing endpoints (openrouter/auto) each request may resolve to a different model.
		const rates = pricing.get(message.responseModel ?? message.model ?? "");
		if (!rates) continue;
		estimated += usage.cost.total;
		live += openrouterUsageCost(rates, usage);
	}
	return { estimated, live };
}

export function formatModelRate(perToken: number): string {
	return `$${(perToken * 1_000_000).toFixed(2)}/M`;
}

export async function fetchOpenRouterPricing(fetchImpl: typeof fetch = fetch): Promise<Map<string, OpenRouterPricing>> {
	const response = await fetchImpl(OPENROUTER_MODELS_URL);
	if (!response.ok) throw new Error(`OpenRouter models request failed: ${response.status}`);
	return parseOpenRouterPricing(await response.json());
}
