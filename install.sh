#!/usr/bin/env bash
# Installs the labwc desktop on Fedora Asahi Remix (any edition, including
# Minimal with no desktop at all).
#
#   ./install.sh                  install packages, then copy the configs
#   ./install.sh --no-packages    copy the configs only (packages already installed)
#   ./install.sh --greetd         also set up the greetd login screen (needed on Minimal)
#
# Flags can be combined. Existing configs are backed up to
# ~/.config/<name>.bak-<date> first; other files in those folders are left alone.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cfg="${XDG_CONFIG_HOME:-$HOME/.config}"
stamp="$(date +%Y%m%d-%H%M%S)"
dirs=(labwc waybar fuzzel mako swaylock)

install_packages=1
setup_greetd=0
for arg in "$@"; do
    case "$arg" in
        --no-packages) install_packages=0 ;;
        --greetd)      setup_greetd=1 ;;
        -h|--help)     sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)             echo "Unknown option: $arg (try --help)" >&2; exit 1 ;;
    esac
done

packages=(
    # window manager (labwc, plus labwc-session, which lists it on login
    # screens), idle, lock, wallpaper, screen off, display scale
    labwc labwc-session swayidle swaylock swaybg wlopm wlr-randr
    # bar, launcher, notifications, terminal
    waybar fuzzel mako foot
    # fonts and icons (bar icons, app icons in the taskbar and title bars)
    fontawesome-fonts-all default-fonts-core-sans default-fonts-core-mono
    default-fonts-core-emoji dejavu-sans-fonts dejavu-sans-mono-fonts
    adwaita-icon-theme hicolor-icon-theme
    # basics a Minimal install may not have: graphics, X11 apps, sound,
    # Bluetooth, Wi-Fi, password prompts (usually already installed)
    mesa-dri-drivers xorg-x11-server-Xwayland pipewire pipewire-pulseaudio
    pipewire-alsa wireplumber bluez NetworkManager-wifi polkit
    # Mac speakers (usually already installed)
    asahi-audio speakersafetyd
    # brightness, volume, media keys
    brightnessctl playerctl
    # settings windows opened from the bar
    pavucontrol blueman NetworkManager-tui nm-connection-editor
    # screenshots and notifications from scripts
    grim slurp wl-clipboard libnotify xdg-user-dirs
    # password prompts for apps, screen sharing, file pickers
    lxpolkit xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
    # quick settings panel (sliders, battery, power mode)
    python3-gobject gtk3 gtk-layer-shell upower
    # saved app settings (title bar buttons, dark / light style) and the
    # dark theme for older GTK 3 apps
    dconf gsettings-desktop-schemas gnome-themes-extra
    # bigger text on the login screen and text consoles
    terminus-fonts-console
)

if (( install_packages || setup_greetd )); then
    echo "==> Installing packages (asks for your password)"
    if dnf --version 2>/dev/null | grep -qi dnf5; then
        skip=(--skip-unavailable)
    else
        skip=(--setopt=strict=0)
    fi
    if (( install_packages )); then
        sudo dnf install -y "${skip[@]}" "${packages[@]}"
    fi
    if (( setup_greetd )); then
        sudo dnf install -y "${skip[@]}" greetd tuigreet terminus-fonts-console
    fi
fi

echo "==> Copying configs to $cfg"
for d in "${dirs[@]}"; do
    if [[ -e "$cfg/$d" ]]; then
        cp -a "$cfg/$d" "$cfg/$d.bak-$stamp"
        echo "    backed up $cfg/$d -> $d.bak-$stamp"
    fi
    mkdir -p "$cfg/$d"
    cp -r "$here/config/$d/." "$cfg/$d/"
done
chmod +x "$cfg/labwc/scripts/"*.sh "$cfg/labwc/scripts/"*.py "$cfg/waybar/scripts/"*.sh

# Refresh the font cache so the bar icons show up right away
fc-cache -f >/dev/null 2>&1 || true

# Apps that draw their own title bars (browsers, GNOME and GTK apps) follow
# GNOME's button setting, whose default shows only the close button. Show
# minimize, maximize and close, like labwc's own title bars. A layout you've
# already changed is left alone.
key=(org.gnome.desktop.wm.preferences button-layout)
layout=":minimize,maximize,close"
if command -v gsettings >/dev/null &&
   [[ "$(gsettings get "${key[@]}" 2>/dev/null)" == "'appmenu:close'" ]]; then
    gsettings set "${key[@]}" "$layout" 2>/dev/null || true
    # Read it back from a new process: without dconf the change isn't saved
    if [[ "$(gsettings get "${key[@]}" 2>/dev/null)" == "'$layout'" ]]; then
        echo "==> App title bars now show minimize, maximize and close"
    else
        echo "==> Couldn't save the app title bar buttons. Once dconf is installed, run:"
        echo "    gsettings set ${key[*]} '$layout'"
    fi
fi

# Apps use the dark style to match the desktop, unless a style was already
# chosen. Switch any time: quick settings panel -> Dark style.
if command -v gsettings >/dev/null; then
    style=$("$cfg/labwc/scripts/appearance.sh" --default 2>/dev/null || echo failed)
    case "$style" in
        set)  echo "==> Apps now use the dark style (switch it in the quick settings panel)" ;;
        kept) ;;
        *)    echo "==> Couldn't save the dark style. Once dconf is installed, run:"
              echo "    ~/.config/labwc/scripts/appearance.sh dark" ;;
    esac
fi

echo "==> Checking the labwc config"
if command -v xmllint >/dev/null; then
    if xmllint --noout "$cfg/labwc/rc.xml" "$cfg/labwc/menu.xml" 2>/dev/null; then
        echo "    rc.xml and menu.xml OK"
    else
        echo "    rc.xml or menu.xml has a mistake; run this to see it:"
        echo "    xmllint --noout $cfg/labwc/rc.xml $cfg/labwc/menu.xml"
    fi
else
    echo "    (xmllint not installed, skipped)"
fi

if (( setup_greetd )); then
    echo "==> Setting up the greetd login screen"
    conf=/etc/greetd/config.toml

    # Use the greeter account Fedora's greetd package created
    greeter=greetd
    if [[ -f "$conf" ]]; then
        found=$(sudo sed -n 's/^[[:space:]]*user[[:space:]]*=[[:space:]]*"\(.*\)".*/\1/p' "$conf" | head -1 || true)
        [[ -n "$found" ]] && greeter="$found"
        sudo cp -a "$conf" "$conf.bak-$stamp"
        echo "    backed up $conf -> config.toml.bak-$stamp"
    fi
    if ! id "$greeter" >/dev/null 2>&1; then
        echo "    The greeter account '$greeter' doesn't exist; is greetd installed?" >&2
        echo "    Leaving your current login screen alone." >&2
        exit 1
    fi

    sudo mkdir -p /etc/greetd
    sudo tee "$conf" >/dev/null <<EOF
# Written by the labwc dotfiles install.sh. The old file is next to this one as .bak-<date>.
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --remember-session --asterisks --cmd labwc"
user = "$greeter"
EOF
    # tuigreet keeps the last user and session here (for --remember)
    sudo install -d -o "$greeter" -g "$greeter" -m 755 /var/cache/tuigreet

    # Bigger login screen text. tuigreet runs on the text console, whose
    # default font is tiny on a Retina screen, so use a Terminus console font
    # the same size as the 150% display scale. Change it later from the
    # quick-settings menu: Display scale -> Login screen text size.
    vconsole=/etc/vconsole.conf
    font=""
    for f in /usr/lib/kbd/consolefonts/ter-{v,u,i,1}24n.psf*; do
        if [[ -e "$f" ]]; then font=${f##*/}; font=${font%%.*}; break; fi
    done
    if grep -qs '^FONT="\{0,1\}ter-' "$vconsole"; then
        echo "    login screen text size already set in $vconsole"
    elif [[ -z "$font" ]]; then
        echo "    Terminus console fonts not found, so the login screen text stays small"
    else
        if [[ -f "$vconsole" ]]; then
            sudo cp -a "$vconsole" "$vconsole.bak-$stamp"
            echo "    backed up $vconsole -> vconsole.conf.bak-$stamp"
        fi
        if grep -qs '^FONT=' "$vconsole"; then
            sudo sed -i "s/^FONT=.*/FONT=\"$font\"/" "$vconsole"
        else
            echo "FONT=\"$font\"" | sudo tee -a "$vconsole" >/dev/null
        fi
        echo "    login screen text set to 150% ($font in $vconsole)"
    fi

    # Switch the login screen: turn off the current one (e.g. gdm or sddm),
    # turn on greetd
    current=$(systemctl show -p Id --value display-manager.service 2>/dev/null || true)
    previous=""
    if [[ -n "$current" && "$current" != "greetd.service" && "$current" != "display-manager.service" ]]; then
        previous="$current"
        sudo systemctl disable "$current"
        echo "    disabled $current"
    fi
    sudo systemctl enable greetd.service

    # Minimal installs start in text mode, where no login screen runs
    old_target=$(systemctl get-default 2>/dev/null || echo multi-user.target)
    if [[ "$old_target" != "graphical.target" ]]; then
        sudo systemctl set-default graphical.target
        echo "    the Mac now starts in graphical mode (was $old_target)"
    fi
    echo "    greetd will show the login screen from the next reboot"

    if [[ -n "$previous" ]]; then
        undo="sudo systemctl disable greetd && sudo systemctl enable $previous"
    else
        undo="sudo systemctl disable greetd && sudo systemctl set-default $old_target"
    fi
    cat <<EOF

    If the login screen doesn't appear after rebooting, press
    Ctrl+Option+F3 (hold fn too if needed), log in, and run:
        $undo
    then reboot.
EOF
fi

cat <<'EOF'

Done. To start the desktop:
  - with --greetd: reboot, then log in at the new login screen
  - from a text console: type  labwc
  - from another desktop: log out and pick labwc at the login screen

Command and Control are swapped: Control is the desktop shortcut key,
Command copies and pastes like Ctrl on other computers.

  Ctrl+?                   list of every shortcut (type to search)
  Ctrl+D or Ctrl+Space     app launcher
  Ctrl+Enter               terminal
  Option+Tab               switch windows
  Right-click the desktop  desktop menu
  Sliders icon (top right) quick settings

Undo: delete ~/.config/{labwc,waybar,fuzzel,mako,swaylock} and rename the
.bak-<date> folders back.
EOF
