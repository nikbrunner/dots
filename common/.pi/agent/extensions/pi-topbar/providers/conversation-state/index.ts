import { wrapTextWithAnsi } from "@earendil-works/pi-tui";
import {
	alignTopbarLabel,
	getSpinnerFrame,
	getTopbarColor,
	getTopbarValueIndent,
	type TopbarLine,
} from "../../lib/layout";
import type { TopbarProvider } from "../types";

function renderStateLines(lines: TopbarLine[], width: number): string[] {
	const renderedLines: string[] = [];
	for (const [index, line] of lines.entries()) {
		if (index > 0) renderedLines.push("");
		const valueLines = wrapTextWithAnsi(line.value, Math.max(1, width - getTopbarValueIndent(line.label)));
		renderedLines.push(`${line.renderedLabel} ${valueLines[0] ?? ""}`);
		renderedLines.push(
			...valueLines.slice(1).map((valueLine) => `${" ".repeat(getTopbarValueIndent(line.label))}${valueLine}`),
		);
	}
	return renderedLines;
}

const conversationStateProvider: TopbarProvider = {
	id: "conversation-state",
	render({ currentState, focus, focusPending, summaryPending, theme }) {
		if (!focus && !currentState) return undefined;

		const lines: TopbarLine[] = [];
		if (focus) {
			const focusColor = getTopbarColor("focus");
			const value = focusPending ? theme.fg(focusColor, getSpinnerFrame(Date.now())) : theme.fg(focusColor, focus);
			lines.push({ label: "Focus:", renderedLabel: theme.bold(alignTopbarLabel("Focus:")), value });
		}
		if (currentState) {
			const nowColor = getTopbarColor("now");
			const value = summaryPending
				? theme.fg(nowColor, getSpinnerFrame(Date.now()))
				: theme.fg(nowColor, currentState);
			lines.push({ label: "Now:", renderedLabel: theme.bold(alignTopbarLabel("Now:")), value });
		}
		return {
			render: (width: number): string[] => renderStateLines(lines, width),
			invalidate: (): void => {},
		};
	},
};

export default conversationStateProvider;
