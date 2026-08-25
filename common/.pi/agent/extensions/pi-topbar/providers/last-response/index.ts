import { Text } from "@earendil-works/pi-tui";
import type { TopbarProvider } from "../types";

const lastResponseProvider: TopbarProvider = {
	id: "last-response",
	render({ lastResponse }) {
		return lastResponse ? new Text(lastResponse, 0, 0) : undefined;
	},
};

export default lastResponseProvider;
