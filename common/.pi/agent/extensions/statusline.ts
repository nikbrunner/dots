import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";
import { execFile } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { stripVTControlCharacters } from "node:util";

const MCP_STATUS_CHANNEL = "pi-mcp-adapter/status/v1";

interface Usage {
	input: number;
	output: number;
	cacheRead: number;
	cacheWrite: number;
	cost: { total: number };
}

interface UsageWindow {
	usedPercent?: number;
	resetAt?: number;
}

interface CodexLimitSnapshot {
	provider?: string;
	weekly?: UsageWindow;
	fetchedAt?: number;
}

interface McpStatusSnapshot {
	version: 1;
	servers: ReadonlyArray<{ disabled: boolean }>;
	connectedCount: number;
	disabledCount: number;
}

interface CodexCredential {
	accountId?: string;
	refresh?: string;
}

interface ActiveCodexAccount {
	identity: string;
	label?: string;
}

declare global {
	var piCodexLimit: CodexLimitSnapshot | undefined;
}

function getAgentDir(): string {
	const override = process.env.PI_CODING_AGENT_DIR?.trim();
	if (!override) return join(homedir(), ".pi", "agent");
	if (override === "~") return homedir();
	if (override.startsWith("~/")) return join(homedir(), override.slice(2));
	return override;
}

function readJson(path: string): Record<string, unknown> | undefined {
	if (!existsSync(path)) return undefined;
	try {
		const value: unknown = JSON.parse(readFileSync(path, "utf8"));
		return value && typeof value === "object" && !Array.isArray(value)
			? value as Record<string, unknown>
			: undefined;
	} catch {
		return undefined;
	}
}

function readCredential(value: unknown): CodexCredential | undefined {
	if (!value || typeof value !== "object" || Array.isArray(value)) return undefined;
	const record = value as Record<string, unknown>;
	return {
		...(typeof record.accountId === "string" ? { accountId: record.accountId } : {}),
		...(typeof record.refresh === "string" ? { refresh: record.refresh } : {}),
	};
}

function getActiveCodexAccount(): ActiveCodexAccount | undefined {
	const active = readCredential(readJson(join(getAgentDir(), "auth.json"))?.["openai-codex"]);
	const identity = active?.accountId ?? active?.refresh;
	if (!identity) return undefined;
	const accounts = readJson(join(getAgentDir(), "codex-accounts.json"))?.accounts;
	if (!accounts || typeof accounts !== "object" || Array.isArray(accounts)) return { identity };

	for (const [label, value] of Object.entries(accounts)) {
		const saved = value && typeof value === "object" && !Array.isArray(value)
			? readCredential((value as Record<string, unknown>).credential)
			: undefined;
		if (active?.accountId && saved?.accountId === active.accountId) return { identity, label };
	}
	for (const [label, value] of Object.entries(accounts)) {
		const saved = value && typeof value === "object" && !Array.isArray(value)
			? readCredential((value as Record<string, unknown>).credential)
			: undefined;
		if (active?.refresh && saved?.refresh === active.refresh) return { identity, label };
	}
	return { identity };
}

function isCodexProvider(provider: string | undefined): boolean {
	return /^openai-codex(?:-\d+)?$/.test(provider ?? "");
}

function isMcpStatusSnapshot(value: unknown): value is McpStatusSnapshot {
	if (!value || typeof value !== "object") return false;
	const snapshot = value as Partial<McpStatusSnapshot>;
	if (snapshot.version !== 1 || !Array.isArray(snapshot.servers)) return false;
	if (!snapshot.servers.every((server) => server && typeof server === "object" && typeof server.disabled === "boolean")) return false;
	if (!Number.isInteger(snapshot.connectedCount) || (snapshot.connectedCount ?? -1) < 0) return false;
	if (!Number.isInteger(snapshot.disabledCount) || (snapshot.disabledCount ?? -1) < 0) return false;
	if (snapshot.disabledCount !== snapshot.servers.filter((server) => server.disabled).length) return false;
	return (snapshot.connectedCount ?? 0) <= snapshot.servers.length - snapshot.disabledCount;
}

function sanitizeMcpStatus(status: string): string | undefined {
	const plain = stripVTControlCharacters(status)
		.replace(/[\u0000-\u001f\u007f]/g, " ")
		.replace(/\s+/g, " ")
		.trim()
		.replace(/^🔌\s*/u, "");
	return plain || undefined;
}

function conciseStatus(status: string): string {
	const characters = Array.from(status);
	return characters.length <= 48 ? status : `${characters.slice(0, 47).join("")}…`;
}

function formatMcpFooterStatus(status: string, wide: boolean): string | undefined {
	const plain = sanitizeMcpStatus(status);
	if (!plain) return undefined;

	const compact = /^MCP (\d+)\/(\d+)$/.exec(plain);
	if (compact) {
		const connected = Number(compact[1]);
		const enabled = Number(compact[2]);
		if (Number.isSafeInteger(connected) && Number.isSafeInteger(enabled) && connected <= enabled) {
			return wide ? `MCP ${connected} connected / ${enabled} enabled` : plain;
		}
	}

	const full = /^MCP: (\d+) servers? enabled(?: \((\d+) connected\))?(?: \((\d+) disabled\))?$/.exec(plain);
	if (full) {
		const enabled = Number(full[1]);
		const connected = Number(full[2] ?? 0);
		if (Number.isSafeInteger(connected) && Number.isSafeInteger(enabled) && connected <= enabled) {
			return wide ? `MCP ${connected} connected / ${enabled} enabled` : `MCP ${connected}/${enabled}`;
		}
	}

	return conciseStatus(plain);
}

function formatTokens(count: number): string {
	if (count < 1_000) return `${count}`;
	if (count < 10_000) return `${(count / 1_000).toFixed(1)}k`;
	if (count < 1_000_000) return `${Math.round(count / 1_000)}k`;
	if (count < 10_000_000) return `${(count / 1_000_000).toFixed(1)}M`;
	return `${Math.round(count / 1_000_000)}M`;
}

function formatReset(resetAt: number | undefined): string | undefined {
	if (resetAt === undefined) return undefined;
	const minutes = Math.max(0, Math.ceil((resetAt * 1_000 - Date.now()) / 60_000));
	const days = Math.floor(minutes / 1_440);
	const hours = Math.floor((minutes % 1_440) / 60);
	if (days > 0) return `${days}d ${hours}h`;
	if (hours > 0) return `${hours}h ${minutes % 60}m`;
	return `${minutes}m`;
}

function clampPercent(value: number): number {
	return Math.max(0, Math.min(100, value));
}

function usageTotals(ctx: ExtensionContext): { usage: Usage; cacheHit?: number } {
	const usage: Usage = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: { total: 0 } };
	let cacheHit: number | undefined;
	for (const entry of ctx.sessionManager.getEntries()) {
		let item: Usage | undefined;
		if (entry.type === "message" && entry.message.role === "assistant") {
			const assistantUsage = entry.message.usage;
			item = assistantUsage;
			const prompt = assistantUsage.input + assistantUsage.cacheRead + assistantUsage.cacheWrite;
			cacheHit = prompt > 0 ? assistantUsage.cacheRead / prompt * 100 : undefined;
		} else if (entry.type === "message" && entry.message.role === "toolResult") {
			item = entry.message.usage;
		} else if (entry.type === "compaction" || entry.type === "branch_summary") {
			item = entry.usage;
		}
		if (!item) continue;
		usage.input += item.input;
		usage.output += item.output;
		usage.cacheRead += item.cacheRead;
		usage.cacheWrite += item.cacheWrite;
		usage.cost.total += item.cost.total;
	}
	return { usage, cacheHit };
}

function meter(percent: number, width: number): string {
	const filled = Math.round(clampPercent(percent) / 100 * width);
	return `[${"█".repeat(filled)}${"·".repeat(width - filled)}]`;
}

export default function (pi: ExtensionAPI): void {
	const runtimeStartedAt = Date.now();
	let active = true;
	let requestRender = (): void => {};
	let state: "ready" | "working" | "error" = "ready";
	let dirty = false;
	let dirtyRefreshGeneration = 0;
	let dirtyRefreshTimer: ReturnType<typeof setTimeout> | undefined;
	let mcp: McpStatusSnapshot | undefined;
	let activeAccount: ActiveCodexAccount | undefined;
	let attributedSnapshotFetchedAt: number | undefined;
	let attributedAccountIdentity: string | undefined;

	const repaint = (): void => requestRender();
	const refreshActiveAccount = (): void => {
		activeAccount = getActiveCodexAccount();
	};
	const refreshDirty = (cwd: string): void => {
		const generation = ++dirtyRefreshGeneration;
		execFile("git", ["status", "--porcelain", "--untracked-files=normal"], { cwd }, (error, stdout) => {
			if (!active || generation !== dirtyRefreshGeneration) return;
			dirty = !error && stdout.length > 0;
			repaint();
		});
	};
	const scheduleDirtyRefresh = (cwd: string): void => {
		if (dirtyRefreshTimer) clearTimeout(dirtyRefreshTimer);
		dirtyRefreshTimer = setTimeout(() => {
			dirtyRefreshTimer = undefined;
			if (active) refreshDirty(cwd);
		}, 750);
	};

	pi.events.on(MCP_STATUS_CHANNEL, (snapshot: unknown) => {
		if (!active || !isMcpStatusSnapshot(snapshot)) return;
		mcp = snapshot;
		repaint();
	});

	pi.on("session_start", (_event, ctx) => {
		active = true;
		state = ctx.isIdle() ? "ready" : "working";
		refreshActiveAccount();
		refreshDirty(ctx.cwd);
		ctx.ui.setFooter((tui, theme, footerData) => {
			requestRender = (): void => tui.requestRender();
			const unsubscribe = footerData.onBranchChange(() => {
				refreshDirty(ctx.cwd);
				tui.requestRender();
			});

			const separator = theme.fg("dim", " │ ");
			const line = (label: string, parts: string[], width: number): string => {
				const prefix = theme.bold(theme.fg("accent", label.padEnd(9)));
				return truncateToWidth(prefix + parts.join(separator), width, theme.fg("dim", "…"));
			};
			const stateText = (): string => {
				const color = state === "ready" ? "success" : state === "working" ? "warning" : "error";
				return theme.bold(theme.fg(color, `${state === "working" ? "●" : state === "error" ? "×" : "✓"} ${state}`));
			};
			const contextText = (compact: boolean): string | undefined => {
				const context = ctx.getContextUsage();
				if (!context) return undefined;
				const percent = context.percent;
				const value = percent === null ? "?" : `${percent.toFixed(compact ? 0 : 1)}%`;
				const color = (percent ?? 0) > 90 ? "error" : (percent ?? 0) > 70 ? "warning" : "success";
				const details = compact
					? `ctx ${value}/${formatTokens(context.contextWindow)}`
					: `context ${percent === null ? "" : `${meter(percent, 12)} `}${value} / ${formatTokens(context.contextWindow)}`;
				return theme.fg(color, details);
			};

			return {
				dispose(): void {
					unsubscribe();
					requestRender = (): void => {};
				},
				invalidate(): void {},
				render(width: number): string[] {
					if (width <= 0) return [];
					const wide = width >= 100;
					const medium = width >= 68;
					const branch = footerData.getGitBranch();
					const model = ctx.model?.id;
					const thinking = ctx.thinkingLevel ?? (ctx.model?.reasoning ? "off" : undefined);
					const agent = [stateText()];
					if (model) agent.push(wide ? `model ${theme.bold(model)}` : theme.bold(model));
					if (thinking && wide) agent.push(`thinking ${thinking}`);
					if (branch && medium) agent.push(`git ${branch}${dirty ? theme.fg("warning", "*") : ""}`);
					if (medium) {
						const enabled = mcp ? mcp.servers.length - mcp.disabledCount : undefined;
						const mcpStatus = mcp
							? wide ? `MCP ${mcp.connectedCount} connected / ${enabled} enabled` : `MCP ${mcp.connectedCount}/${enabled}`
							: formatMcpFooterStatus(footerData.getExtensionStatuses().get("mcp") ?? "", wide);
						if (mcpStatus) agent.push(mcpStatus);
					}

					const totals = usageTotals(ctx);
					const subscription = isCodexProvider(ctx.model?.provider) || ctx.model?.provider === "kimi-coding";
					const session = [
						`${wide ? "input " : "↑"}${formatTokens(totals.usage.input)}`,
						`${wide ? "output " : "↓"}${formatTokens(totals.usage.output)}`,
					];
					const context = contextText(!wide);
					if (context) session.push(context);
					if (totals.cacheHit !== undefined && medium) session.push(`${wide ? "latest cache " : "cache "}${totals.cacheHit.toFixed(0)}%`);
					session.push(`${wide ? "cost " : ""}$${totals.usage.cost.total.toFixed(3)}${subscription ? theme.fg("accent", " (sub)") : ""}`);

					const providerDetails: string[] = [];
					const provider = ctx.model?.provider;
					if (isCodexProvider(provider)) {
						providerDetails.push(theme.bold("Codex"));
						const snapshot = globalThis.piCodexLimit;
						let weekly: UsageWindow | undefined;
						if (
							snapshot
							&& snapshot.provider === provider
							&& typeof snapshot.fetchedAt === "number"
							&& snapshot.fetchedAt >= runtimeStartedAt
						) {
							if (snapshot.fetchedAt !== attributedSnapshotFetchedAt) {
								attributedSnapshotFetchedAt = snapshot.fetchedAt;
								attributedAccountIdentity = activeAccount?.identity;
							}
							if (activeAccount?.identity && attributedAccountIdentity === activeAccount.identity) {
								weekly = snapshot.weekly;
							}
						}
						const used = weekly?.usedPercent === undefined ? undefined : clampPercent(weekly.usedPercent);
						const reset = formatReset(weekly?.resetAt);
						const label = activeAccount?.label;
						if (wide) {
							if (label) providerDetails.push(`account ${theme.bold(label)}`);
							if (used !== undefined) providerDetails.push(`weekly ${used.toFixed(0)}% used${reset ? ` · resets ${reset}` : ""}`);
						} else if (label || used !== undefined) {
							providerDetails.push(`${label ? `${theme.bold(label)} ` : ""}${used === undefined ? "" : `${used.toFixed(0)}%${reset ? `/${reset}` : ""}`}`.trim());
						}
					}

					const lines = [line("AGENT", agent, width), line("SESSION", session, width)];
					if (providerDetails.length > 0) lines.push(line("PROVIDER", providerDetails, width));
					return lines;
				},
			};
		});
	});

	pi.on("before_provider_request", () => {
		refreshActiveAccount();
		repaint();
	});
	pi.on("agent_start", () => {
		state = "working";
		repaint();
	});
	pi.on("message_end", (event) => {
		if (event.message.role !== "assistant") return;
		if (event.message.stopReason === "error" || event.message.stopReason === "aborted") state = "error";
		repaint();
	});
	pi.on("agent_end", (_event, ctx) => {
		if (state !== "error") state = "ready";
		refreshActiveAccount();
		refreshDirty(ctx.cwd);
		repaint();
	});
	pi.on("model_select", () => {
		refreshActiveAccount();
		repaint();
	});
	pi.on("thinking_level_select", () => repaint());
	pi.on("tool_execution_end", (_event, ctx) => refreshDirty(ctx.cwd));
	pi.on("user_bash", (event) => scheduleDirtyRefresh(event.cwd));
	pi.on("session_shutdown", () => {
		active = false;
		dirtyRefreshGeneration++;
		if (dirtyRefreshTimer) clearTimeout(dirtyRefreshTimer);
		dirtyRefreshTimer = undefined;
		requestRender = (): void => {};
	});
}
