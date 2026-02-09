#!/usr/bin/env bash
# Shared library for repository operations.
# Sourced by both `dots` and `repos` commands.
# Has NO side effects -- callers must invoke load_config() themselves.

# Guard against double-sourcing
[[ -n "${_REPOS_LIB_LOADED:-}" ]] && return 0
_REPOS_LIB_LOADED=1

# ── Configuration ────────────────────────────────────────────

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/repos/config.json"

_DEFAULT_REPOS_BASE_PATH="$HOME/repos"
_DEFAULT_PARALLEL_JOBS=4

# ── Colors ───────────────────────────────────────────────────

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ── Output helpers ───────────────────────────────────────────

print_success() {
	echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
	echo -e "${RED}✗ $1${NC}"
}

print_warning() {
	echo -e "${YELLOW}⚠ $1${NC}"
}

# ── Config loading ───────────────────────────────────────────

load_config() {
	REPOS_BASE_PATH="$_DEFAULT_REPOS_BASE_PATH"
	DEFAULT_PARALLEL_JOBS="$_DEFAULT_PARALLEL_JOBS"

	if [[ -f "$CONFIG_FILE" ]]; then
		local val

		val=$(jq -r '.repos_base_path // empty' "$CONFIG_FILE" 2>/dev/null) || true
		[[ -n "$val" ]] && REPOS_BASE_PATH="${val/#\~/$HOME}"

		val=$(jq -r '.parallel_jobs // empty' "$CONFIG_FILE" 2>/dev/null) || true
		[[ -n "$val" ]] && DEFAULT_PARALLEL_JOBS="$val"
	fi
}

# Get repositories to ensure are cloned from config (as JSON array)
get_ensure_cloned() {
	if [[ ! -f "$CONFIG_FILE" ]]; then
		return 1
	fi
	jq -c '.ensure_cloned[]? // empty' "$CONFIG_FILE" 2>/dev/null
}

# Extract URL from ensure_cloned entry (handles both string and object formats)
get_entry_url() {
	local entry="$1"
	if [[ "$entry" == "{"* ]]; then
		echo "$entry" | jq -r '.url // empty'
	else
		echo "$entry" | tr -d '"'
	fi
}

# Extract postClone command from ensure_cloned entry
get_entry_post_clone() {
	local entry="$1"
	if [[ "$entry" == "{"* ]]; then
		echo "$entry" | jq -r '.postClone // empty'
	fi
}

# ── Utility helpers ──────────────────────────────────────────

has_gum() {
	command -v gum &>/dev/null
}

confirm_action() {
	local prompt="$1"

	if has_gum; then
		gum confirm "$prompt"
	else
		echo -n "$prompt (y/N) "
		read -r confirm
		[[ "$confirm" == "y" || "$confirm" == "Y" ]]
	fi
}

# ── Git URL parsing ──────────────────────────────────────────

parse_git_url() {
	local url="$1"
	local username repo_name

	# Remove .git suffix if present
	url="${url%.git}"

	if [[ "$url" =~ ^git@.*:(.+)/(.+)$ ]]; then
		username="${BASH_REMATCH[1]}"
		repo_name="${BASH_REMATCH[2]}"
	elif [[ "$url" =~ ^https?://.*github\.com/(.+)/(.+)$ ]]; then
		username="${BASH_REMATCH[1]}"
		repo_name="${BASH_REMATCH[2]}"
	else
		print_error "Invalid Git URL format"
		return 1
	fi

	echo "$username/$repo_name"
}

# ── Repository listing & status ──────────────────────────────

list_repos() {
	if [[ ! -d "$REPOS_BASE_PATH" ]]; then
		return
	fi

	find "$REPOS_BASE_PATH" -mindepth 2 -maxdepth 2 -type d 2>/dev/null |
		sed "s|$REPOS_BASE_PATH/||" |
		sort
}

get_repo_sync_status() {
	local repo_path="$1"

	if ! git -C "$repo_path" rev-parse --abbrev-ref '@{u}' &>/dev/null; then
		echo "no upstream"
		return
	fi

	local ahead behind
	ahead=$(git -C "$repo_path" rev-list --count '@{u}..' 2>/dev/null || echo "0")
	behind=$(git -C "$repo_path" rev-list --count '..@{u}' 2>/dev/null || echo "0")

	if [[ "$ahead" -eq 0 && "$behind" -eq 0 ]]; then
		echo "up to date"
	elif [[ "$ahead" -gt 0 && "$behind" -gt 0 ]]; then
		echo "↑$ahead ↓$behind"
	elif [[ "$ahead" -gt 0 ]]; then
		echo "↑$ahead ahead"
	else
		echo "↓$behind behind"
	fi
}

show_repo_status() {
	local repo="$1"
	local repo_path="$REPOS_BASE_PATH/$repo"

	echo "────────────────────────────────────────────────"
	echo -e "${YELLOW}${repo}${NC}"
	echo "────────────────────────────────────────────────"

	(cd "$repo_path" && git status --short)

	local sync_status
	sync_status=$(get_repo_sync_status "$repo_path")
	if [[ "$sync_status" != "up to date" && "$sync_status" != "no upstream" ]]; then
		echo ""
		echo -e "${BLUE}${sync_status}${NC}"
	elif [[ "$sync_status" == "no upstream" ]]; then
		echo ""
		echo -e "${YELLOW}⚠ no upstream configured${NC}"
	fi

	echo "────────────────────────────────────────────────"
}

# ── Repo state detection ─────────────────────────────────────

# Returns: "clean:0:0" | "behind:0:N" | "ahead:N:0" | "diverged:N:N" | "dirty:N:N" | "dirty+behind:N:N" | "no-upstream"
get_repo_state() {
	local repo_path="$1"

	local dirty=""
	if [[ -n $(git -C "$repo_path" status --porcelain 2>/dev/null) ]]; then
		dirty="dirty"
	fi

	if ! git -C "$repo_path" rev-parse --abbrev-ref '@{u}' &>/dev/null; then
		echo "no-upstream"
		return
	fi

	local ahead behind
	ahead=$(git -C "$repo_path" rev-list --count '@{u}..' 2>/dev/null || echo "0")
	behind=$(git -C "$repo_path" rev-list --count '..@{u}' 2>/dev/null || echo "0")

	if [[ -n "$dirty" ]]; then
		if [[ "$behind" -gt 0 ]]; then
			echo "dirty+behind:$ahead:$behind"
		else
			echo "dirty:$ahead:$behind"
		fi
	elif [[ "$ahead" -gt 0 && "$behind" -gt 0 ]]; then
		echo "diverged:$ahead:$behind"
	elif [[ "$ahead" -gt 0 ]]; then
		echo "ahead:$ahead:$behind"
	elif [[ "$behind" -gt 0 ]]; then
		echo "behind:$ahead:$behind"
	else
		echo "clean:0:0"
	fi
}

# Hard reset a repo to match remote
fullreset_repo() {
	local repo_path="$1"

	git -C "$repo_path" fetch --all --quiet 2>/dev/null || true

	if git -C "$repo_path" reset --hard "@{u}" 2>/dev/null; then
		return 0
	else
		return 1
	fi
}

# ── Dots repo helpers ─────────────────────────────────────────

is_dots_repo() {
	local repo_path="$1"
	[[ -f "$repo_path/common/.config/ghostty/config" ]] && [[ -f "$repo_path/symlinks.yml" ]]
}

dots_commit_theme() {
	local repo_path="$1"
	local theme_files=(
		"common/.config/ghostty/config"
		"common/.config/nvim/lua/config.lua"
		"common/.config/tmux/tmux.conf"
		"common/.config/zed/settings.json"
	)

	local has_changes=false
	for file in "${theme_files[@]}"; do
		if [[ -n $(git -C "$repo_path" status --porcelain "$file" 2>/dev/null) ]]; then
			has_changes=true
			break
		fi
	done

	if [[ "$has_changes" == false ]]; then
		echo "No theme changes to commit"
		return 1
	fi

	local theme_name
	theme_name=$(git -C "$repo_path" diff "common/.config/nvim/lua/config.lua" 2>/dev/null | grep '+.*colorscheme' | sed 's/.*"\(.*\)".*/\1/') || true
	if [[ -z "$theme_name" ]]; then
		theme_name=$(grep 'colorscheme = ' "$repo_path/common/.config/nvim/lua/config.lua" | sed 's/.*"\(.*\)".*/\1/') || true
	fi

	if [[ -z "$theme_name" ]]; then
		theme_name="unknown"
	fi

	(cd "$repo_path" && git add "${theme_files[@]}" && git commit -m "chore(themes): switch to $theme_name")
	print_success "Theme commit created: $theme_name"
}

dots_commit_sessions() {
	local repo_path="$1"
	local sessions_dir="$repo_path/common/.config/nvim/sessions"

	local deleted_count
	deleted_count=$(find "$sessions_dir" -type f -mtime +2 -delete -print 2>/dev/null | wc -l | tr -d ' ')
	if [[ "$deleted_count" -gt 0 ]]; then
		echo "Cleaned up $deleted_count old session(s)"
	fi

	if [[ -z $(git -C "$repo_path" status --porcelain "common/.config/nvim/sessions/" 2>/dev/null) ]]; then
		echo "No session changes to commit"
		return 1
	fi

	(cd "$repo_path" && git add "common/.config/nvim/sessions/" && git commit -m "chore(nvim): update sessions")
	print_success "Sessions commit created"
}

dots_commit_radar() {
	local repo_path="$1"
	local radar_file="common/.local/share/nvim/radar/data.json"

	if [[ -z $(git -C "$repo_path" status --porcelain "$radar_file" 2>/dev/null) ]]; then
		echo "No radar changes to commit"
		return 1
	fi

	(cd "$repo_path" && git add "$radar_file" && git commit -m "chore(nvim): update radar data")
	print_success "Radar commit created"
}
