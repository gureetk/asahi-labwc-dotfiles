#!/usr/bin/env bash
# Lock the screen. Shows your wallpaper (if you picked one) with the password
# ring always visible, so it's obvious the Mac is locked: just type your
# password and press Enter. Used by Ctrl+Cmd+Q, auto-lock, sleep and the menus.

cfg="${XDG_CONFIG_HOME:-$HOME/.config}/labwc"

# Already locked? Don't start a second lock screen. (Leftover "zombie"
# entries of a lock screen that already exited don't count.)
if ps -C swaylock -o stat= | grep -qv '^Z'; then
    exit 0
fi

image=$(sed -n 's/^image=//p' "$cfg/wallpaper.conf" 2>/dev/null)
if [ -n "$image" ] && [ -f "$image" ]; then
    exec swaylock -f -i "$image" -s fill "$@"
fi
exec swaylock -f "$@"
