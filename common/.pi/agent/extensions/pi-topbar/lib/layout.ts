export const DEFAULT_TOPBAR_SHORTCUT = "ctrl+shift+t";
const SPINNER_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"] as const;
const TOPBAR_LABEL_WIDTH = 6;

export type TopbarView = "compact" | "expanded" | "hidden";

export interface TopbarPadding {
	top: number;
	right: number;
	bottom: number;
	left: number;
}

export interface TopbarLine {
	label: string;
	renderedLabel: string;
	value: string;
}

export function applyTopbarPadding(lines: string[], padding: TopbarPadding): string[] {
	const horizontalPadding = (line: string): string =>
		line.length > 0 ? `${" ".repeat(padding.left)}${line}${" ".repeat(padding.right)}` : line;
	return [
		...Array.from({ length: padding.top }, () => ""),
		...lines.map(horizontalPadding),
		...Array.from({ length: padding.bottom }, () => ""),
	];
}

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

type TopbarColorRole = "session" | "focus" | "now";
type TopbarColor = "accent" | "success" | "warning";

const TOPBAR_COLORS: Record<TopbarColorRole, TopbarColor> = {
	session: "warning",
	focus: "accent",
	now: "success",
};

export function getTopbarColor(role: TopbarColorRole): TopbarColor {
	return TOPBAR_COLORS[role];
}

export function getTopbarContentMaxHeight(maxHeight: number, borderBottom: boolean): number {
	return Math.max(0, maxHeight - (borderBottom ? 1 : 0));
}

export function alignTopbarLabel(label: string): string {
	return label.padEnd(TOPBAR_LABEL_WIDTH);
}

export function getTopbarValueIndent(label: string): number {
	return alignTopbarLabel(label).length + 1;
}

export function getSpinnerFrame(now: number): string {
	return SPINNER_FRAMES[Math.floor(now / 80) % SPINNER_FRAMES.length];
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
