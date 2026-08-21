export interface FooterRow {
	label: string;
	parts: string[];
}

const compactLabels: Record<string, string> = {
	WORKSPACE: "WS",
	AGENT: "AG",
	SESSION: "SESS",
	PROVIDER: "PROV",
};

export function compactFooterLabel(label: string): string {
	return compactLabels[label] ?? label;
}

export function formatFooterRowLabel(label: string, compact: boolean): string {
	const displayLabel = compact ? compactFooterLabel(label) : label;
	return displayLabel.padEnd(compact ? 5 : 10);
}

export interface SessionWidgetParts {
	before: string;
	name: string;
	after: string;
}

export function formatSessionWidget(sessionName: string | undefined): SessionWidgetParts | undefined {
	const name = sessionName?.trim();
	return name ? { before: "╭─ ", name, after: " ─╮" } : undefined;
}

export function getAlignedColumnWidths(
	rows: FooterRow[],
	measure: (value: string) => number = (value) => Array.from(value).length,
): number[] {
	const columnCount = Math.max(...rows.map((row) => row.parts.length));
	const columnWidths = Array.from({ length: columnCount }, (_, index) =>
		Math.max(...rows.map((row) => measure(row.parts[index] ?? ""))),
	);
	return columnWidths;
}
