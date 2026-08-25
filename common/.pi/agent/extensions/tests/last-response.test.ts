import { darkenRgb, type RgbColor } from "../pi-topbar/lib/colors.ts";
import { getTopbarOverlayOptions } from "../pi-topbar/lib/layout.ts";

Deno.test("anchors the Pi Topbar overlay at the top center", () => {
	const options = getTopbarOverlayOptions(6);

	if (options.anchor !== "top-center") throw new Error(`Expected top-center, got ${options.anchor}`);
	if (options.width !== "100%") throw new Error(`Expected full width, got ${options.width}`);
	if (options.maxHeight !== 6) throw new Error(`Expected six rows, got ${options.maxHeight}`);
	if (options.nonCapturing !== true) throw new Error("Expected the overlay to leave editor focus alone");
});

Deno.test("darkens the terminal background by the configured amount", () => {
	const color: RgbColor = { r: 100, g: 150, b: 200 };
	const darkened = darkenRgb(color, 0.1);

	if (JSON.stringify(darkened) !== JSON.stringify({ r: 90, g: 135, b: 180 })) {
		throw new Error(`Unexpected darkened color: ${JSON.stringify(darkened)}`);
	}
});
