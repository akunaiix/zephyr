#!/usr/bin/env bash
#
# Zephyr uninstaller.
# Removes symlinks/copies and restores the latest backup if available.

set -euo pipefail

CONFIG_DST="$HOME/.config"
COMPONENTS=(niri waybar fuzzel mako gtklock swayosd foot)

c_reset='\033[0m'
c_red='\033[0;31m'
c_green='\033[0;32m'
c_yellow='\033[0;33m'
c_blue='\033[0;34m'

info()  { printf "${c_blue}::${c_reset} %s\n" "$*"; }
ok()    { printf "${c_green}ok${c_reset} %s\n" "$*"; }
warn()  { printf "${c_yellow}!!${c_reset} %s\n" "$*" >&2; }

info "Uninstalling Zephyr configs"

# Find latest backup
BACKUP_DIR=$(find "$CONFIG_DST" -maxdepth 1 -type d -name "zephyr-backup-*" | sort | tail -n 1 || true)

if [[ -n "$BACKUP_DIR" ]]; then
    info "Found backup: $BACKUP_DIR"
else
    warn "No backup found. Your configs will be removed without restoration."
fi

for d in "${COMPONENTS[@]}"; do
    dst="$CONFIG_DST/$d"
    
    if [[ -L "$dst" ]]; then
        rm "$dst"
        ok "Removed symlink: $d"
    elif [[ -d "$dst" ]]; then
        warn "$d is a real directory (not a Zephyr symlink). Skipping to be safe."
        continue
    fi
    
    # Restore from backup if it exists
    if [[ -n "$BACKUP_DIR" && -e "$BACKUP_DIR/$d" ]]; then
        mv "$BACKUP_DIR/$d" "$CONFIG_DST/$d"
        ok "Restored from backup: $d"
    fi
done

if [[ -n "$BACKUP_DIR" ]]; then
    info "Backup dir left at: $BACKUP_DIR (delete it manually if no longer needed)"
fi

info "Zephyr configs uninstalled."
info "Note: packages installed by apt (waybar, fuzzel, etc.) were NOT removed."
