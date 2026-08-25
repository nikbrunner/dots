import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { Context } from "@earendil-works/pi-ai";
import { Box, Text, truncateToWidth, type Component, visibleWidth } from "@earendil-works/pi-tui";
import { darkenRgb, paintBackground, type RgbColor } from "./lib/colors";
import {
	applyTopbarPadding,
	clipTopbarLines,
	DEFAULT_TOPBAR_SHORTCUT,
	getTopbarContentMaxHeight,
	getTopbarOverlayOptions,
	layoutTopbarSections,
	nextTopbarView,
	type TopbarPadding,
	type TopbarView,
} from "./lib/layout";
import { extractAssistantText } from "./lib/messages";
import {
	buildFocusPrompt,
	buildSummaryPrompt,
	extractToolActivity,
	extractUserText,
	getConversationStateSummaryConfig,
	getSummaryDelay,
	shouldRefreshSummary,
	type SummaryConfig,
} from "./lib/summary";
import conversationStateProvider from "./providers/conversation-state";
import sessionNameProvider from "./providers/session-name";
import type { TopbarProvider, TopbarProviderContent, TopbarProviderContext } from "./providers/types";

interface TopbarSlot {
	provider: string;
	maxLines?: number;
	summary?: Partial<SummaryConfig>;
}

interface TopbarConfig {
	shortcut: string;
	maxHeight: number;
	gap: number;
	padding: TopbarPadding;
	"border-bottom": boolean;
	background: { source: "terminal"; darken: number };
	providers: TopbarSlot[];
	conversationStateSummary: SummaryConfig;
}

const extensionDir = dirname(fileURLToPath(import.meta.url));
const providerRegistry = new Map<string, TopbarProvider>([
	[sessionNameProvider.id, sessionNameProvider],
	[conversationStateProvider.id, conversationStateProvider],
]);
let activeContext: TopbarProviderContext | undefined;
let requestRender: (() => void) | undefined;
let lastResponse: string | undefined;
let pendingResponse: string | undefined;
let focus: string | undefined;
let focusSource: string | undefined;
let currentState: string | undefined;
let focusController: AbortController | undefined;
let focusPending = false;
let summaryPending = false;
let spinnerTimer: ReturnType<typeof setInterval> | undefined;
let summaryTimer: ReturnType<typeof setTimeout> | undefined;
let summaryController: AbortController | undefined;
let summaryDirty = false;
let lastSummaryAt = 0;
let focusGeneration = 0;
let summaryGeneration = 0;

function restoreFocus(ctx: ExtensionContext): string | undefined {
	const branch = ctx.sessionManager.getBranch();
	for (let index = branch.length - 1; index >= 0; index -= 1) {
		const entry = branch[index];
		if (entry.type !== "message") continue;
		const text = extractUserText(entry.message);
		if (text) return text;
	}
	return undefined;
}

function getRecentConversation(ctx: ExtensionContext): string[] {
	return ctx.sessionManager
		.getBranch()
		.slice(-12)
		.flatMap((entry) => {
			if (entry.type !== "message") return [];
			const userText = extractUserText(entry.message);
			if (userText) return [`User: ${userText}`];
			const assistantText = extractAssistantText(entry.message);
			if (assistantText) return [`Assistant: ${assistantText}`];
			const toolActivity = extractToolActivity(entry.message);
			return toolActivity ? [toolActivity] : [];
		});
}

function restoreLastResponse(ctx: ExtensionContext): string | undefined {
	const branch = ctx.sessionManager.getBranch();
	for (let index = branch.length - 1; index >= 0; index -= 1) {
		const entry = branch[index];
		if (entry.type !== "message") continue;
		const text = extractAssistantText(entry.message);
		if (text) return text;
	}
	return undefined;
}

function readConfig(): TopbarConfig {
	const config = JSON.parse(readFileSync(join(extensionDir, "config.json"), "utf8")) as Partial<TopbarConfig>;
	return {
		shortcut: config.shortcut ?? DEFAULT_TOPBAR_SHORTCUT,
		maxHeight: config.maxHeight ?? 20,
		gap: config.gap ?? 1,
		padding: {
			top: config.padding?.top ?? 0,
			right: config.padding?.right ?? 1,
			bottom: config.padding?.bottom ?? 0,
			left: config.padding?.left ?? 1,
		},
		"border-bottom": config["border-bottom"] ?? false,
		background: config.background ?? { source: "terminal", darken: 0.1 },
		providers: config.providers ?? [],
		conversationStateSummary: getConversationStateSummaryConfig(config.providers ?? []),
	};
}

function renderContent(content: TopbarProviderContent, width: number): string[] {
	if (content === undefined) return [];
	return Array.isArray(content) ? content : content.render(width);
}

function limitProviderLines(lines: string[], maxLines: number, width: number): string[] {
	const limited = lines.slice(0, maxLines);
	if (lines.length > maxLines && limited.length > 0) {
		limited[limited.length - 1] = truncateToWidth(limited[limited.length - 1], width, "…");
	}
	return limited;
}

function padLine(line: string, width: number): string {
	const truncated = truncateToWidth(line, width, "");
	return truncated + " ".repeat(Math.max(0, width - visibleWidth(truncated)));
}

class TopbarShell implements Component {
	private expanded = false;

	constructor(
		private readonly context: TopbarProviderContext,
		private readonly config: TopbarConfig,
		private readonly background: RgbColor | undefined,
	) {}

	setExpanded(expanded: boolean): void {
		this.expanded = expanded;
	}

	getMaxHeight(): number {
		return this.config.maxHeight;
	}

	render(width: number): string[] {
		const contentWidth = Math.max(1, width - this.config.padding.left - this.config.padding.right);
		const sections: string[][] = [];
		const maxLines: number[] = [];

		for (const slot of this.config.providers) {
			const provider = providerRegistry.get(slot.provider);
			if (!provider) continue;

			const content = provider.render(this.context);
			const providerLines = renderContent(content, contentWidth);
			const providerMaxLines = slot.maxLines ?? providerLines.length;
			const lines = this.expanded ? providerLines : limitProviderLines(providerLines, providerMaxLines, contentWidth);
			if (lines.length > 0) {
				sections.push(lines);
				maxLines.push(providerMaxLines);
			}
		}

		const lines = layoutTopbarSections(sections, maxLines, this.expanded, this.config.gap);
		const contentMaxHeight = getTopbarContentMaxHeight(this.config.maxHeight, this.config["border-bottom"]);
		const visibleLines = clipTopbarLines(lines, this.expanded, contentMaxHeight);
		if (lines.length > visibleLines.length && visibleLines.length > 0) {
			visibleLines[visibleLines.length - 1] = truncateToWidth(visibleLines[visibleLines.length - 1], contentWidth, "…");
		}
		if (this.config["border-bottom"]) {
			visibleLines.push(this.context.theme.fg("muted", "─".repeat(contentWidth)));
		}
		const box = new Box(0, 0, (text) =>
			this.background ? paintBackground(text, this.background) : text,
		);
		const paddedLines = applyTopbarPadding(
			visibleLines.map((line) => padLine(line, contentWidth)),
			this.config.padding,
		);
		box.addChild(new Text(paddedLines.join("\n"), 0, 0));
		return box.render(width);
	}

	invalidate(): void {}
}

export default function (pi: ExtensionAPI): void {
	const config = readConfig();
	let hideOverlay: (() => void) | undefined;
	let overlayHandle: { setHidden(hidden: boolean): void } | undefined;
	let topbarShell: TopbarShell | undefined;
	let view: TopbarView = "compact";

	const clearOverlay = (): void => {
		hideOverlay?.();
		hideOverlay = undefined;
	};

	const setFocusPending = (pending: boolean): void => {
		if (focusPending === pending) return;
		focusPending = pending;
		if (activeContext) activeContext.focusPending = pending;
		requestRender?.();
	};

	const setSummaryPending = (pending: boolean): void => {
		if (summaryPending === pending) return;
		summaryPending = pending;
		if (activeContext) activeContext.summaryPending = pending;
		if (spinnerTimer) clearInterval(spinnerTimer);
		spinnerTimer = pending ? setInterval(() => requestRender?.(), 80) : undefined;
		requestRender?.();
	};

	const refreshSummaryPending = (): void => {
		setFocusPending(focusController !== undefined);
		setSummaryPending(summaryController !== undefined);
	};

	const clearSummaryWork = (): void => {
		if (summaryTimer) clearTimeout(summaryTimer);
		summaryTimer = undefined;
		focusController?.abort();
		focusController = undefined;
		summaryController?.abort();
		summaryController = undefined;
		summaryDirty = false;
		setFocusPending(false);
		setSummaryPending(false);
		focusGeneration += 1;
		summaryGeneration += 1;
	};

	const getSummaryModel = (ctx: ExtensionContext) => {
		const separator = config.conversationStateSummary.model.indexOf("/");
		if (separator <= 0 || separator === config.conversationStateSummary.model.length - 1) return undefined;
		return ctx.modelRegistry.find(
			config.conversationStateSummary.model.slice(0, separator),
			config.conversationStateSummary.model.slice(separator + 1),
		);
	};

	const getSummarySnapshot = (ctx: ExtensionContext) => ({
		request: focusSource ?? focus ?? "Current request",
		focus: focus ?? "Current request",
		lastResponse,
		recentActivity: getRecentConversation(ctx),
	});

	const updateFocus = async (
		ctx: ExtensionContext,
		{ request, fallback }: { request: string; fallback?: string },
	): Promise<void> => {
		const model = getSummaryModel(ctx);
		if (!model) return;

		focusController?.abort();
		const controller = new AbortController();
		const generation = ++focusGeneration;
		focusController = controller;
		setFocusPending(true);
		try {
			const response = await ctx.modelRegistry.complete(
				model,
				{
					systemPrompt:
						"You infer the user's stable coding goal for a small status bar. Be concise and concrete.",
					messages: [{
						role: "user",
						content: buildFocusPrompt({
							request,
							recentConversation: getRecentConversation(ctx),
						}),
						timestamp: Date.now(),
					}],
				} satisfies Context,
				{ maxTokens: config.conversationStateSummary.maxTokens, signal: controller.signal },
			);
			const goal = extractAssistantText(response)?.replace(/\s+/g, " ");
			if (goal && generation === focusGeneration && focusSource === request) {
				focus = goal;
				if (activeContext) activeContext.focus = focus;
				requestRender?.();
			}
		} catch {
			if (generation === focusGeneration) {
				focus = fallback ?? "Updating focus…";
				if (activeContext) activeContext.focus = focus;
				requestRender?.();
			}
		} finally {
			if (focusController === controller) focusController = undefined;
			refreshSummaryPending();
			if (summaryDirty) scheduleSummary(ctx);
		}
	};

	const updateSummary = async (ctx: ExtensionContext): Promise<void> => {
		if (!summaryDirty || !config.conversationStateSummary.enabled || !focus || summaryController) return;
		const model = getSummaryModel(ctx);
		if (!model) return;

		summaryDirty = false;
		const focusAtStart = focus;
		const generation = ++summaryGeneration;
		const controller = new AbortController();
		summaryController = controller;
		setSummaryPending(true);
		try {
			const response = await ctx.modelRegistry.complete(
				model,
				{
					systemPrompt:
						"You summarize coding-session progress for a small status bar. Be concrete and concise.",
					messages: [{
						role: "user",
						content: buildSummaryPrompt(getSummarySnapshot(ctx)),
						timestamp: Date.now(),
					}],
				} satisfies Context,
				{ maxTokens: config.conversationStateSummary.maxTokens, signal: controller.signal },
			);
			const summary = extractAssistantText(response)?.replace(/\s+/g, " ");
			if (summary && generation === summaryGeneration && focus === focusAtStart) {
				currentState = summary;
				lastSummaryAt = Date.now();
				if (activeContext) activeContext.currentState = currentState;
				requestRender?.();
			}
		} catch {
			if (generation === summaryGeneration) {
				currentState = "Ready for the next prompt.";
				if (activeContext) activeContext.currentState = currentState;
				requestRender?.();
			}
		} finally {
			if (summaryController === controller) summaryController = undefined;
			refreshSummaryPending();
			if (summaryDirty) scheduleSummary(ctx);
		}
	};

	const scheduleSummary = (ctx: ExtensionContext): void => {
		if (!config.conversationStateSummary.enabled || !focus || summaryTimer || summaryController) return;
		const delay = getSummaryDelay({
			lastSummaryAt,
			now: Date.now(),
			minIntervalMs: config.conversationStateSummary.minIntervalMs,
		});
		summaryTimer = setTimeout(() => {
			summaryTimer = undefined;
			void updateSummary(ctx);
		}, delay);
	};

	const markSummaryDirty = (ctx: ExtensionContext): void => {
		summaryDirty = true;
		scheduleSummary(ctx);
	};

	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;
		clearOverlay();
		clearSummaryWork();
		overlayHandle = undefined;
		topbarShell = undefined;
		view = "compact";
		focusSource = restoreFocus(ctx);
		focus = focusSource ? "Updating focus…" : undefined;
		lastResponse = restoreLastResponse(ctx);
		currentState = focusSource ? "Ready for the next prompt." : undefined;
		pendingResponse = undefined;
		lastSummaryAt = 0;
		focusPending = Boolean(focusSource);
		summaryPending = Boolean(focusSource);

		void ctx.ui.custom<void>(
			async (tui, theme) => {
				const terminalBackground = await tui.queryTerminalBackgroundColor({ timeoutMs: 100 });
				const background = terminalBackground
					? darkenRgb(terminalBackground, config.background.darken)
					: undefined;
				const providerContext: TopbarProviderContext = {
					theme,
					sessionName: pi.getSessionName(),
					focus,
					focusPending,
					currentState,
					summaryPending,
					lastResponse,
				};
				activeContext = providerContext;
				requestRender = () => tui.requestRender();
				topbarShell = new TopbarShell(providerContext, config, background);
				return topbarShell;
			},
			{
				overlay: true,
				overlayOptions: () => getTopbarOverlayOptions(topbarShell?.getMaxHeight() ?? config.maxHeight),
				onHandle: (handle) => {
					overlayHandle = handle;
					hideOverlay = () => handle.hide();
				},
			},
		).finally(() => {
			hideOverlay = undefined;
			activeContext = undefined;
			requestRender = undefined;
			overlayHandle = undefined;
			topbarShell = undefined;
		});
		if (focusSource) {
			summaryDirty = true;
			void updateFocus(ctx, { request: focusSource, fallback: undefined });
			void updateSummary(ctx);
		}
	});

	pi.registerShortcut(config.shortcut, {
		description: "Cycle Pi Topbar compact, expanded, and hidden views",
		handler: async () => {
			view = nextTopbarView(view);
			if (!overlayHandle || !topbarShell) return;

			if (view === "hidden") {
				overlayHandle.setHidden(true);
			} else {
				overlayHandle.setHidden(false);
				topbarShell.setExpanded(view === "expanded");
			}
			requestRender?.();
		},
	});

	pi.on("message_end", (event, ctx) => {
		const userText = extractUserText(event.message);
		if (userText) {
			const previousFocus = focus === "Updating focus…" ? undefined : focus;
			focusSource = userText;
			focus = previousFocus ?? "Updating focus…";
			currentState = "Working on the current request.";
			focusController?.abort();
			focusGeneration += 1;
			summaryController?.abort();
			setFocusPending(true);
			setSummaryPending(true);
			summaryGeneration += 1;
			if (summaryTimer) clearTimeout(summaryTimer);
			summaryTimer = undefined;
			summaryDirty = false;
			if (activeContext) {
				activeContext.focus = focus;
				activeContext.currentState = currentState;
				activeContext.lastResponse = undefined;
			}
			requestRender?.();
			void updateFocus(ctx, { request: userText, fallback: previousFocus });
			void updateSummary(ctx);
			return;
		}

		const text = extractAssistantText(event.message);
		if (text) pendingResponse = text;
		if (ctx.isIdle()) markSummaryDirty(ctx);
	});

	pi.on("turn_end", (_event, ctx) => {
		if (shouldRefreshSummary("turn_end")) markSummaryDirty(ctx);
	});

	pi.on("agent_settled", (_event, ctx) => {
		if (!ctx.isIdle()) return;
		lastResponse = pendingResponse ?? restoreLastResponse(ctx);
		pendingResponse = undefined;
		currentState = "Ready for the next prompt.";
		if (activeContext) {
			activeContext.lastResponse = lastResponse;
			activeContext.currentState = currentState;
		}
		markSummaryDirty(ctx);
		requestRender?.();
	});

	pi.on("session_info_changed", (event) => {
		if (activeContext) activeContext.sessionName = event.name;
		requestRender?.();
	});

	pi.on("session_shutdown", () => {
		clearOverlay();
		clearSummaryWork();
		activeContext = undefined;
		requestRender = undefined;
		overlayHandle = undefined;
		topbarShell = undefined;
		view = "compact";
		focus = undefined;
		focusSource = undefined;
		currentState = undefined;
		pendingResponse = undefined;
	});
}
