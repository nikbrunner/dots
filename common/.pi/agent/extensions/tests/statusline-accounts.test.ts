import { getActiveAccountLabel } from "../lib/statusline-accounts.ts";

Deno.test("reads the active account from pi-accounts provider data", () => {
	const accounts = {
		version: 1,
		providers: {
			"openai-codex": {
				active: "Personal",
				accounts: {},
			},
		},
	};

	if (getActiveAccountLabel(accounts, "openai-codex") !== "Personal") {
		throw new Error("Expected the active pi-accounts account label.");
	}
});

Deno.test("returns no account label when the provider uses the default login", () => {
	const accounts = {
		version: 1,
		providers: {
			"openai-codex": {
				accounts: {},
			},
		},
	};

	if (getActiveAccountLabel(accounts, "openai-codex") !== undefined) {
		throw new Error("Expected no label for the default login.");
	}
});
