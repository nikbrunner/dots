#!/usr/bin/env bash
# Block until a selection is made in the visual companion browser.
# Usage: wait-for-decision.sh <screen_dir> [--timeout <seconds>]
#
# Reads the server URL from .server-info, then long-polls /api/wait.
# Returns the selection JSON on stdout: { choice, text, feedback, ... }
# Exits with code 1 on timeout or if the server stopped.
#
# Example:
#   result=$(wait-for-decision.sh "$SCREEN_DIR")
#   choice=$(echo "$result" | jq -r '.choice')
#   feedback=$(echo "$result" | jq -r '.feedback // empty')

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <screen_dir> [--timeout <seconds>]" >&2
  exit 1
fi

SCREEN_DIR="$1"
TIMEOUT=""

shift
while [[ $# -gt 0 ]]; do
  case "$1" in
    --timeout)
      TIMEOUT="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

SERVER_INFO="$SCREEN_DIR/.server-info"
SERVER_STOPPED="$SCREEN_DIR/.server-stopped"

# Wait for .server-info to appear (server might still be starting)
for i in {1..50}; do
  if [[ -f "$SERVER_INFO" ]]; then
    break
  fi
  sleep 0.1
done

if [[ ! -f "$SERVER_INFO" ]]; then
  echo '{"error": "Server info not found — server may have failed to start"}' >&2
  exit 1
fi

# Extract URL
URL=$(grep -o '"url":"[^"]*"' "$SERVER_INFO" | head -1 | sed 's/"url":"\(.*\)"/\1/')
if [[ -z "$URL" ]]; then
  echo '{"error": "Could not extract URL from .server-info"}' >&2
  exit 1
fi

# Build curl args
CURL_ARGS=(-s)
if [[ -n "$TIMEOUT" ]]; then
  CURL_ARGS+=(--max-time "$TIMEOUT")
fi

# Long-poll the /api/wait endpoint
RESULT=$(curl "${CURL_ARGS[@]}" "$URL/api/wait" 2>/dev/null)

# Check if the server stopped while waiting
if [[ -z "$RESULT" ]]; then
  if [[ -f "$SERVER_STOPPED" ]]; then
    echo '{"error": "Server stopped while waiting for decision"}' >&2
  else
    # Could be curl exit due to signal (timeout or interrupt)
    echo '{"error": "Wait cancelled or timed out"}' >&2
  fi
  exit 1
fi

echo "$RESULT"
