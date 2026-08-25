import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Box, Text, truncateToWidth, type Component, visibleWidth } from "@earendil-works/pi-tui";
import { darkenRgb, paintBackground, type RgbColor } from "./lib/colors";
import {
	clipTopbarLines,
	DEFAULT_TOPBAR_SHORTCUT,
	getTopbarOverlayOptions,
	layoutTopbarSections,
	nextTopbarView,
	type TopbarView,
} from "./lib/layout";
import { extractAssistantText } from "./lib/messages";
import lastResponseProvider from "./providers/last-response";
import sessionNameProvider from "./providers/session-name";
import type { TopbarProvider, TopbarProviderContent, TopbarProviderContext } from "./providers/types";

interface TopbarSlot {
	provider: string;
	maxLines?: number;
}

interface TopbarConfig {
	shortcut: string;
	maxHeight: number;
	gap: number;
	background: { source: "terminal"; darken: number };
	providers: TopbarSlot[];
}

const extensionDir = dirname(fileURLToPath(import.meta.url));
const providerRegistry = new Map<string, TopbarProvider>([
	[sessionNameProvider.id, sessionNameProvider],
	[lastResponseProvider.id, lastResponseProvider],
]);
let activeContext: TopbarProviderContext | undefined;
let requestRender: (() => void) | undefined;
let lastResponse: string | undefined;
let pendingResponse: string | undefined;

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
		background: config.background ?? { source: "terminal", darken: 0.1 },
		providers: config.providers ?? [],
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
		const contentWidth = Math.max(1, width - 2);
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
		const visibleLines = clipTopbarLines(lines, this.expanded, this.config.maxHeight);
		if (lines.length > visibleLines.length && visibleLines.length > 0) {
			visibleLines[visibleLines.length - 1] = truncateToWidth(visibleLines[visibleLines.length - 1], contentWidth, "…");
		}

		const box = new Box(1, 0, (text) =>
			this.background ? paintBackground(text, this.background) : text,
		);
		box.addChild(new Text(visibleLines.map((line) => padLine(line, contentWidth)).join("\n"), 0, 0));
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

	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;
		clearOverlay();
		overlayHandle = undefined;
		topbarShell = undefined;
		view = "compact";
		lastResponse = restoreLastResponse(ctx);
		pendingResponse = undefined;

		void ctx.ui.custom<void>(
			async (tui, theme) => {
				const terminalBackground = await tui.queryTerminalBackgroundColor({ timeoutMs: 100 });
				const background = terminalBackground
					? darkenRgb(terminalBackground, config.background.darken)
					: undefined;
				const providerContext: TopbarProviderContext = {
					theme,
					sessionName: pi.getSessionName(),
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

	pi.on("message_end", (event) => {
		const text = extractAssistantText(event.message);
		if (text) pendingResponse = text;
	});

	pi.on("agent_settled", (_event, ctx) => {
		if (!ctx.isIdle() || pendingResponse === undefined) return;
		lastResponse = pendingResponse;
		pendingResponse = undefined;
		if (activeContext) activeContext.lastResponse = lastResponse;
		requestRender?.();
	});

	pi.on("session_info_changed", (event) => {
		if (activeContext) activeContext.sessionName = event.name;
		requestRender?.();
	});

	pi.on("session_shutdown", () => {
		clearOverlay();
		activeContext = undefined;
		requestRender = undefined;
		overlayHandle = undefined;
		topbarShell = undefined;
		view = "compact";
		pendingResponse = undefined;
	});
}
