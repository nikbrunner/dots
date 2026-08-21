import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { execFile } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join, resolve } from "node:path";
import { stripVTControlCharacters } from "node:util";
import {
	formatFooterRowLabel,
	formatSessionWidget,
	getAlignedColumnWidths,
	type FooterRow,
} from "./lib/statusline-layout";

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

interface GitStatus {
	added: number;
	changed: number;
	deleted: number;
	untracked: number;
}

function parseGitStatus(output: string): GitStatus {
	const status: GitStatus = { added: 0, changed: 0, deleted: 0, untracked: 0 };
	for (const line of output.split("\n")) {
		const code = line.slice(0, 2);
		if (code === "??") status.untracked++;
		else if (code.includes("D")) status.deleted++;
		else if (code.includes("A")) status.added++;
		else if (code.length === 2) status.changed++;
	}
	return status;
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

function formatCwd(cwd: string): string {
	const home = homedir();
	if (cwd === home) return "~";
	return cwd.startsWith(`${home}/`) ? `~${cwd.slice(home.length)}` : cwd;
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
	let updateSessionWidget = (): void => {};
	let state: "ready" | "working" | "error" = "ready";
	let dirty = false;
	let gitStatus: GitStatus | undefined;
	let linkedWorktree = false;
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
		gitStatus = undefined;
		execFile("git", ["status", "--porcelain", "--untracked-files=normal"], { cwd }, (error, stdout) => {
			if (!active || generation !== dirtyRefreshGeneration) return;
			gitStatus = error ? undefined : parseGitStatus(stdout);
			dirty = gitStatus !== undefined && Object.values(gitStatus).some((count) => count > 0);
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
	const refreshWorktreeState = (cwd: string): void => {
		execFile("git", ["rev-parse", "--git-dir", "--git-common-dir"], { cwd }, (error, stdout) => {
			if (!active) return;
			const [gitDir, commonDir] = stdout.trim().split("\n");
			linkedWorktree = !error
				&& gitDir !== undefined
				&& commonDir !== undefined
				&& resolve(cwd, gitDir) !== resolve(cwd, commonDir);
			repaint();
		});
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
		refreshWorktreeState(ctx.cwd);

		const setSessionWidget = (): void => {
			if (ctx.mode !== "tui") return;
			ctx.ui.setHeader(undefined);
			ctx.ui.setWidget("session-name", (_tui, theme) => ({
				invalidate(): void {},
				render(width: number): string[] {
					const parts = formatSessionWidget(pi.getSessionName());
					if (!parts || width <= 0) return [];
					const frameBefore = theme.fg("muted", parts.before);
					const name = theme.bold(theme.fg("accent", parts.name));
					const frameAfter = theme.fg("muted", parts.after);
					return [truncateToWidth(frameBefore + name + frameAfter, width)];
				},
			}), { placement: "aboveEditor" });
		};
		updateSessionWidget = setSessionWidget;
		setSessionWidget();

		ctx.ui.setFooter((tui, theme, footerData) => {
			requestRender = (): void => tui.requestRender();
			const unsubscribe = footerData.onBranchChange(() => {
				refreshDirty(ctx.cwd);
				tui.requestRender();
			});

			const separator = theme.fg("dim", " │ ");
			const rawLine = ({ label, parts }: FooterRow, compact = false): string =>
				theme.bold(theme.fg("warning", formatFooterRowLabel(label, compact))) + parts.join(separator);
			const renderLine = (row: FooterRow, width: number, compact = false): string =>
				truncateToWidth(rawLine(row, compact), width, theme.fg("dim", "…"));
			const renderRows = (rows: FooterRow[], width: number): string[] => {
				const compact = width < 110;
				const columnWidths = getAlignedColumnWidths(rows, visibleWidth);
				const aligned = rows.map((row) => ({
					...row,
					parts: row.parts.map((part, index) =>
						index === row.parts.length - 1
							? part
							: part + " ".repeat(columnWidths[index] - visibleWidth(part)),
					),
				}));
				return aligned.map((row) =>
					truncateToWidth(rawLine(row, compact), width, theme.fg("dim", "…")),
				);
			};
			const indicator = (label: string, compactLabel = label, compact = false): string =>
				theme.fg("warning", `${compact ? compactLabel : label} `);
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
					? `${value}/${formatTokens(context.contextWindow)}`
					: `${percent === null ? "" : `${meter(percent, 12)} `}${value} / ${formatTokens(context.contextWindow)}`;
				return indicator("context", "ctx", compact) + theme.fg(color, details);
			};

			return {
				dispose(): void {
					unsubscribe();
					requestRender = (): void => {};
				},
				invalidate(): void {},
				render(width: number): string[] {
					if (width <= 0) return [];
					const wide = width >= 110;
					const compact = !wide;
					const medium = width >= 68;
					const branch = footerData.getGitBranch();
					const workspace = [`${indicator("cwd", "dir", compact)}${theme.bold(formatCwd(ctx.cwd))}`];
					const git: string[] = [];
					if (branch) git.push(`${indicator("branch", "br", compact)}${branch}${dirty ? theme.fg("warning", "*") : ""}`);
					if (branch && gitStatus) {
						const statusParts = [
							gitStatus.add > 0 ? theme.fg("success", `+${gitStatus.add}`) : undefined,
							gitStatus.changed > 0 ? theme.fg("warning", `~${gitStatus.changed}`) : undefined,
							gitStatus.deleted > 0 ? theme.fg("error", `-${gitStatus.deleted}`) : undefined,
							gitStatus.untracked > 0 ? theme.fg("accent", `?${gitStatus.untracked}`) : undefined,
						].filter((part): part is string => part !== undefined);
						git.push(`${indicator("status", "git", compact)}${statusParts.length > 0 ? statusParts.join(" ") : theme.fg("success", "clean")}`);
					}
					if (linkedWorktree) git.push(theme.fg("muted", "worktree"));

					const model = ctx.model?.id;
					const thinking = ctx.thinkingLevel ?? (ctx.model?.reasoning ? "off" : undefined);
					const agent = [stateText()];
					if (model) agent.push(`${indicator("model", "mdl", compact)}${theme.bold(model)}`);
					if (thinking) {
						agent.push(`${indicator("thinking", "th", compact)}${theme.fg("dim", thinking)}`);
					}
					if (medium) {
						const enabled = mcp ? mcp.servers.length - mcp.disabledCount : undefined;
						const mcpStatus = mcp
							? wide ? `MCP ${mcp.connectedCount} connected / ${enabled} enabled` : `MCP ${mcp.connectedCount}/${enabled}`
							: formatMcpFooterStatus(footerData.getExtensionStatuses().get("mcp") ?? "", wide);
						if (mcpStatus) {
							const color = mcp
								? mcp.connectedCount === enabled ? "success" : mcp.connectedCount === 0 ? "error" : "warning"
								: "accent";
							const value = mcpStatus.replace(/^MCP:?\s*/, "");
							agent.push(indicator("MCP", "mcp", compact) + theme.fg(color, value));
						}
					}

					const totals = usageTotals(ctx);
					const subscription = isCodexProvider(ctx.model?.provider) || ctx.model?.provider === "kimi-coding";
					const session = [
						`${indicator(wide ? "input" : "↑")}${formatTokens(totals.usage.input)}`,
						`${indicator(wide ? "output" : "↓")}${formatTokens(totals.usage.output)}`,
					];
					const context = contextText(compact);
					if (context) session.push(context);
					const cache = totals.cacheHit === undefined
						? undefined
						: indicator("latest cache", "hit", compact) + `${totals.cacheHit.toFixed(0)}%`;
					if (medium && cache) session.push(cache);
					session.push(`${indicator(wide ? "cost" : "$")}${totals.usage.cost.total.toFixed(3)}${subscription ? theme.fg("dim", " (sub)") : ""}`);

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
						const quotaColor = (used ?? 0) >= 90 ? "error" : (used ?? 0) >= 70 ? "warning" : "success";
						if (wide) {
							if (label) providerDetails.push(`${indicator("account")}${theme.bold(label)}`);
							if (used !== undefined) providerDetails.push(`${indicator("weekly")}${theme.fg(quotaColor, `${used.toFixed(0)}% used`)}`);
							if (reset) providerDetails.push(indicator("resets") + theme.fg("dim", reset));
						} else {
							if (label) providerDetails.push(indicator("account", "acct", compact) + theme.bold(label));
							if (used !== undefined) providerDetails.push(indicator("weekly", "wk", compact) + theme.fg(quotaColor, `${used.toFixed(0)}%`));
							if (reset) providerDetails.push(indicator("resets", "rst", compact) + theme.fg("dim", reset));
						}
					}

					const rows: FooterRow[] = [];
					if (git.length > 0) rows.push({ label: "GIT", parts: git });
					rows.push(
						{ label: "AGENT", parts: agent },
						{ label: "SESSION", parts: session },
					);
					if (providerDetails.length > 0) rows.push({ label: "PROVIDER", parts: providerDetails });
					return [renderLine({ label: "WORKSPACE", parts: [workspace.join("  ")] }, width, compact), ...renderRows(rows, width)];
				},
			};
		});
	});

	pi.on("session_info_changed", () => {
		updateSessionWidget();
		repaint();
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
	pi.on("session_shutdown", (_event, ctx) => {
		if (ctx.mode === "tui") {
			ctx.ui.setHeader(undefined);
			ctx.ui.setWidget("session-name", undefined);
		}
		updateSessionWidget = (): void => {};
		active = false;
		dirtyRefreshGeneration++;
		if (dirtyRefreshTimer) clearTimeout(dirtyRefreshTimer);
		dirtyRefreshTimer = undefined;
		requestRender = (): void => {};
	});
}
