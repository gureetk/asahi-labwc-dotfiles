#!/usr/bin/env bash
# Dark or light style for apps, like GNOME's "Dark Style" switch. Opened from
# the quick settings panel, the sliders menu or the desktop menu.
#
#   appearance.sh            pick dark or light
#   appearance.sh dark       (or light)
#   appearance.sh toggle     switch to the other one
#   appearance.sh --status   print dark or light
#   appearance.sh --default  dark, unless a style was already chosen (installer)
#
# It sets the same two settings GNOME does, so apps follow it on their own:
#   - color-scheme: GNOME / libadwaita apps, Firefox, Chromium, Electron apps,
#     and websites that offer a dark mode. Most switch straight away.
#   - gtk-theme: older GTK 3 apps (Adwaita or Adwaita-dark). A custom GTK
#     theme you've picked is left alone.
# The desktop itself (bar, menus, title bars, notifications) stays dark.

schema=org.gnome.desktop.interface

get() { gsettings get "$schema" "$1" 2>/dev/null | tr -d "'"; }

current() {
    [ "$(get color-scheme)" = prefer-dark ] && echo dark || echo light
}

set_style() {   # dark | light
    local scheme theme
    if [ "$1" = dark ]; then
        scheme=prefer-dark theme=Adwaita-dark
    else
        # "prefer-light" is newer; older systems only know "default"
        if gsettings range "$schema" color-scheme 2>/dev/null | grep -qx "'prefer-light'"; then
            scheme=prefer-light
        else
            scheme=default
        fi
        theme=Adwaita
    fi
    gsettings set "$schema" color-scheme "$scheme" || return 1
    case "$(get gtk-theme)" in
        Adwaita|Adwaita-dark|"") gsettings set "$schema" gtk-theme "$theme" ;;
    esac
    # Read it back from a new process: without dconf nothing is saved
    [ "$(current)" = "$1" ]
}

apply() {
    if set_style "$1"; then
        notify-send -t 2000 "${1^} style"
    else
        notify-send "Dark / light style" "Couldn't save the setting (is dconf installed?)"
        return 1
    fi
}

if ! command -v gsettings >/dev/null; then
    echo "gsettings is missing (it comes with glib2)" >&2
    exit 1
fi

case "${1:-}" in
    dark|light) apply "$1" ;;
    toggle)     if [ "$(current)" = dark ]; then apply light; else apply dark; fi ;;
    --status)   current ;;
    --default)
        # Untouched means GNOME's out-of-the-box values: no preference + Adwaita.
        # Prints "set" or "kept"; fails if the setting couldn't be saved.
        if [ "$(get color-scheme)" = default ] && [ "$(get gtk-theme)" = Adwaita ]; then
            set_style dark && echo set
        else
            echo kept
        fi ;;
    "")
        labels=("Dark" "Light")
        if [ "$(current)" = dark ]; then labels[0]+="  ✓"; else labels[1]+="  ✓"; fi
        choice=$(printf '%s\n' "${labels[@]}" |
            fuzzel --dmenu --index --no-sort --prompt "Style ❯ " --width 24 --lines 2) || exit 0
        case "$choice" in
            0) apply dark ;;
            1) apply light ;;
        esac ;;
    -h|--help) sed -n '5,9p' "$0" | sed 's/^# \{0,1\}//' ;;
    *) sed -n '5,9p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 1 ;;
esac
