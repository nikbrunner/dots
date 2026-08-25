export const DEFAULT_TOPBAR_SHORTCUT = "ctrl+shift+t";

export type TopbarView = "compact" | "expanded" | "hidden";

export function addSectionGaps(sections: string[][], gap: number): string[] {
	const lines: string[] = [];
	const visibleSections = sections.filter((section) => section.length > 0);
	for (const [index, section] of visibleSections.entries()) {
		if (index > 0) lines.push(...Array.from({ length: gap }, () => ""));
		lines.push(...section);
	}
	return lines;
}

export function layoutTopbarSections(
	sections: string[][],
	maxLines: number[],
	expanded: boolean,
	gap: number,
): string[] {
	const visibleSections = sections
		.map((section, index) => (expanded ? section : section.slice(0, maxLines[index] ?? section.length)))
		.filter((section) => section.length > 0);
	return addSectionGaps(visibleSections, gap);
}

export function clipTopbarLines(lines: string[], expanded: boolean, maxHeight: number): string[] {
	return expanded ? lines.slice(0, maxHeight) : lines;
}

export function nextTopbarView(view: TopbarView): TopbarView {
	if (view === "compact") return "expanded";
	if (view === "expanded") return "hidden";
	return "compact";
}

export function getTopbarOverlayOptions(maxHeight: number) {
	return {
		anchor: "top-center" as const,
		width: "100%" as const,
		maxHeight,
		nonCapturing: true,
	};
}
