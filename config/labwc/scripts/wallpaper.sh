#!/usr/bin/env bash
# Set the desktop wallpaper. It stays after logging out and rebooting.
#
#   wallpaper.sh                     pick an image (Ctrl+Shift+W does this)
#   wallpaper.sh ~/Downloads/x.jpg   use that image
#   wallpaper.sh ~/x.jpg fit         fill (default), fit, center, tile or stretch
#   wallpaper.sh none                back to the plain dark background
#   wallpaper.sh --restore           show the saved choice (run at login)
#
# The picker lists JPG/PNG images in ~/Pictures (put yours in
# ~/Pictures/Wallpapers) and Fedora's built-in ones in /usr/share/backgrounds.
# The wallpaper is drawn by swaybg, which uses a few MB while it runs.

cfg="${XDG_CONFIG_HOME:-$HOME/.config}/labwc"
conf="$cfg/wallpaper.conf"
pidfile="${XDG_RUNTIME_DIR:-/tmp}/labwc-wallpaper.pid"
plain='#16161e'

# Start swaybg with these arguments, then stop the previous one (in that
# order, so there's no flash of black in between)
show() {
    local old
    old=$(cat "$pidfile" 2>/dev/null)
    setsid -f swaybg "$@" >/dev/null 2>&1
    sleep 0.3
    pgrep -n -x -u "$(id -u)" swaybg > "$pidfile"
    if [ -n "$old" ] && [ "$old" != "$(cat "$pidfile")" ] &&
       [ "$(ps -o comm= -p "$old" 2>/dev/null)" = swaybg ]; then
        kill "$old"
    fi
}

save() { { echo "# Set by wallpaper.sh (Ctrl+Shift+W)"; printf '%s\n' "$@"; } > "$conf"; }

if [ "${1:-}" = --restore ]; then
    image="" mode=fill color=$plain
    if [ -f "$conf" ]; then
        image=$(sed -n 's/^image=//p' "$conf")
        mode=$(sed -n 's/^mode=//p' "$conf"); mode=${mode:-fill}
    fi
    if [ -n "$image" ] && [ -f "$image" ]; then
        show -i "$image" -m "$mode" -c "$color"
    else
        show -c "$color"
    fi
    exit 0
fi

if [ $# -eq 0 ]; then
    pick=$(find "$HOME/Pictures" /usr/share/backgrounds -maxdepth 3 -type f \
               \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) \
               -not -path '*/Screenshots/*' 2>/dev/null |
           sort | sed -e "s|^$HOME/|~/|" -e "s|^/usr/share/backgrounds/|Fedora: |" |
           fuzzel --dmenu --prompt "Wallpaper ❯ " --width 44) || exit 0
    case "$pick" in
        \~/*)       pick="$HOME/${pick#\~/}" ;;
        "Fedora: "*) pick="/usr/share/backgrounds/${pick#Fedora: }" ;;
    esac
    set -- "$pick"
fi

image="$1"
mode="${2:-fill}"

if [ "$image" = "none" ]; then
    save "image="
    show -c "$plain"
    exit 0
fi

if [ ! -f "$image" ]; then
    notify-send "Wallpaper" "Can't find $image"
    exit 1
fi

case "$mode" in
    fill|fit|center|tile|stretch) ;;
    *) echo "mode must be fill, fit, center, tile or stretch" >&2; exit 1 ;;
esac

# Keep a copy, so the wallpaper survives if the original is moved or deleted
mkdir -p "$cfg"
ext="${image##*.}"
saved="$cfg/wallpaper.${ext,,}"
if [ "$(realpath "$image")" != "$(realpath -m "$saved")" ]; then
    rm -f "$cfg"/wallpaper.jpg "$cfg"/wallpaper.jpeg "$cfg"/wallpaper.png
    cp -f "$image" "$saved"
fi

save "image=$saved" "mode=$mode"
show -i "$saved" -m "$mode" -c "$plain"
