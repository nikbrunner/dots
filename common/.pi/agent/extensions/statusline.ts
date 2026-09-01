import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { execFile } from "node:child_process";
import { homedir } from "node:os";
import { resolve } from "node:path";
import { stripVTControlCharacters } from "node:util";
import {
	formatFooterRowLabel,
	formatUsageFooterStatus,
	getAlignedColumnWidths,
	type FooterRow,
} from "./lib/statusline-layout";
import { getActiveAccountLabelFromStatus } from "./lib/statusline-accounts";
const MCP_STATUS_CHANNEL = "pi-mcp-adapter/status/v1";

interface Usage {
	input: number;
	output: number;
	cacheRead: number;
	cacheWrite: number;
	cost: { total: number };
}

interface McpStatusSnapshot {
	version: 1;
	servers: ReadonlyArray<{ disabled: boolean }>;
	connectedCount: number;
	disabledCount: number;
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

function formatCwd(cwd: string): string {
	const home = homedir();
	if (cwd === home) return "~";
	return cwd.startsWith(`${home}/`) ? `~${cwd.slice(home.length)}` : cwd;
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

function formatMcpFooterStatus(status: string): string | undefined {
	const plain = sanitizeMcpStatus(status);
	if (!plain) return undefined;

	const compact = /^MCP (\d+)\/(\d+)$/.exec(plain);
	if (compact) {
		const connected = Number(compact[1]);
		const enabled = Number(compact[2]);
		if (Number.isSafeInteger(connected) && Number.isSafeInteger(enabled) && connected <= enabled) {
			return plain;
		}
	}

	const full = /^MCP: (\d+) servers? enabled(?: \((\d+) connected\))?(?: \((\d+) disabled\))?$/.exec(plain);
	if (full) {
		const enabled = Number(full[1]);
		const connected = Number(full[2] ?? 0);
		if (Number.isSafeInteger(connected) && Number.isSafeInteger(enabled) && connected <= enabled) {
			return `MCP ${connected}/${enabled}`;
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

export default function (pi: ExtensionAPI): void {
	let active = true;
	let requestRender = (): void => {};
	let state: "ready" | "working" | "error" = "ready";
	let dirty = false;
	let gitStatus: GitStatus | undefined;
	let linkedWorktree = false;
	let dirtyRefreshGeneration = 0;
	let dirtyRefreshTimer: ReturnType<typeof setTimeout> | undefined;
	let mcp: McpStatusSnapshot | undefined;

	const repaint = (): void => requestRender();
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
		refreshDirty(ctx.cwd);
		refreshWorktreeState(ctx.cwd);

		ctx.ui.setFooter((tui, theme, footerData) => {
			requestRender = (): void => tui.requestRender();
			const unsubscribe = footerData.onBranchChange(() => {
				refreshDirty(ctx.cwd);
				tui.requestRender();
			});

			const separator = theme.fg("dim", " │ ");
			const rawLine = ({ label, parts }: FooterRow): string =>
				theme.bold(theme.fg("warning", formatFooterRowLabel(label))) + parts.join(separator);
			const renderLine = (row: FooterRow, width: number): string =>
				truncateToWidth(rawLine(row), width, theme.fg("dim", "…"));
			const renderRows = (rows: FooterRow[], width: number): string[] => {
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
					truncateToWidth(rawLine(row), width, theme.fg("dim", "…")),
				);
			};
			const indicator = (label: string): string => theme.fg("warning", `${label} `);
			const stateText = (): string => {
				const color = state === "ready" ? "success" : state === "working" ? "warning" : "error";
				return theme.bold(theme.fg(color, `${state === "working" ? "●" : state === "error" ? "×" : "✓"} ${state}`));
			};
			const contextText = (): string | undefined => {
				const context = ctx.getContextUsage();
				if (!context) return undefined;
				const percent = context.percent;
				const value = percent === null ? "?" : `${percent.toFixed(0)}%`;
				const color = (percent ?? 0) > 90 ? "error" : (percent ?? 0) > 70 ? "warning" : "success";
				return indicator("ctx") + theme.fg(color, `${value}/${formatTokens(context.contextWindow)}`);
			};

			return {
				dispose(): void {
					unsubscribe();
					requestRender = (): void => {};
				},
				invalidate(): void {},
				render(width: number): string[] {
					if (width <= 0) return [];
					const branch = footerData.getGitBranch();
					const workspace = [`${indicator("dir")}${theme.bold(formatCwd(ctx.cwd))}`];
					const git: string[] = [];
					if (branch) git.push(`${indicator("br.")}${branch}${dirty ? theme.fg("warning", "*") : ""}`);
					if (branch && gitStatus) {
						const statusParts = [
							gitStatus.added > 0 ? theme.fg("success", `+${gitStatus.added}`) : undefined,
							gitStatus.changed > 0 ? theme.fg("warning", `~${gitStatus.changed}`) : undefined,
							gitStatus.deleted > 0 ? theme.fg("error", `-${gitStatus.deleted}`) : undefined,
							gitStatus.untracked > 0 ? theme.fg("accent", `?${gitStatus.untracked}`) : undefined,
						].filter((part): part is string => part !== undefined);
						git.push(`${indicator("st.")}${statusParts.length > 0 ? statusParts.join(" ") : theme.fg("success", "clean")}`);
					}
					if (linkedWorktree) git.push(theme.fg("muted", "worktree"));

					const model = ctx.model?.id;
					const thinking = ctx.thinkingLevel ?? (ctx.model?.reasoning ? "off" : undefined);
					const agent = [stateText()];
					if (model) agent.push(`${indicator("mdl")}${theme.bold(model)}`);
					if (thinking) agent.push(`${indicator("thk")}${theme.fg("dim", thinking)}`);
					const enabled = mcp ? mcp.servers.length - mcp.disabledCount : undefined;
					const mcpStatus = mcp
						? `MCP ${mcp.connectedCount}/${enabled}`
						: formatMcpFooterStatus(footerData.getExtensionStatuses().get("mcp") ?? "");
					if (mcpStatus) {
						const color = mcp
							? mcp.connectedCount === enabled ? "success" : mcp.connectedCount === 0 ? "error" : "warning"
							: "accent";
						const value = mcpStatus.replace(/^MCP:?\s*/, "");
						agent.push(indicator("mcp") + theme.fg(color, value));
					}

					const totals = usageTotals(ctx);
					const subscription = isCodexProvider(ctx.model?.provider) || ctx.model?.provider === "kimi-coding";
					const session = [
						`${indicator("↑")}${formatTokens(totals.usage.input)}`,
						`${indicator("↓")}${formatTokens(totals.usage.output)}`,
					];
					const context = contextText();
					if (context) session.push(context);
					const cache = totals.cacheHit === undefined
						? undefined
						: indicator("hit") + `${totals.cacheHit.toFixed(0)}%`;
					if (cache) session.push(cache);
					session.push(`${indicator("$")}${totals.usage.cost.total.toFixed(3)}${subscription ? theme.fg("dim", " (sub)") : ""}`);

					const providerDetails: string[] = [];
					const provider = ctx.model?.provider;
					if (isCodexProvider(provider)) {
						const label = getActiveAccountLabelFromStatus(
							footerData.getExtensionStatuses().get("accounts") ?? "",
						);
						const usage = formatUsageFooterStatus(footerData.getExtensionStatuses().get("usage") ?? "");
						providerDetails.push(theme.bold(`Codex${label ? ` [${label}]` : ""}`));
						if (usage) providerDetails.push(theme.fg("accent", usage));
					}

					const rows: FooterRow[] = [];
					if (git.length > 0) rows.push({ label: "GIT", parts: git });
					rows.push(
						{ label: "AGENT", parts: agent },
						{ label: "SESSION", parts: session },
					);
					if (providerDetails.length > 0) rows.push({ label: "PROVIDER", parts: providerDetails });
					return [renderLine({ label: "WORKSPACE", parts: [workspace.join("  ")] }, width), ...renderRows(rows, width)];
				},
			};
		});
	});

	pi.on("session_info_changed", () => {
		repaint();
	});
	pi.on("before_provider_request", () => repaint());
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
		refreshDirty(ctx.cwd);
		repaint();
	});
	pi.on("model_select", () => repaint());
	pi.on("thinking_level_select", () => repaint());
	pi.on("tool_execution_end", (_event, ctx) => refreshDirty(ctx.cwd));
	pi.on("user_bash", (event) => scheduleDirtyRefresh(event.cwd));
	pi.on("session_shutdown", (_event, _ctx) => {
		active = false;
		dirtyRefreshGeneration++;
		if (dirtyRefreshTimer) clearTimeout(dirtyRefreshTimer);
		dirtyRefreshTimer = undefined;
		requestRender = (): void => {};
	});
}
