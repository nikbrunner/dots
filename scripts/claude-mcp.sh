#!/usr/bin/env bash
# Claude Code MCP server setup script
# Configures MCP servers from mcp-servers.json using environment variables for secrets

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$(dirname "$SCRIPT_DIR")"
MCP_CONFIG="$DOTS_DIR/common/.claude/mcp-servers.json"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
DRY_RUN=false
FORCE=false
for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=true
            ;;
        --force)
            FORCE=true
            ;;
        --help|-h)
            echo "Usage: $0 [--dry-run] [--force]"
            echo ""
            echo "Options:"
            echo "  --dry-run  Show what would be done without making changes"
            echo "  --force    Re-add servers even if they already exist"
            echo ""
            echo "Environment variables required:"
            echo "  EXA_API_KEY  - API key for Exa web search"
            echo "  REF_API_KEY  - API key for Ref.tools documentation"
            exit 0
            ;;
    esac
done

# Check prerequisites
check_prerequisites() {
    local missing=()

    if ! command -v claude &>/dev/null; then
        missing+=("claude")
    fi

    if ! command -v jq &>/dev/null; then
        missing+=("jq")
    fi

    if [[ ! -f "$MCP_CONFIG" ]]; then
        echo -e "${RED}Error: MCP config not found at $MCP_CONFIG${NC}"
        exit 1
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}Error: Missing required commands: ${missing[*]}${NC}"
        echo "Install with: brew install ${missing[*]} (macOS) or paru -S ${missing[*]} (Arch)"
        exit 1
    fi
}

# Check if an MCP server is already configured
is_mcp_configured() {
    local name="$1"
    # Format is "name: command - status"
    claude mcp list 2>/dev/null | grep -q "^${name}:"
}

# Get environment variable value or prompt
get_secret() {
    local var_name="$1"
    local value="${!var_name}"

    if [[ -z "$value" ]]; then
        echo ""
    else
        echo "$value"
    fi
}

# Add a stdio MCP server
add_stdio_server() {
    local name="$1"
    local command="$2"
    local args="$3"
    local env_json="$4"

    local cmd_args=()
    cmd_args+=("--scope" "user")
    cmd_args+=("--transport" "stdio")

    # Parse environment variables from JSON
    if [[ -n "$env_json" && "$env_json" != "null" ]]; then
        while IFS='=' read -r key val; do
            # Check if value is an env var reference (${VAR_NAME})
            if [[ "$val" =~ ^\$\{([^}]+)\}$ ]]; then
                local env_var="${BASH_REMATCH[1]}"
                local actual_val
                actual_val=$(get_secret "$env_var")
                if [[ -z "$actual_val" ]]; then
                    echo -e "${YELLOW}Warning: $env_var not set, skipping $name${NC}"
                    return 1
                fi
                cmd_args+=("-e" "$key=$actual_val")
            else
                cmd_args+=("-e" "$key=$val")
            fi
        done < <(echo "$env_json" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"')
    fi

    cmd_args+=("$name")
    cmd_args+=("--")
    cmd_args+=("$command")

    # Parse args array
    while IFS= read -r arg; do
        cmd_args+=("$arg")
    done < <(echo "$args" | jq -r '.[]')

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}[DRY]${NC} Would run: claude mcp add ${cmd_args[*]}"
    else
        if claude mcp add "${cmd_args[@]}"; then
            echo -e "${GREEN}✓${NC} Added $name"
        else
            echo -e "${RED}✗${NC} Failed to add $name"
            return 1
        fi
    fi
}

# Add an HTTP MCP server
add_http_server() {
    local name="$1"
    local url="$2"
    local headers_json="$3"

    local cmd_args=()
    cmd_args+=("--scope" "user")
    cmd_args+=("--transport" "http")

    # Parse headers from JSON
    if [[ -n "$headers_json" && "$headers_json" != "null" ]]; then
        while IFS='=' read -r key val; do
            # Check if value is an env var reference (${VAR_NAME})
            if [[ "$val" =~ ^\$\{([^}]+)\}$ ]]; then
                local env_var="${BASH_REMATCH[1]}"
                local actual_val
                actual_val=$(get_secret "$env_var")
                if [[ -z "$actual_val" ]]; then
                    echo -e "${YELLOW}Warning: $env_var not set, skipping $name${NC}"
                    return 1
                fi
                cmd_args+=("-H" "$key: $actual_val")
            else
                cmd_args+=("-H" "$key: $val")
            fi
        done < <(echo "$headers_json" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"')
    fi

    cmd_args+=("$name")
    cmd_args+=("$url")

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}[DRY]${NC} Would run: claude mcp add ${cmd_args[*]}"
    else
        if claude mcp add "${cmd_args[@]}"; then
            echo -e "${GREEN}✓${NC} Added $name"
        else
            echo -e "${RED}✗${NC} Failed to add $name"
            return 1
        fi
    fi
}

# Main setup function
setup_mcp_servers() {
    echo -e "${BLUE}Setting up Claude Code MCP servers...${NC}"
    echo ""

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}DRY RUN MODE - No changes will be made${NC}"
        echo ""
    fi

    # Read server names from config
    local servers
    servers=$(jq -r '.servers | keys[]' "$MCP_CONFIG")

    local added=0
    local skipped=0
    local failed=0

    for name in $servers; do
        local transport
        transport=$(jq -r ".servers[\"$name\"].transport" "$MCP_CONFIG")

        # Check if already configured
        if [[ "$FORCE" != true ]] && is_mcp_configured "$name"; then
            echo -e "${GREEN}✓${NC} $name already configured"
            ((skipped++))
            continue
        fi

        case "$transport" in
            stdio)
                local command args env_json
                command=$(jq -r ".servers[\"$name\"].command" "$MCP_CONFIG")
                args=$(jq -c ".servers[\"$name\"].args // []" "$MCP_CONFIG")
                env_json=$(jq -c ".servers[\"$name\"].env // {}" "$MCP_CONFIG")

                if add_stdio_server "$name" "$command" "$args" "$env_json"; then
                    ((added++))
                else
                    ((failed++))
                fi
                ;;
            http)
                local url headers_json
                url=$(jq -r ".servers[\"$name\"].url" "$MCP_CONFIG")
                headers_json=$(jq -c ".servers[\"$name\"].headers // {}" "$MCP_CONFIG")

                if add_http_server "$name" "$url" "$headers_json"; then
                    ((added++))
                else
                    ((failed++))
                fi
                ;;
            *)
                echo -e "${YELLOW}Warning: Unknown transport '$transport' for $name${NC}"
                ((failed++))
                ;;
        esac
    done

    echo ""
    echo -e "${BLUE}Summary:${NC}"
    echo -e "  Added:   $added"
    echo -e "  Skipped: $skipped"
    echo -e "  Failed:  $failed"

    if [[ $failed -gt 0 ]]; then
        echo ""
        echo -e "${YELLOW}Some servers failed to configure. Make sure required environment variables are set:${NC}"
        echo "  export EXA_API_KEY='your-key'"
        echo "  export REF_API_KEY='your-key'"
        return 1
    fi
}

# Run
check_prerequisites
setup_mcp_servers
