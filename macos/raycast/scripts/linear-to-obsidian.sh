#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Linear to Obsidian Link
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔗
# @raycast.packageName Linear

# Documentation:
# @raycast.description Converts a Linear issue URL from clipboard to an Obsidian-friendly markdown link with linear:// URL scheme

clipboard=$(pbpaste)

# Handle markdown link format: [Title](https://linear.app/...)
md_regex='^\[([^]]+)\]\((https://linear\.app/[^)]+)\)$'
if [[ "$clipboard" =~ $md_regex ]]; then
  md_title="${BASH_REMATCH[1]}"
  url="${BASH_REMATCH[2]}"
else
  url="$clipboard"
fi

if [[ ! "$url" =~ ^https://linear\.app/.*/issue/([A-Z]+-[0-9]+)/(.*) ]]; then
  echo "Clipboard does not contain a valid Linear issue URL"
  exit 1
fi

issue_id="${BASH_REMATCH[1]}"

if [[ -n "${md_title:-}" ]]; then
  # Strip issue prefix if already in markdown title (e.g. "DES-25: Design Logo" -> "Design Logo")
  title="${md_title#*: }"
else
  slug="${BASH_REMATCH[2]}"
  # Convert slug dashes to spaces for the title
  title="${slug//-/ }"
  # Remove trailing slash if present
  title="${title%/}"
fi

result="[${issue_id}: ${title}](linear://issue/${issue_id})"

echo -n "$result" | pbcopy
osascript -e 'tell application "System Events" to keystroke "v" using command down'
echo "Pasted: $result"
