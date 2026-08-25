import type { ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { Component } from "@earendil-works/pi-tui";

export interface TopbarProviderContext {
	theme: ExtensionContext["ui"]["theme"];
	sessionName?: string;
	lastResponse?: string;
}

export type TopbarProviderContent = string[] | Component | undefined;

export interface TopbarProvider {
	id: string;
	render(context: TopbarProviderContext): TopbarProviderContent;
}
