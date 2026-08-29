import {
	compactFooterLabel,
	formatFooterRowLabel,
	getAlignedColumnWidths,
	type FooterRow,
} from "../lib/statusline-layout.ts";

function assertEquals<T>(actual: T, expected: T): void {
	if (JSON.stringify(actual) !== JSON.stringify(expected)) {
		throw new Error(`Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`);
	}
}

Deno.test("uses compact row labels", () => {
	assertEquals(compactFooterLabel("WORKSPACE"), "WRK");
	assertEquals(compactFooterLabel("AGENT"), "AGT");
	assertEquals(compactFooterLabel("SESSION"), "SES");
	assertEquals(compactFooterLabel("PROVIDER"), "PRV");
});

Deno.test("leaves a gap after compact row labels", () => {
	assertEquals(formatFooterRowLabel("PROVIDER"), "PRV  ");
});

Deno.test("keeps compact rows aligned when shortened labels fit", () => {
	const rows: FooterRow[] = [
		{ label: "AG", parts: ["✓ ready", "mdl gpt-5.6-luna", "th high", "mcp 0/6"] },
		{ label: "SESS", parts: ["↑589k", "↓11k", "ctx 65%/272k", "hit 93%", "$0.174"] },
	];

	assertEquals(getAlignedColumnWidths(rows), [7, 16, 12, 7, 6]);
});

Deno.test("keeps shared compact widths when rows overflow", () => {
	const rows: FooterRow[] = [
		{ label: "AG", parts: ["✓ ready", "mdl gpt-5.6-luna", "th high", "mcp 0/6"] },
		{ label: "SESS", parts: ["↑589k", "↓11k", "ctx 65%/272k", "hit 93%", "$0.174"] },
	];

	assertEquals(getAlignedColumnWidths(rows), [7, 16, 12, 7, 6]);
});
