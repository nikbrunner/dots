import { Text } from "@earendil-works/pi-tui";
import { addSectionGaps, alignTopbarLabel, getSpinnerFrame, getTopbarColor } from "../../lib/layout";
import type { TopbarProvider } from "../types";

const conversationStateProvider: TopbarProvider = {
	id: "conversation-state",
	render({ currentState, focus, focusPending, summaryPending, theme }) {
		if (!focus && !currentState) return undefined;

		const lines: string[] = [];
		if (focus) {
			const focusColor = getTopbarColor("focus");
			const value = focusPending ? theme.fg(focusColor, getSpinnerFrame(Date.now())) : theme.fg(focusColor, focus);
			lines.push(`${theme.bold(alignTopbarLabel("Focus:"))} ${value}`);
		}
		if (currentState) {
			const nowColor = getTopbarColor("now");
			const value = summaryPending
				? theme.fg(nowColor, getSpinnerFrame(Date.now()))
				: theme.fg(nowColor, currentState);
			lines.push(`${theme.bold(alignTopbarLabel("Now:"))} ${value}`);
		}
		return new Text(addSectionGaps(lines.map((line) => [line]), 1).join("\n"), 0, 0);
	},
};

export default conversationStateProvider;
