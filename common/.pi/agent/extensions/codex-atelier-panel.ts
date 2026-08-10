import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const CHANNEL = "pi-atelier:sidebar-panels";
const SOURCE = "codex-atelier-panel";
const PANEL_ID = "codex:limits" as const;

interface UsageWindow {
	usedPercent?: number;
	resetAt?: number;
}

interface UsageSnapshot {
	provider?: string;
	planType?: string;
	email?: string;
	weekly?: UsageWindow;
	fetchedAt?: number;
}

declare global {
	var piCodexLimit: UsageSnapshot | undefined;
}

interface CodexCredential {
	accountId?: string;
	access?: string;
	refresh?: string;
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
		if (typeof value !== "object" || value === null || Array.isArray(value)) return undefined;
		return value as Record<string, unknown>;
	} catch {
		return undefined;
	}
}

function readCredential(value: unknown): CodexCredential | undefined {
	if (typeof value !== "object" || value === null || Array.isArray(value)) return undefined;
	const record = value as Record<string, unknown>;
	return {
		...(typeof record.accountId === "string" ? { accountId: record.accountId } : {}),
		...(typeof record.access === "string" ? { access: record.access } : {}),
		...(typeof record.refresh === "string" ? { refresh: record.refresh } : {}),
	};
}

function readSavedCredential(value: unknown): CodexCredential | undefined {
	if (typeof value !== "object" || value === null || Array.isArray(value) || !("credential" in value)) return undefined;
	return readCredential(value.credential);
}

function getActiveCredential(): CodexCredential | undefined {
	const auth = readJson(join(getAgentDir(), "auth.json"));
	return readCredential(auth?.["openai-codex"]);
}

function getCurrentAccountLabel(): string | undefined {
	const active = getActiveCredential();
	if (!active) return undefined;

	const store = readJson(join(getAgentDir(), "codex-accounts.json"));
	const accounts = store?.accounts;
	if (typeof accounts !== "object" || accounts === null || Array.isArray(accounts)) return undefined;

	for (const [label, value] of Object.entries(accounts)) {
		const account = readSavedCredential(value);
		if (active.accountId && account?.accountId === active.accountId) return label;
	}
	for (const [label, value] of Object.entries(accounts)) {
		const account = readSavedCredential(value);
		if (active.refresh && account?.refresh === active.refresh) return label;
	}
	return undefined;
}

function isCodexProvider(provider: string | undefined): boolean {
	return /^openai-codex(?:-\d+)?$/.test(provider ?? "");
}

function getTokenMetadata(token: string | undefined): { planType?: string; email?: string } {
	if (!token) return {};
	try {
		const payload = JSON.parse(Buffer.from(token.split(".")[1] ?? "", "base64url").toString("utf8")) as Record<string, unknown>;
		const auth = payload["https://api.openai.com/auth"] as Record<string, unknown> | undefined;
		const profile = payload["https://api.openai.com/profile"] as Record<string, unknown> | undefined;
		return {
			...(typeof auth?.chatgpt_plan_type === "string" ? { planType: auth.chatgpt_plan_type } : {}),
			...(typeof profile?.email === "string" ? { email: profile.email } : {}),
		};
	} catch {
		return {};
	}
}

function maskEmail(email: string): string {
	const [local, domain] = email.split("@");
	if (!local || !domain) return "***";
	const [domainName, ...suffix] = domain.split(".");
	return `${local.slice(0, 2)}***@${domainName?.[0] ?? ""}***${domainName?.slice(-1) ?? ""}${suffix.length ? `.${suffix.join(".")}` : ""}`;
}

function boldText(text: string): string {
	return [...text].map((character) => {
		const code = character.codePointAt(0);
		if (code === undefined) return character;
		if (code >= 65 && code <= 90) return String.fromCodePoint(code + 0x1d400 - 65);
		if (code >= 97 && code <= 122) return String.fromCodePoint(code + 0x1d41a - 97);
		if (code >= 48 && code <= 57) return String.fromCodePoint(code + 0x1d7ce - 48);
		return character;
	}).join("");
}

function formatUsageRow(label: string, value: string): string {
	return `${label.padEnd(8, "⠀")} ${value}`;
}

function renderProgressBar(usedPercent: number): string {
	const width = 12;
	const filled = Math.round((usedPercent / 100) * width);
	return `[${"█".repeat(filled)}${"·".repeat(width - filled)}]`;
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
	const accountLabel = isCodexProvider(provider) ? getCurrentAccountLabel() : undefined;
	const metadata = getTokenMetadata(getActiveCredential()?.access);
	const plan = snapshot?.planType ?? metadata.planType ?? "unknown";
	const email = snapshot?.email ?? metadata.email;
	const accountRow = { text: formatUsageRow("Account:", `${accountLabel ? boldText(accountLabel) : "not saved"} (${plan})`), role: "accent" as const };
	const rows = !isCodexProvider(provider)
		? [{ text: "Only available for openai-codex", role: "muted" as const }]
		: snapshot
			? [
					accountRow,
					{ text: formatUsageRow("Email:", email ? maskEmail(email) : "unknown"), role: "primary" as const },
					{
						text: formatUsageRow(
							"Limit:",
							snapshot.weekly?.usedPercent === undefined
								? "unavailable"
								: `${renderProgressBar(Math.max(0, Math.min(100, snapshot.weekly.usedPercent)))} ${Math.round(Math.max(0, Math.min(100, snapshot.weekly.usedPercent)))}%`,
						),
						role: "primary" as const,
					},
					{
						text: formatUsageRow("Reset:", formatResetDetails(snapshot.weekly?.resetAt)),
						role: "muted" as const,
					},
					{
						text: formatUsageRow("Updated:", formatFetched(snapshot.fetchedAt)),
						role: "muted" as const,
					},
			  ]
			: [accountRow, { text: "Waiting for Codex usage data", role: "muted" as const }];

	pi.events.emit(CHANNEL, {
		version: 1,
		type: "register",
		source: SOURCE,
		revision,
		panel: {
			id: PANEL_ID,
			title: "CODEX",
			rows,
			role: "cache",
		},
		...(requestId ? { requestId } : {}),
	});
}

function formatFetched(timestamp: number | undefined): string {
	if (timestamp === undefined) return "unknown";
	return new Date(timestamp).toLocaleString();
}

function formatResetDetails(resetAt: number | undefined): string {
	if (resetAt === undefined) return "unknown";
	return `${formatReset(resetAt)} (${formatFetched(resetAt * 1000)})`;
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
