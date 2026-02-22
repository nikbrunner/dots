#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Linear to Obsidian Link
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔗
# @raycast.packageName Linear

# Documentation:
# @raycast.description Converts a Linear URL from clipboard to an Obsidian-friendly markdown link with linear:// URL scheme

clipboard=$(pbpaste)

# Handle markdown link format: [Title](https://linear.app/...)
md_regex='^\[([^]]+)\]\((https://linear\.app/[^)]+)\)$'
if [[ "$clipboard" =~ $md_regex ]]; then
  title="${BASH_REMATCH[1]}"
  url="${BASH_REMATCH[2]}"
else
  url="$clipboard"
fi

# Validate it's a Linear URL
if [[ ! "$url" =~ ^https://linear\.app/ ]]; then
  echo "Clipboard does not contain a valid Linear URL"
  exit 1
fi

# Convert https://linear.app/... to linear://...
linear_url="linear://${url#https://linear.app/}"

# For issue URLs, extract ID and build a cleaner title if we don't have one
if [[ "$url" =~ /issue/([A-Z]+-[0-9]+)/(.*) ]]; then
  issue_id="${BASH_REMATCH[1]}"

  if [[ -n "${title:-}" ]]; then
    # Strip issue prefix if already in title (e.g. "DES-25: Design Logo" -> "Design Logo")
    clean_title="${title#*: }"
    result="[${issue_id}: ${clean_title}](${linear_url})"
  else
    slug="${BASH_REMATCH[2]}"
    clean_title="${slug//-/ }"
    clean_title="${clean_title%/}"
    result="[${issue_id}: ${clean_title}](${linear_url})"
  fi
elif [[ -n "${title:-}" ]]; then
  # Non-issue URL with markdown title (e.g. project, view, etc.)
  result="[${title}](${linear_url})"
else
  # Plain URL without title — just wrap it
  result="[Linear](${linear_url})"
fi

echo -n "$result" | pbcopy
osascript -e 'tell application "System Events" to keystroke "v" using command down'
echo "Pasted: $result"
