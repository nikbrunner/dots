#!/bin/bash
# PostToolUse hook: Warn when `: any` or `as any` appears in TypeScript files.
# This is a warning (exit 0), not a block — it provides feedback without stopping.

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only check Write and Edit tools
if [ "$TOOL_NAME" != "Write" ] && [ "$TOOL_NAME" != "Edit" ]; then
    exit 0
fi

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check TypeScript files
if ! echo "$FILE_PATH" | grep -qE '\.(ts|tsx)$'; then
    exit 0
fi

# Check the content that was written/edited
CONTENT=""
if [ "$TOOL_NAME" = "Write" ]; then
    CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')
elif [ "$TOOL_NAME" = "Edit" ]; then
    CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // empty')
fi

if echo "$CONTENT" | grep -qE ':\s*any\b|as\s+any\b'; then
    echo "WARNING: TypeScript \`any\` type detected in $FILE_PATH." >&2
    echo "Prefer proper types or \`unknown\` as a last resort." >&2
fi

exit 0
