#!/usr/bin/env bash
# Shared library for dots CLI operations.
# Sourced by the `dots` command.
# Has NO side effects -- callers must invoke load_config() themselves.
# Requires: yq (https://github.com/mikefarah/yq/)

# Guard against double-sourcing
[[ -n "${_DOTS_LIB_LOADED:-}" ]] && return 0
_DOTS_LIB_LOADED=1

# Require DOTS_DIR from caller
: "${DOTS_DIR:?DOTS_DIR must be set before sourcing lib.sh}"

# Source shared logging (provides log_*, confirm, choose)
# shellcheck disable=SC1091
source "$DOTS_DIR/scripts/log.sh"

# ── Configuration ────────────────────────────────────────────

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/helm/config.yml"

_DEFAULT_REPOS_BASE_PATH="$HOME/repos"

# ── Config loading ───────────────────────────────────────────

load_config() {
    REPOS_BASE_PATH="$_DEFAULT_REPOS_BASE_PATH"

    if [[ -f "$CONFIG_FILE" ]]; then
        local val

        val=$(yq '.project_dirs[0] // ""' "$CONFIG_FILE" 2>/dev/null) || true
        [[ -n "$val" && "$val" != "null" ]] && REPOS_BASE_PATH="${val/#\~/$HOME}"
    fi
}

# Get repositories to ensure are cloned from config (one JSON entry per line)
get_ensure_cloned() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        return 1
    fi
    yq -o=json -I=0 '.ensure_cloned[]' "$CONFIG_FILE" 2>/dev/null
}

# Extract URL from ensure_cloned entry (handles both string and object formats)
get_entry_url() {
    local entry="$1"
    if [[ "$entry" == "{"* ]]; then
        echo "$entry" | yq -p=json '.url // ""'
    else
        echo "$entry" | tr -d '"'
    fi
}

# Extract post_clone command from ensure_cloned entry
get_entry_post_clone() {
    local entry="$1"
    if [[ "$entry" == "{"* ]]; then
        local val
        val=$(echo "$entry" | yq -p=json '.post_clone // ""')
        [[ -n "$val" && "$val" != "null" ]] && echo "$val"
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
        log_fail "Invalid Git URL format"
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

dots_stage_theme() {
    local repo_path="$1"
    local theme_files=(
        "common/.config/ghostty/config"
        "common/.config/lazygit/config.yml"
        "common/.config/nvim/plugin/50_specs/black_atom/nvim.lua"
        "common/.config/tmux/tmux.conf"
        "common/.config/zed/settings.json"
        "arch/.config/waybar/theme.css"
        "arch/.config/niri/theme.kdl"
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

    if (cd "$repo_path" && git add "${theme_files[@]}"); then
        log_okay "Theme changes staged"
    else
        log_fail "Failed to stage theme changes"
        return 1
    fi
}

# Clean orphaned and stale nvim sessions.
# Orphaned = cd directory or worktree no longer exists.
# Stale = modified more than 2 days ago.
# Prints structured output: ORPHAN:<name> or OLD:<name> per deleted file.
# Nvim config dirs whose sessions/ are managed by chores (NVIM_APPNAME dirs)
DOTS_NVIM_CONFIGS=("nvim" "nvim-edit")

dots_clean_sessions() {
    local home="$HOME"
    # REPOS_BASE_PATH must be set (call load_config first)
    local repos_dir="${REPOS_BASE_PATH:-$HOME/repos}"

    local orphan_count=0 old_count=0
    local nvim_config sessions_dir

    for nvim_config in "${DOTS_NVIM_CONFIGS[@]}"; do
        sessions_dir="$HOME/.config/$nvim_config/sessions"
        [[ -d "$sessions_dir" ]] || continue

        for f in "$sessions_dir"/*; do
            [[ -f "$f" ]] || continue

            local name
            name=$(basename "$f")

            # Extract cd path from session file
            local cdpath
            cdpath=$(grep '^cd ' "$f" 2>/dev/null | head -1 | sed 's/^cd //' | sed "s|^~|$home|")

            local orphan=false

            # Check 1: cd directory no longer exists
            if [[ -n "$cdpath" ]] && [[ ! -d "$cdpath" ]]; then
                orphan=true
            fi

            # Check 2: worktree subdir no longer exists (cd points to parent repo)
            if [[ "$orphan" == "false" ]] && [[ -n "$cdpath" ]] && echo "$name" | grep -q '\.claude_worktrees_'; then
                local wt
                wt="${name#*.claude_worktrees_}"
                wt="${wt%%_*}"
                if [[ -n "$wt" ]] && ! echo "$cdpath" | grep -q '\.claude/worktrees'; then
                    [[ ! -d "$cdpath/.claude/worktrees/$wt" ]] && orphan=true
                fi
            fi

            # Check 3: no cd line — search repos for matching worktree
            if [[ -z "$cdpath" ]] && echo "$name" | grep -q '\.claude_worktrees_'; then
                local wt
                wt="${name#*.claude_worktrees_}"
                wt="${wt%%_*}"
                local found=false
                if [[ -n "$wt" ]]; then
                    while IFS= read -r wt_dir; do
                        [[ -z "$wt_dir" ]] && continue
                        found=true
                        break
                    done < <(find "$repos_dir" -maxdepth 4 -path "*/.claude/worktrees/$wt" -type d 2>/dev/null | head -1)
                fi
                [[ "$found" == "false" ]] && orphan=true
            fi

            if [[ "$orphan" == "true" ]]; then
                rm -f "$f" && echo "ORPHAN:$name"
                ((orphan_count++)) || true
            elif find "$f" -maxdepth 0 -mtime +2 -print 2>/dev/null | grep -q .; then
                rm -f "$f" && echo "OLD:$name"
                ((old_count++)) || true
            fi
        done
    done

    if [[ $orphan_count -eq 0 && $old_count -eq 0 ]]; then
        echo "NONE"
    fi
}

dots_stage_sessions() {
    local repo_path="$1"

    # Clean orphaned and stale sessions
    local clean_output
    clean_output=$(dots_clean_sessions)
    if [[ -n "$clean_output" && "$clean_output" != "NONE" ]]; then
        while IFS= read -r line; do
            echo "  $line"
        done <<<"$clean_output"
    fi

    local nvim_config staged=false
    for nvim_config in "${DOTS_NVIM_CONFIGS[@]}"; do
        local sessions_path="common/.config/$nvim_config/sessions/"
        if [[ -n $(git -C "$repo_path" status --porcelain "$sessions_path" 2>/dev/null) ]]; then
            (cd "$repo_path" && git add "$sessions_path")
            staged=true
        fi
    done

    if [[ "$staged" == false ]]; then
        echo "No session changes to commit"
        return 1
    fi

    log_okay "Session changes staged"
}

dots_stage_pi() {
    local repo_path="$1"
    local pi_sessions_dir="$repo_path/common/.pi/agent/sessions"
    local pi_paths=(
        "common/.pi/agent/settings.json"
    )

    # Clean up old sessions (>2 days)
    if [[ -d "$pi_sessions_dir" ]]; then
        local deleted_count
        deleted_count=$(find "$pi_sessions_dir" -type f -mtime +2 -delete -print 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$deleted_count" -gt 0 ]]; then
            echo "Cleaned up $deleted_count old pi session(s)"
        fi
    fi

    # Filter to only paths that exist on disk or have uncommitted changes
    local existing_paths=()
    for p in "${pi_paths[@]}"; do
        if [[ -e "$repo_path/$p" ]] || [[ -n $(git -C "$repo_path" status --porcelain "$p" 2>/dev/null) ]]; then
            existing_paths+=("$p")
        fi
    done

    if [[ ${#existing_paths[@]} -eq 0 ]]; then
        echo "No pi changes to commit"
        return 1
    fi

    local has_changes=false
    for p in "${existing_paths[@]}"; do
        if [[ -n $(git -C "$repo_path" status --porcelain "$p" 2>/dev/null) ]]; then
            has_changes=true
            break
        fi
    done

    if [[ "$has_changes" == false ]]; then
        echo "No pi changes to commit"
        return 1
    fi

    if (cd "$repo_path" && git add "${existing_paths[@]}"); then
        log_okay "Pi changes staged"
    else
        log_fail "Failed to stage pi changes"
        return 1
    fi
}

dots_stage_radar() {
    local repo_path="$1"

    local nvim_config staged=false
    for nvim_config in "${DOTS_NVIM_CONFIGS[@]}"; do
        local radar_file="common/.local/share/$nvim_config/radar/data.json"
        if [[ -n $(git -C "$repo_path" status --porcelain "$radar_file" 2>/dev/null) ]]; then
            (cd "$repo_path" && git add "$radar_file")
            staged=true
        fi
    done

    if [[ "$staged" == false ]]; then
        echo "No radar changes to commit"
        return 1
    fi

    log_okay "Radar changes staged"
}

dots_stage_lazy_lock() {
    local repo_path="$1"
    local lazy_lock_file="common/.config/nvim/lazy-lock.json"

    if [[ -z $(git -C "$repo_path" status --porcelain "$lazy_lock_file" 2>/dev/null) ]]; then
        echo "No lazy-lock changes to commit"
        return 1
    fi

    (cd "$repo_path" && git add "$lazy_lock_file")
    log_okay "Lazy-lock changes staged"
}

dots_stage_bookmarks() {
    local repo_path="$1"
    local bookmarks_file="common/.config/bm/bookmarks.db"

    if [[ -z $(git -C "$repo_path" status --porcelain "$bookmarks_file" 2>/dev/null) ]]; then
        echo "No bookmarks changes to commit"
        return 1
    fi

    (cd "$repo_path" && git add "$bookmarks_file")
    log_okay "Bookmarks changes staged"
}

# Resolve a Claude project directory name to a readable org/repo path
# by matching against actual directories in the repos base path.
# Example: -Users-nbr-repos-black-atom-industries-core → black-atom-industries/core
_resolve_claude_project_path() {
    local project_dir="$1"
    local repos_base="$2"

    local stripped
    stripped=$(echo "$project_dir" | sed 's/^-Users-[^-]*-repos-//')

    for org_dir in "$repos_base"/*/; do
        [[ -d "$org_dir" ]] || continue
        local org
        org=$(basename "$org_dir")
        local org_dashed
        org_dashed=$(echo "$org" | tr '/' '-')

        if [[ "$stripped" == "$org_dashed"-* ]]; then
            echo "$org/${stripped#"${org_dashed}"-}"
            return
        elif [[ "$stripped" == "$org_dashed" ]]; then
            echo "$org"
            return
        fi
    done

    # Fallback: use raw stripped name
    echo "$stripped"
}

# Link tracked claude memories back to ~/.claude/projects/*/memory/
# This is the reverse of dots_commit_claude_memories: given memory content in dots,
# create the expected Claude project directory and symlink memory/ back to dots.
dots_link_claude_memories() {
    local repo_path="$1"
    local memories_dir="$repo_path/common/.claude/claude-memories"
    local projects_base="$HOME/.claude/projects"
    local repos_base="${REPOS_BASE_PATH:-$HOME/repos}"

    if [[ ! -d "$memories_dir" ]]; then
        return
    fi

    local user
    user=$(basename "$HOME")

    local linked=0
    # Iterate org/repo dirs in claude-memories/
    for org_dir in "$memories_dir"/*/; do
        [[ -d "$org_dir" ]] || continue
        local org
        org=$(basename "$org_dir")

        # Skip non-project entries (like README.md's parent)
        [[ "$org" == "README.md" ]] && continue

        for repo_dir in "$org_dir"/*/; do
            [[ -d "$repo_dir" ]] || continue
            local repo
            repo=$(basename "$repo_dir")

            # Skip empty dirs (no files to link)
            if [[ -z $(find "$repo_dir" -type f 2>/dev/null) ]]; then
                continue
            fi

            # Reconstruct Claude project dir name:
            # black-atom-industries/core → -Users-nbr-repos-black-atom-industries-core
            local project_dir_name="-Users-${user}-repos-${org}-${repo}"
            local project_dir="$projects_base/$project_dir_name"
            local memory_target="$project_dir/memory"

            # Skip if already correctly symlinked
            if [[ -L "$memory_target" ]]; then
                local current_target
                current_target=$(readlink "$memory_target")
                if [[ "$current_target" == "$repo_dir" || "$current_target" == "${repo_dir%/}" ]]; then
                    continue
                fi
            fi

            # Ensure project dir exists
            mkdir -p "$project_dir"

            # Remove existing memory dir/symlink if present
            if [[ -e "$memory_target" || -L "$memory_target" ]]; then
                rm -rf "$memory_target"
            fi

            ln -s "${repo_dir%/}" "$memory_target"
            echo "  Linked: $org/$repo"
            ((linked++)) || true
        done
    done

    if [[ $linked -gt 0 ]]; then
        log_okay "Linked $linked claude memory project(s)"
    fi
}

dots_stage_gitconfig() {
    local repo_path="$1"
    local gitconfig="common/.gitconfig"

    if [[ -z $(git -C "$repo_path" status --porcelain "$gitconfig" 2>/dev/null) ]]; then
        echo "No gitconfig changes to commit"
        return 1
    fi

    (cd "$repo_path" && git add "$gitconfig")
    log_okay "Gitconfig changes staged"
}

dots_stage_gitconfig_delta() {
    local repo_path="$1"
    local gitconfig_delta="common/.gitconfig.delta"

    if [[ -z $(git -C "$repo_path" status --porcelain "$gitconfig_delta" 2>/dev/null) ]]; then
        echo "No gitconfig.delta changes to commit"
        return 1
    fi

    (cd "$repo_path" && git add "$gitconfig_delta")
    log_okay "Gitconfig.delta changes staged"
}

dots_stage_helm_config() {
    local repo_path="$1"
    local helm_config="common/.config/black-atom/helm/config.yml"

    if [[ -z $(git -C "$repo_path" status --porcelain "$helm_config" 2>/dev/null) ]]; then
        echo "No helm config changes to commit"
        return 1
    fi

    (cd "$repo_path" && git add "$helm_config")
    log_okay "Helm config changes staged"
}

dots_stage_claude_settings() {
    local repo_path="$1"
    local claude_settings="common/.claude/settings.json"

    if [[ -z $(git -C "$repo_path" status --porcelain "$claude_settings" 2>/dev/null) ]]; then
        echo "No claude settings changes to commit"
        return 1
    fi

    (cd "$repo_path" && git add "$claude_settings")
    log_okay "Claude settings changes staged"
}

dots_stage_claude_memories() {
    local repo_path="$1"
    local memories_dir="$repo_path/common/.claude/claude-memories"
    local source_base="$HOME/.claude/projects"
    local repos_base="${REPOS_BASE_PATH:-$HOME/repos}"

    # Discover memory dirs and ensure they are symlinked into dots
    local linked=0
    for memory_dir in "$source_base"/*/memory; do
        [[ -d "$memory_dir" ]] || continue

        # Skip if already a symlink (already managed)
        if [[ -L "$memory_dir" ]]; then
            continue
        fi

        # Skip empty memory dirs (no files to track)
        if [[ -z $(find "$memory_dir" -type f 2>/dev/null) ]]; then
            continue
        fi

        local project_dir
        project_dir=$(basename "$(dirname "$memory_dir")")

        local target_path
        target_path=$(_resolve_claude_project_path "$project_dir" "$repos_base")

        local dots_target="$memories_dir/$target_path"
        mkdir -p "$dots_target"

        # Move memory files into dots, then replace with symlink
        cp -a "$memory_dir"/* "$dots_target/" 2>/dev/null || true
        rm -rf "$memory_dir"
        ln -s "$dots_target" "$memory_dir"

        echo "Linked: $target_path"
        ((linked++)) || true
    done

    if [[ $linked -gt 0 ]]; then
        echo "Linked $linked new project(s)"
    fi

    if [[ -z $(git -C "$repo_path" status --porcelain "common/.claude/claude-memories/" 2>/dev/null) ]]; then
        echo "No claude memory changes to commit"
        return 1
    fi

    (cd "$repo_path" && git add "common/.claude/claude-memories/")
    log_okay "Claude memory changes staged"
}
