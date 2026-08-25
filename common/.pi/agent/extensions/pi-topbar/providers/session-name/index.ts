import { Text } from "@earendil-works/pi-tui";
import type { TopbarProvider } from "../types";

const sessionNameProvider: TopbarProvider = {
	id: "session-name",
	render({ sessionName, theme }) {
		return sessionName ? new Text(theme.bold(sessionName), 0, 0) : undefined;
	},
};

export default sessionNameProvider;
