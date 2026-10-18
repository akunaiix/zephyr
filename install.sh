#!/usr/bin/env bash
#
# Zephyr installer.
# Installs packages, backs up old configs, links new ones.
# Run as a regular user, not root.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$REPO_DIR/config"
CONFIG_DST="$HOME/.config"
BACKUP_DIR="$CONFIG_DST/zephyr-backup-$(date +%Y%m%d-%H%M%S)"
PACKAGE_LIST="$REPO_DIR/packages/debian.list"

DRY_RUN=0
INSTALL_PACKAGES=1
USE_SYMLINKS=1
KEEP_NIRI=0
ASSUME_YES=0

# --- output ---

c_reset='\033[0m'
c_red='\033[0;31m'
c_green='\033[0;32m'
c_yellow='\033[0;33m'
c_blue='\033[0;34m'
c_bold='\033[1m'

info()  { printf "${c_blue}::${c_reset} %s\n" "$*"; }
ok()    { printf "${c_green}ok${c_reset} %s\n" "$*"; }
warn()  { printf "${c_yellow}!!${c_reset} %s\n" "$*" >&2; }
die()   { printf "${c_red}xx${c_reset} %s\n" "$*" >&2; exit 1; }

# In dry-run mode print the command instead of running it.
run() {
    if (( DRY_RUN )); then
        printf "${c_yellow}[dry-run]${c_reset} %s\n" "$*"
    else
        "$@"
    fi
}

# --- args ---

usage() {
    cat <<EOF
Zephyr installer

Usage: ./install.sh [options]

Options:
  --dry-run        Show what would be done, change nothing
  --no-packages    Skip package installation (configs still get linked)
  --copy           Copy configs instead of symlinking
  --keep-niri      Leave existing ~/.config/niri untouched
  --yes            Do not ask for confirmation
  -h, --help       Show this help
EOF
}

parse_args() {
    while (( $# )); do
        case "$1" in
            --dry-run)      DRY_RUN=1 ;;
            --no-packages)  INSTALL_PACKAGES=0 ;;
            --copy)         USE_SYMLINKS=0 ;;
            --keep-niri)    KEEP_NIRI=1 ;;
            --yes)          ASSUME_YES=1 ;;
            -h|--help)      usage; exit 0 ;;
            *)              die "Unknown argument: $1 (see --help)" ;;
        esac
        shift
    done
}

# --- checks ---

check_env() {
    info "Checking environment"

    if [[ "$(id -u)" -eq 0 ]]; then
        die "Do not run as root. The installer will ask for sudo when needed."
    fi

    if [[ -z "${WAYLAND_DISPLAY:-}" ]] && [[ "${XDG_SESSION_TYPE:-}" != "wayland" ]]; then
        die "Wayland session required (WAYLAND_DISPLAY and XDG_SESSION_TYPE both unset). Log into niri and retry."
    fi
    command -v niri >/dev/null || die "niri not found in PATH. Install niri first."
    command -v apt  >/dev/null || die "apt not found. This installer is for Debian."

    [[ -f "$PACKAGE_LIST" ]] || die "Missing $PACKAGE_LIST - repo is broken?"

    ok "environment ok"
}

# --- backup ---

backup_configs() {
    local dirs=(niri waybar fuzzel mako gtklock swayosd foot)
    local found=0

    info "Backing up existing configs"

    for d in "${dirs[@]}"; do
        [[ -e "$CONFIG_DST/$d" ]] || continue
        if (( KEEP_NIRI )) && [[ "$d" == "niri" ]]; then
            warn "niri: skipped (--keep-niri)"
            continue
        fi
        found=1
        run mkdir -p "$BACKUP_DIR"
        run mv "$CONFIG_DST/$d" "$BACKUP_DIR/$d"
        ok "$d -> $BACKUP_DIR/$d"
    done

    if (( ! found )); then
        info "nothing to back up - no existing configs"
    fi
}

# --- packages ---

install_packages() {
    if (( ! INSTALL_PACKAGES )); then
        info "Packages: skipped (--no-packages)"
        return
    fi

    info "Installing packages from packages/debian.list"

    local pkgs
        pkgs=$(grep -vE '^\s*(#|$)' "$PACKAGE_LIST" | tr '\n' ' ')

    if (( DRY_RUN )); then
        printf "${c_yellow}[dry-run]${c_reset} sudo apt install %s\n" "$pkgs"
        return
    fi

    # shellcheck disable=SC2086
    sudo apt install -y $pkgs
    ok "packages installed"
}

# --- symlinks ---
link_configs() {
    info "Linking configs into $CONFIG_DST"

    if [[ ! -d "$CONFIG_SRC" ]] || [[ -z "$(ls -A "$CONFIG_SRC" 2>/dev/null)" ]]; then
        warn "config/ is empty - no configs yet (expected at skeleton stage)"
        return
    fi

    local entry name src dst
    for entry in "$CONFIG_SRC"/*; do
        name=$(basename "$entry")
        src="$entry"
        dst="$CONFIG_DST/$name"

        if (( KEEP_NIRI )) && [[ "$name" == "niri" ]]; then
            warn "niri: skipped (--keep-niri)"
            continue
        fi

        if [[ -e "$dst" && ! -L "$dst" ]]; then
            if (( ! DRY_RUN )); then
                die "$dst exists and is not a symlink. Check $BACKUP_DIR."
            fi
        fi

        run rm -f "$dst"
        if (( USE_SYMLINKS )); then
            run ln -s "$src" "$dst"
        else
            run cp -a "$src" "$dst"
        fi
        ok "$name"
    done
}

# --- main ---

main() {
    parse_args "$@"

    printf "${c_bold}Zephyr installer${c_reset}\n"
    (( DRY_RUN )) && warn "dry-run mode: nothing will be changed"

    check_env
    backup_configs
    install_packages
    link_configs

    printf "\n${c_green}${c_bold}Done.${c_reset}\n"
    printf "Backup (if any): %s\n" "$BACKUP_DIR"
    printf "Next: re-log into niri and check the bar / launcher.\n"
}

main "$@"
