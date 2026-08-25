export interface RgbColor {
	r: number;
	g: number;
	b: number;
}

export function darkenRgb(color: RgbColor, amount: number): RgbColor {
	const factor = 1 - Math.max(0, Math.min(1, amount));
	return {
		r: Math.round(color.r * factor),
		g: Math.round(color.g * factor),
		b: Math.round(color.b * factor),
	};
}

export function paintBackground(text: string, color: RgbColor): string {
	return `\u001b[48;2;${color.r};${color.g};${color.b}m${text}\u001b[49m`;
}
