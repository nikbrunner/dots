import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const CHANNEL = "pi-atelier:sidebar-panels";
const SOURCE = "codex-atelier-panel";
const PANEL_ID = "codex:limits" as const;

interface UsageWindow {
	usedPercent?: number;
	resetAt?: number;
}

interface UsageSnapshot {
	provider?: string;
	fiveHour?: UsageWindow;
	weekly?: UsageWindow;
	fetchedAt?: number;
}

declare global {
	var piCodexLimit: UsageSnapshot | undefined;
}

function isCodexProvider(provider: string | undefined): boolean {
	return /^openai-codex(?:-\d+)?$/.test(provider ?? "");
}

function formatWindow(window: UsageWindow | undefined): string {
	if (window?.usedPercent === undefined) return "unavailable";
	const used = Math.max(0, Math.min(100, window.usedPercent));
	const remaining = Math.round(100 - used);
	return `${remaining}% left, resets ${formatReset(window.resetAt)}`;
}

function formatReset(resetAt: number | undefined): string {
	if (resetAt === undefined) return "unknown";
	const minutes = Math.max(0, Math.round((resetAt * 1000 - Date.now()) / 60000));
	const days = Math.floor(minutes / (60 * 24));
	const hours = Math.floor((minutes % (60 * 24)) / 60);
	const remainingMinutes = minutes % 60;
	if (days > 0) return `in ${days}d ${hours}h`;
	if (hours > 0) return `in ${hours}h ${remainingMinutes}m`;
	return `in ${remainingMinutes}m`;
}

function emitPanel(
	pi: ExtensionAPI,
	ctx: ExtensionContext,
	revision: number,
	requestId?: string,
): void {
	const snapshot = globalThis.piCodexLimit;
	const provider = snapshot?.provider ?? ctx.model?.provider;
	const rows = !isCodexProvider(provider)
		? [{ text: "Only available for openai-codex", role: "muted" as const }]
		: snapshot
			? [
					{ text: `5-hour: ${formatWindow(snapshot.fiveHour)}`, role: "primary" as const },
					{ text: `Weekly: ${formatWindow(snapshot.weekly)}`, role: "accent" as const },
					{ text: `Updated: ${formatUpdated(snapshot.fetchedAt)}`, role: "muted" as const },
			  ]
			: [{ text: "Waiting for Codex usage data", role: "muted" as const }];

	pi.events.emit(CHANNEL, {
		version: 1,
		type: "register",
		source: SOURCE,
		revision,
		panel: {
			id: PANEL_ID,
			title: "Codex limits",
			rows,
			role: "cache",
		},
		...(requestId ? { requestId } : {}),
	});
}

function formatUpdated(timestamp: number | undefined): string {
	if (timestamp === undefined) return "unknown";
	return new Date(timestamp).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
}

export default function (pi: ExtensionAPI): void {
	let revision = 0;
	let currentContext: ExtensionContext | undefined;
	const publish = (ctx: ExtensionContext, requestId?: string): void => {
		revision += 1;
		emitPanel(pi, ctx, revision, requestId);
	};

	pi.events.on(CHANNEL, (event: unknown) => {
		if (!currentContext || typeof event !== "object" || event === null || !("type" in event)) return;
		if (event.type !== "discover" || !("requestId" in event) || typeof event.requestId !== "string") return;
		publish(currentContext, event.requestId);
	});

	pi.on("session_start", (_event, ctx) => {
		currentContext = ctx;
		publish(ctx);
	});
	pi.on("agent_end", (_event, ctx) => publish(ctx));
	pi.on("model_select", (_event, ctx) => publish(ctx));
	pi.on("turn_end", (_event, ctx) => publish(ctx));
	pi.on("session_shutdown", () => {
		currentContext = undefined;
		revision += 1;
		pi.events.emit(CHANNEL, {
			version: 1,
			type: "unregister",
			source: SOURCE,
			revision,
			id: PANEL_ID,
		});
	});
}
