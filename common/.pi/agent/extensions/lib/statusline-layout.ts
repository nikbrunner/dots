import { stripVTControlCharacters } from "node:util";

export interface FooterRow {
	label: string;
	parts: string[];
}

const compactLabels: Record<string, string> = {
	WORKSPACE: "WRK",
	AGENT: "AGT",
	SESSION: "SES",
	PROVIDER: "PRV",
};

export function compactFooterLabel(label: string): string {
	return compactLabels[label] ?? label;
}

export function formatFooterRowLabel(label: string): string {
	return compactFooterLabel(label).padEnd(5);
}

export function formatUsageFooterStatus(status: string): string | undefined {
	const plain = stripVTControlCharacters(status)
		.replace(/[\u0000-\u001f\u007f]/g, " ")
		.replace(/\s+/g, " ")
		.trim();
	if (!plain) return undefined;
	return plain.replace(/^codex\s+/iu, "");
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
