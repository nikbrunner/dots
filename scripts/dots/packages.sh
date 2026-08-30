#!/usr/bin/env bash

DOTS_DIR="${DOTS_DIR:-$HOME/repos/nikbrunner/dots}"
_PACKAGES_SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# shellcheck disable=SC1091
source "$_PACKAGES_SCRIPT_DIR/../log.sh"
# shellcheck disable=SC1091
source "$_PACKAGES_SCRIPT_DIR/detect-os.sh"

_packages_mise_dir() {
    printf '%s\n' "$DOTS_DIR/common/.config/mise"
}

_packages_brewfile() {
    printf '%s\n' "$DOTS_DIR/install/mac/Brewfile"
}

_packages_arch_packages() {
    awk '!/^[[:space:]]*#/ && NF { print $1 }' "$DOTS_DIR/install/arch/pkglist.txt"
}

_packages_run_mise() {
    if ! command -v mise >/dev/null 2>&1; then
        log_warn "mise not found — skipping mise packages"
        return 1
    fi

    if [[ "${1:-}" == "--upgrade" ]]; then
        mise upgrade --cd "$(_packages_mise_dir)"
    else
        mise install --cd "$(_packages_mise_dir)" --locked
    fi
}

_packages_run_brew() {
    local brewfile
    brewfile=$(_packages_brewfile)

    if ! command -v brew >/dev/null 2>&1; then
        log_warn "Homebrew not found — skipping Homebrew packages"
        return 1
    fi

    if [[ "${1:-}" == "--upgrade" ]]; then
        brew bundle install --upgrade --file="$brewfile"
    else
        brew bundle install --no-upgrade --file="$brewfile"
    fi
}

_packages_run_arch() {
    local package_manager
    local packages=()

    if [[ -f "$DOTS_DIR/install/arch/pkglist.txt" ]]; then
        mapfile -t packages < <(_packages_arch_packages)
    fi

    if [[ ${#packages[@]} -eq 0 ]]; then
        log_info "No Arch packages declared"
        return 0
    fi

    if command -v paru >/dev/null 2>&1; then
        package_manager=(paru)
    elif command -v pacman >/dev/null 2>&1; then
        package_manager=(sudo pacman)
    else
        log_warn "Neither paru nor pacman found — skipping Arch packages"
        return 1
    fi

    "${package_manager[@]}" -S --needed --noconfirm "${packages[@]}"
}

packages_install() {
    local upgrade=false
    local failures=0
    local os

    [[ "${1:-}" == "--upgrade" ]] && upgrade=true
    os=$(get_os)

    if [[ "$upgrade" == true ]]; then
        log_section "Upgrade mise tools"
        _packages_run_mise --upgrade || failures=$((failures + 1))
    else
        log_section "Install mise tools"
        _packages_run_mise || failures=$((failures + 1))
    fi

    case "$os" in
    macos)
        if [[ "$upgrade" == true ]]; then
            log_section "Upgrade Homebrew packages"
            _packages_run_brew --upgrade || failures=$((failures + 1))
        else
            log_section "Install Homebrew packages"
            _packages_run_brew || failures=$((failures + 1))
        fi
        ;;
    arch)
        log_section "Install Arch packages"
        _packages_run_arch || failures=$((failures + 1))
        ;;
    linux)
        log_info "No native package declaration for Linux"
        ;;
    *)
        log_warn "Unsupported OS: $os"
        failures=$((failures + 1))
        ;;
    esac

    [[ "$failures" -eq 0 ]]
}

_packages_remove_candidate_files() {
    rm -f "$1" "$2"
}

_packages_add_candidate() {
    local candidates_file="$1"
    local timestamp="$2"
    local kind="$3"
    local name="$4"
    local version="$5"
    local label="$6"

    printf '%s\t%s\t%s\t%s\t%s\n' "$timestamp" "$kind" "$name" "$version" "$label" >>"$candidates_file"
}

_packages_epoch_from_date() {
    local value="$1"
    local epoch

    [[ -z "$value" || "$value" == "(null)" ]] && return 1
    if [[ "$OSTYPE" == darwin* ]]; then
        epoch=$(date -j -f '%Y-%m-%d %H:%M:%S %z' "$value" '+%s' 2>/dev/null) || return 1
    else
        epoch=$(date -d "$value" '+%s' 2>/dev/null) || return 1
    fi
    [[ "$epoch" =~ ^[0-9]+$ ]] || return 1
    printf '%s\n' "$epoch"
}

_packages_stat_epoch() {
    local path="$1"
    local epoch

    [[ -e "$path" ]] || return 1
    if [[ "$OSTYPE" == darwin* ]]; then
        epoch=$(stat -f '%a' "$path" 2>/dev/null) || return 1
    else
        epoch=$(stat -c '%X' "$path" 2>/dev/null) || return 1
    fi
    [[ "$epoch" =~ ^[0-9]+$ ]] || return 1
    printf '%s\n' "$epoch"
}

_packages_format_timestamp() {
    local epoch="$1"

    if [[ -z "$epoch" || "$epoch" -ge 9999999999 ]]; then
        printf '%s\n' "unknown"
    elif [[ "$OSTYPE" == darwin* ]]; then
        date -r "$epoch" '+%Y-%m-%d' 2>/dev/null || printf '%s\n' "unknown"
    else
        date -d "@$epoch" '+%Y-%m-%d' 2>/dev/null || printf '%s\n' "unknown"
    fi
}

_packages_cask_app_path() {
    local name="$1"
    local app
    local root

    app=$(brew info --json=v2 --installed "$name" 2>/dev/null | jq -r '.casks[0].artifacts[]?.app[]? // empty' | head -1)
    [[ -z "$app" ]] && return 1

    for root in /Applications "$HOME/Applications"; do
        if [[ -d "$root/$app" ]]; then
            printf '%s\n' "$root/$app"
            return 0
        fi
    done
    return 1
}

_packages_brew_last_used() {
    local kind="$1"
    local name="$2"
    local path
    local value
    local epoch

    if [[ "$kind" == "brew-cask" ]]; then
        path=$(_packages_cask_app_path "$name") || true
        if [[ -n "$path" ]] && command -v mdls >/dev/null 2>&1; then
            value=$(mdls -raw -name kMDItemLastUsedDate "$path" 2>/dev/null) || true
            epoch=$(_packages_epoch_from_date "$value") || true
            [[ -n "$epoch" ]] && printf '%s\n' "$epoch" && return 0
        fi
    elif [[ "$kind" == "brew-formula" ]]; then
        path=$(brew --prefix "$name" 2>/dev/null) || true
        epoch=$(_packages_stat_epoch "$path") || true
        [[ -n "$epoch" ]] && printf '%s\n' "$epoch" && return 0
    fi

    printf '%s\n' 9999999999
}

_packages_mise_last_used() {
    local name="$1"
    local version="$2"
    local path
    local epoch

    path=$(mise where "$name@$version" 2>/dev/null) || true
    epoch=$(_packages_stat_epoch "$path") || true
    [[ -n "$epoch" ]] && printf '%s\n' "$epoch" && return 0
    printf '%s\n' 9999999999
}

_packages_arch_last_used() {
    local name="$1"
    local path
    local epoch

    path=$(pacman -Ql "$name" 2>/dev/null | awk '$1 ~ /^\/usr\/bin\// { print $1; exit }') || true
    epoch=$(_packages_stat_epoch "$path") || true
    [[ -n "$epoch" ]] && printf '%s\n' "$epoch" && return 0
    printf '%s\n' 9999999999
}

_packages_collect_brew() {
    local candidates_file="$1"
    local brewfile
    local declared
    local name
    local timestamp
    local date_label
    local -A declared_formulae=()
    local -A declared_casks=()

    command -v brew >/dev/null 2>&1 || return 0
    brewfile=$(_packages_brewfile)
    [[ -f "$brewfile" ]] || return 0

    while IFS= read -r name; do
        [[ -n "$name" ]] && declared_formulae["$name"]=1
    done < <(brew bundle list --formula --file="$brewfile" 2>/dev/null || true)

    while IFS= read -r name; do
        [[ -n "$name" ]] && declared_casks["$name"]=1
    done < <(brew bundle list --cask --file="$brewfile" 2>/dev/null || true)

    while IFS= read -r name; do
        [[ -z "$name" || -n "${declared_formulae[$name]:-}" ]] && continue
        timestamp=$(_packages_brew_last_used brew-formula "$name")
        date_label=$(_packages_format_timestamp "$timestamp")
        _packages_add_candidate "$candidates_file" "$timestamp" brew-formula "$name" unknown "Homebrew formula: $name [filesystem access: $date_label]"
    done < <(brew list --formula --installed-on-request --full-name 2>/dev/null || true)

    while IFS= read -r name; do
        [[ -z "$name" || -n "${declared_casks[$name]:-}" ]] && continue
        timestamp=$(_packages_brew_last_used brew-cask "$name")
        date_label=$(_packages_format_timestamp "$timestamp")
        _packages_add_candidate "$candidates_file" "$timestamp" brew-cask "$name" unknown "Homebrew cask: $name [last used: $date_label]"
    done < <(brew list --cask --full-name 2>/dev/null || true)
}

_packages_collect_mise() {
    local candidates_file="$1"
    local installed current
    local name version timestamp date_label

    command -v mise >/dev/null 2>&1 || return 0
    command -v jq >/dev/null 2>&1 || return 0

    installed=$(mise ls --global --installed --json 2>/dev/null) || return 0
    current=$(mise ls --global --current --json 2>/dev/null) || current='{}'

    while IFS= read -r name; do
        [[ -z "$name" ]] && continue
        if jq -e --arg name "$name" 'has($name)' <<<"$current" >/dev/null; then
            while IFS=$'\t' read -r version; do
                [[ -z "$version" ]] && continue
                if ! jq -e --arg name "$name" --arg version "$version" '.[$name][]? | select(.version == $version)' <<<"$current" >/dev/null; then
                    log_info "Extra mise version retained: $name@$version"
                fi
            done < <(jq -r --arg name "$name" '.[$name][]?.version // empty' <<<"$installed")
            continue
        fi
        while IFS=$'\t' read -r version; do
            [[ -z "$version" ]] && continue
            timestamp=$(_packages_mise_last_used "$name" "$version")
            date_label=$(_packages_format_timestamp "$timestamp")
            _packages_add_candidate "$candidates_file" "$timestamp" mise "$name" "$version" "mise tool: $name@$version [filesystem access: $date_label]"
        done < <(jq -r --arg name "$name" '.[$name][]?.version // empty' <<<"$installed")
    done < <(jq -r 'keys[]' <<<"$installed")
}

_packages_collect_arch() {
    local candidates_file="$1"
    local declared_file="$DOTS_DIR/install/arch/pkglist.txt"
    local name timestamp date_label
    local -A declared=()
    local query_command=(pacman)

    [[ -f "$declared_file" ]] || return 0
    if ! command -v pacman >/dev/null 2>&1; then
        command -v paru >/dev/null 2>&1 || return 0
        query_command=(paru)
    fi

    while IFS= read -r name; do
        [[ -n "$name" ]] && declared["$name"]=1
    done < <(_packages_arch_packages)

    while IFS= read -r name; do
        [[ -z "$name" || -n "${declared[$name]:-}" ]] && continue
        timestamp=$(_packages_arch_last_used "$name")
        date_label=$(_packages_format_timestamp "$timestamp")
        _packages_add_candidate "$candidates_file" "$timestamp" arch "$name" unknown "Arch package: $name [filesystem access: $date_label]"
    done < <("${query_command[@]}" -Qqe 2>/dev/null || true)
}

_packages_uninstall() {
    local kind="$1"
    local name="$2"
    local version="$3"

    case "$kind" in
    brew-formula)
        brew uninstall --formula "$name"
        ;;
    brew-cask)
        brew uninstall --cask "$name"
        ;;
    mise)
        mise uninstall "$name@$version"
        ;;
    arch)
        if command -v paru >/dev/null 2>&1; then
            paru -Rns --noconfirm "$name"
        else
            sudo pacman -Rns --noconfirm "$name"
        fi
        ;;
    esac
}

_packages_pick() {
    local header="$1"
    shift
    local options=("$@")
    local choice
    local index
    local selected=()

    if command -v gum >/dev/null 2>&1; then
        gum choose --no-limit --header "$header" "${options[@]}"
        return
    fi

    echo "$header"
    for index in "${!options[@]}"; do
        printf '  [%s] %s\n' "$((index + 1))" "${options[$index]}"
    done
    printf 'Selection (comma-separated, blank to cancel): '
    read -r choice
    [[ -z "$choice" ]] && return 0
    IFS=',' read -ra selected <<<"$choice"
    for index in "${selected[@]}"; do
        [[ "$index" =~ ^[0-9]+$ && "$index" -ge 1 && "$index" -le ${#options[@]} ]] || continue
        printf '%s\n' "${options[$((index - 1))]}"
    done
}

packages_purge() {
    local dry_run=false
    local os
    local candidates_file sorted_file
    local timestamp kind name version label
    local selected selected_id id
    local -A candidate_kind=()
    local -A candidate_name=()
    local -A candidate_version=()
    local -A candidate_label=()
    local ids=()
    local labels=()
    local selected_ids=()
    local failures=0

    [[ "${1:-}" == "--dry-run" ]] && dry_run=true
    os=$(get_os)
    candidates_file=$(mktemp)
    sorted_file=$(mktemp)

    _packages_collect_mise "$candidates_file"
    case "$os" in
    macos) _packages_collect_brew "$candidates_file" ;;
    arch) _packages_collect_arch "$candidates_file" ;;
    esac

    sort -t $'\t' -k1,1n -k5,5 "$candidates_file" >"$sorted_file"

    while IFS=$'\t' read -r timestamp kind name version label; do
        [[ -z "$kind" ]] && continue
        id="$kind:$name${version:+@$version}"
        candidate_kind["$id"]="$kind"
        candidate_name["$id"]="$name"
        candidate_version["$id"]="$version"
        candidate_label["$id"]="$label"
        ids+=("$id")
        labels+=("$label")
        printf '%s\n' "$label"
    done <"$sorted_file"

    if [[ ${#ids[@]} -eq 0 ]]; then
        log_okay "No undeclared packages found"
        _packages_remove_candidate_files "$candidates_file" "$sorted_file"
        return 0
    fi

    if [[ "$dry_run" == true ]]; then
        log_info "Dry run — no packages were removed"
        _packages_remove_candidate_files "$candidates_file" "$sorted_file"
        return 0
    fi

    selected=$(_packages_pick "Select packages to uninstall (oldest first):" "${labels[@]}") || true
    [[ -z "$selected" ]] && {
        log_info "No packages selected"
        _packages_remove_candidate_files "$candidates_file" "$sorted_file"
        return 0
    }

    while IFS= read -r selected; do
        [[ -z "$selected" ]] && continue
        selected_id=""
        for id in "${ids[@]}"; do
            if [[ "$selected" == "${candidate_label[$id]}" || "${candidate_label[$id]}" == "$selected"* ]]; then
                selected_id="$id"
                break
            fi
        done
        [[ -n "$selected_id" ]] && selected_ids+=("$selected_id")
    done <<<"$selected"

    [[ ${#selected_ids[@]} -eq 0 ]] && {
        log_info "No packages selected"
        _packages_remove_candidate_files "$candidates_file" "$sorted_file"
        return 0
    }

    if ! confirm "Uninstall ${#selected_ids[@]} selected package(s)?"; then
        log_info "Uninstall cancelled"
        _packages_remove_candidate_files "$candidates_file" "$sorted_file"
        return 0
    fi

    for id in "${selected_ids[@]}"; do
        kind="${candidate_kind[$id]}"
        name="${candidate_name[$id]}"
        version="${candidate_version[$id]}"
        log_info "Removing ${candidate_label[$id]}"
        _packages_uninstall "$kind" "$name" "$version" || failures=$((failures + 1))
    done

    _packages_remove_candidate_files "$candidates_file" "$sorted_file"
    [[ "$failures" -eq 0 ]]
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    packages_install "$@"
fi
