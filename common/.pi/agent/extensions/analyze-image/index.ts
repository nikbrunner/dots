import { spawn } from "node:child_process";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import type { Message } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "@sinclair/typebox";

const supportedExtensions = new Set([".png", ".jpg", ".jpeg", ".gif", ".webp", ".bmp"]);
const configPath = path.join(os.homedir(), ".pi", "agent", "extensions", "analyze-image", "config.json");
const defaultSystemPrompt = [
	"You are an image analysis assistant.",
	"Read every image file listed in the task using the read tool before answering.",
	"Return only the requested analysis as plain text.",
].join("\n");

type Config = {
	defaultModel: string;
	systemPrompt: string;
	maxImagesPerCall: number;
};

function loadConfig(): Config {
	const raw = JSON.parse(fs.readFileSync(configPath, "utf8"));
	return {
		defaultModel: raw.defaultModel,
		systemPrompt: raw.systemPrompt ?? defaultSystemPrompt,
		maxImagesPerCall: raw.maxImagesPerCall ?? 10,
	};
}

function getText(messages: Message[]): string {
	for (let i = messages.length - 1; i >= 0; i--) {
		const content = messages[i]?.content;
		if (!Array.isArray(content)) continue;
		const text = content.find((part) => typeof part === "object" && part.type === "text");
		if (text && "text" in text) return text.text;
	}
	return "";
}

async function analyze(model: string, prompt: string, cwd: string, signal?: AbortSignal) {
	const tempDir = await fs.promises.mkdtemp(path.join(os.tmpdir(), "pi-analyze-image-"));
	const systemPromptPath = path.join(tempDir, "system-prompt.md");
	const messages: Message[] = [];
	let stdout = "";
	let stderr = "";

	try {
		await fs.promises.writeFile(systemPromptPath, loadConfig().systemPrompt, { mode: 0o600 });
		const args = [
			"--mode", "json", "-p", "--no-session", "--model", model, "--tools", "read",
			"--append-system-prompt", systemPromptPath, `Task: ${prompt}`,
		];
		const exitCode = await new Promise<number>((resolve, reject) => {
			const child = spawn("pi", args, { cwd, stdio: ["ignore", "pipe", "pipe"] });
			let buffer = "";
			child.stdout.on("data", (data: Buffer) => {
				buffer += data.toString();
				const lines = buffer.split("\n");
				buffer = lines.pop() ?? "";
				for (const line of lines) {
					try {
						const event = JSON.parse(line);
						if (event.type === "message_end" && event.message) messages.push(event.message);
					} catch { /* Ignore non-JSON output. */ }
				}
			});
			child.stderr.on("data", (data: Buffer) => { stderr += data.toString(); });
			child.on("error", reject);
			child.on("close", (code) => {
				if (buffer.trim()) {
					try {
						const event = JSON.parse(buffer);
						if (event.type === "message_end" && event.message) messages.push(event.message);
					} catch { /* Ignore non-JSON output. */ }
				}
				stdout = getText(messages);
				resolve(code ?? 1);
			});
			if (signal) {
				const abort = () => child.kill("SIGTERM");
				if (signal.aborted) abort();
				else signal.addEventListener("abort", abort, { once: true });
			}
		});
		return { exitCode, output: stdout, stderr };
	} finally {
		await fs.promises.rm(tempDir, { recursive: true, force: true });
	}
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "analyze_image",
		label: "Analyze Image",
		description: "Analyze local images with a vision-capable subagent.",
		parameters: Type.Object({
			images: Type.Array(Type.String(), { description: "Local image paths" }),
			question: Type.String({ description: "Question about the images" }),
			model: Type.Optional(Type.String({ description: "Vision model override" })),
		}),
		async execute(_id, params, signal, _onUpdate, ctx) {
			const config = loadConfig();
			if (params.images.length === 0 || params.images.length > config.maxImagesPerCall) {
				return { content: [{ type: "text", text: `Expected 1-${config.maxImagesPerCall} images.` }], isError: true, details: {} };
			}
			const images = params.images.map((image: string) => {
				const absolutePath = path.resolve(ctx.cwd, image);
				if (!fs.existsSync(absolutePath) || !supportedExtensions.has(path.extname(absolutePath).toLowerCase())) {
					throw new Error(`Invalid image path: ${absolutePath}`);
				}
				return absolutePath;
			});
			const prompt = `Read and analyze these image files:\n${images.map((image) => `- ${image}`).join("\n")}\n\nQuestion: ${params.question}`;
			const result = await analyze(params.model ?? config.defaultModel, prompt, ctx.cwd, signal);
			if (result.exitCode !== 0 || !result.output) {
				return { content: [{ type: "text", text: `Image analysis failed: ${result.stderr || "Subagent returned no analysis."}` }], isError: true, details: {} };
			}
			return { content: [{ type: "text", text: result.output }], details: {} };
		},
	});
}
