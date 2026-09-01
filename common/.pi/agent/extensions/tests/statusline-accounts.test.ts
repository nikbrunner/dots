import { getActiveAccountLabelFromStatus } from "../lib/statusline-accounts.ts";

Deno.test("reads the session account from the pi-accounts status", () => {
	if (getActiveAccountLabelFromStatus("account:ImFusion") !== "ImFusion") {
		throw new Error("Expected the session's active account label.");
	}
});

Deno.test("keeps the session account label when authentication reports an error", () => {
	if (getActiveAccountLabelFromStatus("account:ImFusion auth error") !== "ImFusion") {
		throw new Error("Expected the account label from an authentication error status.");
	}
});

Deno.test("returns no account label for the default pi login status", () => {
	if (getActiveAccountLabelFromStatus("") !== undefined) {
		throw new Error("Expected no label for the default login.");
	}
});
