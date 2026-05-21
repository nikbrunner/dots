#!/usr/bin/env bash
# Export a visual companion screen file as standalone HTML or screenshot-optimized page
# Usage: export.sh <screen-dir> <filename> [--standalone|--screenshot] [--output <path>] [--open]
#
# Default output directory: ./design/ (relative to cwd, created if missing)
# Ask the user before saving if the project doesn't have a design/ dir yet.
#
# Examples:
#   export.sh screen-dir layout.html --standalone --output design/sidebar.html
#   export.sh screen-dir final-layout.html --screenshot --open
#   export.sh screen-dir layout.html --screenshot --output design/layout.png

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <screen-dir> <filename> [options]" >&2
  echo "" >&2
  echo "Options:" >&2
  echo "  --standalone        Export as standalone HTML (default)" >&2
  echo "  --screenshot        Export as screenshot-optimized page" >&2
  echo "  --output <path>     Save to file (HTML or .png/.jpg)" >&2
  echo "  --open              Open in browser after export" >&2
  echo "" >&2
  echo "Examples:" >&2
  echo "  $0 /tmp/brainstorm-123 layout.html --standalone --output design/sidebar.html" >&2
  echo "  $0 /tmp/brainstorm-123 final-layout.html --screenshot --open" >&2
  exit 1
fi

SCREEN_DIR="$1"
FILENAME="$2"
shift 2

MODE="standalone"
OUTPUT=""
OPEN_BROWSER="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --standalone) MODE="standalone" ;;
    --screenshot) MODE="screenshot" ;;
    --output) OUTPUT="$2"; shift ;;
    --open) OPEN_BROWSER="true" ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

# Validate screen dir
if [[ ! -d "$SCREEN_DIR" ]]; then
  echo "Error: screen directory not found: $SCREEN_DIR" >&2
  exit 1
fi

# Validate file exists
if [[ ! -f "${SCREEN_DIR}/${FILENAME}" ]]; then
  echo "Error: file not found: ${SCREEN_DIR}/${FILENAME}" >&2
  exit 1
fi

# Get server URL from .server-info
SERVER_INFO="${SCREEN_DIR}/.server-info"
if [[ ! -f "$SERVER_INFO" ]]; then
  echo "Error: companion server not running (no .server-info found)" >&2
  echo "Start the server first with start-server.sh" >&2
  exit 1
fi

BASE_URL=$(grep -o '"url":"[^"]*"' "$SERVER_INFO" | head -1 | sed 's/"url":"\(.*\)"/\1/')
if [[ -z "$BASE_URL" ]]; then
  echo "Error: could not extract URL from .server-info" >&2
  exit 1
fi

# Build export URL
EXPORT_URL="${BASE_URL}/api/export?file=${FILENAME}&mode=${MODE}"

# Handle output
if [[ -n "$OUTPUT" ]]; then
  EXT="${OUTPUT##*.}"
  case "$EXT" in
    png|jpg|jpeg)
      # Screenshot capture: open in browser via screencapture
      echo "Opening export for screenshot capture..." >&2
      echo "URL: $EXPORT_URL" >&2
      echo "" >&2
      echo "Capturing screenshot to: $OUTPUT" >&2

      case "$(uname)" in
        Darwin)
          # Open the export page, wait a moment, then capture the active window
          open "$EXPORT_URL"
          sleep 0.5
          screencapture -w "$OUTPUT" 2>/dev/null || {
            echo "screencapture cancelled or failed. Try:" >&2
            echo "  open '$EXPORT_URL'" >&2
            echo "  Then take a manual screenshot (Cmd+Shift+4)" >&2
            exit 1
          }
          echo "Captured: $OUTPUT" >&2
          ;;
        Linux)
          echo "Linux screenshot not implemented. Open the URL manually:" >&2
          echo "  $EXPORT_URL" >&2
          exit 1
          ;;
      esac
      ;;
    *)
      # HTML output: fetch the export and save
      if curl -sS "$EXPORT_URL" > "$OUTPUT"; then
        echo "Exported to $OUTPUT" >&2
      else
        echo "Error: failed to fetch export" >&2
        exit 1
      fi
      ;;
  esac
else
  # No output path: print URL and optionally open
  echo "$EXPORT_URL"
  if [[ "$OPEN_BROWSER" == "true" ]]; then
    case "$(uname)" in
      Darwin) open "$EXPORT_URL" ;;
      Linux)  xdg-open "$EXPORT_URL" ;;
    esac
  fi
fi
