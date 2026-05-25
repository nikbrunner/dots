#!/usr/bin/env bash
# Clean up tooling conflicts left over from the Mason → mise migration.
#
# Gated steps:
#   1. Remove leftover ~/.local/share/nvim/mason/ (Mason plugin removed in bf7db58).
#   2. Uninstall Homebrew formulae that overlap with mise-managed tools (macOS).
#   3. Uninstall pacman/AUR packages that overlap with mise-managed tools (Arch).
#   4. Run `mise install` to reconcile.
#
# Steps 2 and 3 are mutually exclusive in practice — each is gated on its
# package manager being present, so only the relevant one runs per machine.
# Idempotent and safe to re-run on any machine.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./log.sh
source "$SCRIPT_DIR/log.sh"

MASON_DIR="$HOME/.local/share/nvim/mason"

# ── Step 1: Mason leftover ───────────────────────────────────────────────────
log_section "Mason leftover directory"

if [[ -d "$MASON_DIR" ]]; then
    size=$(du -sh "$MASON_DIR" 2>/dev/null | awk '{print $1}')
    bin_count=$(find "$MASON_DIR/bin" -maxdepth 1 -type l 2>/dev/null | wc -l | tr -d ' ')
    log_warn "Found $MASON_DIR ($size, $bin_count binaries)"
    log_info "Mason plugin was removed in bf7db58; this directory is orphaned."
    if confirm "Remove it?"; then
        rm -rf "$MASON_DIR"
        log_okay "Mason directory removed."
    else
        log_info "Skipped Mason cleanup."
    fi
else
    log_okay "No Mason directory present."
fi

echo ""

# ── Step 2: Homebrew duplicates of mise tools ────────────────────────────────
log_section "Homebrew duplicates of mise tools"

if ! command -v mise &>/dev/null; then
    log_fail "mise is not installed; cannot detect overlap."
    exit 1
fi

if ! command -v brew &>/dev/null; then
    log_info "Homebrew not installed; skipping brew overlap step."
else
    # Bare mise tool names (drop npm:/go:/pipx: prefixed entries — not brew formulae).
    mise_tools=$(mise ls --current 2>/dev/null | awk '{print $1}' | grep -v ':' || true)

    overlap=()
    for tool in $mise_tools; do
        if brew list --formula --versions "$tool" &>/dev/null; then
            brew_ver=$(brew list --formula --versions "$tool" 2>/dev/null | awk '{print $NF}')
            mise_ver=$(mise current "$tool" 2>/dev/null | awk '{print $1}' || echo "?")
            overlap+=("$tool|$brew_ver|${mise_ver:-?}")
        fi
    done

    if [[ ${#overlap[@]} -eq 0 ]]; then
        log_okay "No Homebrew formulae overlap with mise tools."
    else
        log_warn "Installed via both Homebrew and mise:"
        echo ""
        for entry in "${overlap[@]}"; do
            IFS='|' read -r tool brew_ver mise_ver <<<"$entry"
            printf "  %-25s homebrew: %-15s mise: %s\n" "$tool" "$brew_ver" "$mise_ver"
        done
        echo ""
        if confirm "Uninstall the brew versions?"; then
            for entry in "${overlap[@]}"; do
                IFS='|' read -r tool _ _ <<<"$entry"
                log_info "Uninstalling brew ${tool}..."
                brew uninstall --ignore-dependencies "$tool" || log_warn "  (warnings above are usually fine)"
            done
            log_okay "Brew duplicates removed."
        else
            log_info "Skipped brew uninstall."
        fi
    fi
fi

echo ""

# ── Step 3: pacman/AUR duplicates of mise tools (Arch) ───────────────────────
log_section "Pacman/AUR duplicates of mise tools"

if ! command -v paru &>/dev/null && ! command -v pacman &>/dev/null; then
    log_info "Not an Arch system (no paru/pacman); skipping pacman overlap step."
else
    # Bare mise tool names (drop npm:/go:/pipx: prefixed entries — not native packages).
    mise_tools=$(mise ls --current 2>/dev/null | awk '{print $1}' | grep -v ':' || true)

    # Detect by binary ownership, not name: Arch package names often diverge from
    # mise tool names (delta->git-delta, gh->github-cli, node->nodejs, yq->go-yq).
    # Only offer explicitly-installed packages (pacman -Qe) — the parallel to brew
    # formulae. Dependency-only overlaps (e.g. lua, nodejs) belong to other software
    # and must stay; pacman's own checks protect anything still required.
    pac_overlap=()
    for tool in $mise_tools; do
        bin="/usr/bin/$tool"
        [[ -e "$bin" ]] || continue
        pkg=$(pacman -Qoq "$bin" 2>/dev/null) || continue
        [[ -n "$pkg" ]] || continue
        pacman -Qeq "$pkg" &>/dev/null || continue # explicit installs only
        pac_ver=$(pacman -Q "$pkg" 2>/dev/null | awk '{print $2}')
        mise_ver=$(mise current "$tool" 2>/dev/null | awk '{print $1}' || echo "?")
        pac_overlap+=("$pkg|$tool|$pac_ver|${mise_ver:-?}")
    done

    if [[ ${#pac_overlap[@]} -eq 0 ]]; then
        log_okay "No explicitly-installed pacman/AUR packages overlap with mise tools."
    else
        log_warn "Provided by both a pacman/AUR package and mise:"
        echo ""
        for entry in "${pac_overlap[@]}"; do
            IFS='|' read -r pkg tool pac_ver mise_ver <<<"$entry"
            printf "  %-20s (%-14s pacman: %-12s mise: %s)\n" "$pkg" "$tool" "$pac_ver" "$mise_ver"
        done
        echo ""
        log_info "mise shims already take PATH precedence; removing these reclaims disk"
        log_info "and avoids stale-version confusion. paru will refuse any package still"
        log_info "required by other software (reported and skipped, not forced)."
        if confirm "Uninstall the pacman/AUR versions?"; then
            remover="paru"
            command -v paru &>/dev/null || remover="sudo pacman"
            for entry in "${pac_overlap[@]}"; do
                IFS='|' read -r pkg _ _ _ <<<"$entry"
                log_info "Removing ${pkg}..."
                $remover -Rs --noconfirm "$pkg" || log_warn "  Skipped ${pkg} (likely still required by another package)."
            done
            log_okay "Pacman/AUR duplicates processed."
        else
            log_info "Skipped pacman uninstall."
        fi
    fi
fi

echo ""

# ── Step 4: Reconcile mise ───────────────────────────────────────────────────
log_section "Reconcile mise"

if confirm "Run 'mise install' now?" true; then
    mise install
    log_okay "mise installations are up to date."
else
    log_info "Skipped 'mise install'. Run manually if needed."
fi

echo ""
log_okay "Cleanup complete."
