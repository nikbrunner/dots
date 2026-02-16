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

url=$(pbpaste)

if [[ ! "$url" =~ ^https://linear\.app/.*/issue/([A-Z]+-[0-9]+)/(.*) ]]; then
  echo "Clipboard does not contain a valid Linear issue URL"
  exit 1
fi

issue_id="${BASH_REMATCH[1]}"
slug="${BASH_REMATCH[2]}"

# Convert slug dashes to spaces for the title
title="${slug//-/ }"

# Remove trailing slash if present
title="${title%/}"

result="[${issue_id}: ${title}](linear://issue/${issue_id})"

echo -n "$result" | pbcopy
echo "Copied: $result"
