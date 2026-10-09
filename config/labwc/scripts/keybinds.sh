#!/usr/bin/env bash
# Searchable shortcut list. Bound to Ctrl+? (Ctrl+Shift+/) and Ctrl+/.
# Type to filter, Esc to close. Edit the list in ~/.config/labwc/keybinds.txt.

list="${XDG_CONFIG_HOME:-$HOME/.config}/labwc/keybinds.txt"

# Pressing the shortcut again closes the list
pkill -x fuzzel && exit 0

fuzzel --dmenu --font monospace:size=11 --prompt "Shortcuts ❯ " \
    --width 84 --lines 20 < "$list" >/dev/null
