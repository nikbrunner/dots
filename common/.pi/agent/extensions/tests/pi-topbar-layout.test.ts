import {
	addSectionGaps,
	clipTopbarLines,
	DEFAULT_TOPBAR_SHORTCUT,
	applyTopbarPadding,
	getSpinnerFrame,
	getTopbarColor,
	getTopbarContentMaxHeight,
	getTopbarValueIndent,	alignTopbarLabel,
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

Deno.test("anchors wrapped values after the shared label column", () => {
	if (getTopbarValueIndent("Focus:") !== 7 || getTopbarValueIndent("Now:") !== 7) {
		throw new Error("Expected both values to share the same continuation indent");
	}
});

Deno.test("reserves one row only when the bottom border is enabled", () => {
	if (getTopbarContentMaxHeight(20, true) !== 19 || getTopbarContentMaxHeight(20, false) !== 20) {
		throw new Error("Unexpected content height for border setting");
	}
});

Deno.test("applies independent top, right, bottom, and left padding", () => {
	const padded = applyTopbarPadding(["content"], { top: 1, right: 2, bottom: 1, left: 3 });
	const expected = ["", "   content  ", ""];
	if (JSON.stringify(padded) !== JSON.stringify(expected)) {
		throw new Error(`Unexpected padded lines: ${JSON.stringify(padded)}`);
	}
});

Deno.test("keeps topbar color roles distinct", () => {
	if (getTopbarColor("session") !== "warning") {
		throw new Error("Expected session to use the terminal warning color");
	}
	if (getTopbarColor("session") === getTopbarColor("focus")) {
		throw new Error("Expected session and focus to use different colors");
	}
	if (getTopbarColor("focus") === getTopbarColor("now")) {
		throw new Error("Expected focus and now to use different colors");
	}
});

Deno.test("aligns topbar labels to the same value column", () => {
	if (alignTopbarLabel("Focus:") !== "Focus:" || alignTopbarLabel("Now:") !== "Now:  ") {
		throw new Error("Expected labels to share a fixed width");
	}
});

Deno.test("cycles spinner frames predictably", () => {
	if (getSpinnerFrame(0) !== "⠋" || getSpinnerFrame(80) !== "⠙") {
		throw new Error("Unexpected spinner frame");
	}
});

Deno.test("cycles the topbar view state", () => {
	const states: TopbarView[] = ["compact", "expanded", "hidden", "compact"];
	const result = states.slice(0, -1).map(nextTopbarView);

	if (JSON.stringify(result) !== JSON.stringify(states.slice(1))) {
		throw new Error(`Unexpected view cycle: ${JSON.stringify(result)}`);
	}
});
