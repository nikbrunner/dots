import { isToolCallEventType, type ExtensionAPI } from "@earendil-works/pi-coding-agent";

type AskUserInput = {
  displayMode?: "overlay" | "inline";
  question?: string;
  context?: string;
  options?: unknown[];
  allowMultiple?: boolean;
  allowFreeform?: boolean;
  allowComment?: boolean;
  singleSelectLayout?: "auto" | "list";
  overlayToggleKey?: string;
  commentToggleKey?: string;
  timeout?: number;
};

export default function askUserInline(pi: ExtensionAPI) {
  pi.on("tool_call", (event) => {
    if (isToolCallEventType<"ask_user", AskUserInput>("ask_user", event)) {
      if (!event.input.displayMode) {
        event.input.displayMode = "inline";
      }
    }
  });
}
