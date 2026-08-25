import {
	addSectionGaps,
	clipTopbarLines,
	DEFAULT_TOPBAR_SHORTCUT,
	layoutTopbarSections,
	nextTopbarView,
	type TopbarView,
} from "../pi-topbar/lib/layout.ts";

Deno.test("adds one blank row between non-empty provider sections", () => {
	const lines = addSectionGaps([["Session"], ["First response", "Second response"]], 1);

	if (JSON.stringify(lines) !== JSON.stringify(["Session", "", "First response", "Second response"])) {
		throw new Error(`Unexpected section layout: ${JSON.stringify(lines)}`);
	}
});

Deno.test("keeps a configurable default shortcut", () => {
	if (DEFAULT_TOPBAR_SHORTCUT !== "ctrl+shift+t") {
		throw new Error(`Unexpected default shortcut: ${DEFAULT_TOPBAR_SHORTCUT}`);
	}
});

Deno.test("derives compact height from providers and caps expanded output globally", () => {
	const sections = [["Session"], ["one", "two", "three", "four"]];
	const maxLines = [1, 2];

	const compact = clipTopbarLines(layoutTopbarSections(sections, maxLines, false, 1), false, 3);
	if (JSON.stringify(compact) !== JSON.stringify(["Session", "", "one", "two"])) {
		throw new Error(`Unexpected compact layout: ${JSON.stringify(compact)}`);
	}

	const expanded = clipTopbarLines(layoutTopbarSections(sections, maxLines, true, 1), true, 20);
	if (JSON.stringify(expanded) !== JSON.stringify(["Session", "", "one", "two", "three", "four"])) {
		throw new Error(`Unexpected expanded layout: ${JSON.stringify(expanded)}`);
	}

	const clipped = clipTopbarLines(layoutTopbarSections(sections, maxLines, true, 1), true, 4);
	if (JSON.stringify(clipped) !== JSON.stringify(["Session", "", "one", "two"])) {
		throw new Error(`Unexpected clipped layout: ${JSON.stringify(clipped)}`);
	}
});

Deno.test("cycles the topbar view state", () => {
	const states: TopbarView[] = ["compact", "expanded", "hidden", "compact"];
	const result = states.slice(0, -1).map(nextTopbarView);

	if (JSON.stringify(result) !== JSON.stringify(states.slice(1))) {
		throw new Error(`Unexpected view cycle: ${JSON.stringify(result)}`);
	}
});
