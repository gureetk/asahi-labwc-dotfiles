# Lean labwc Desktop for Apple Silicon Macs

A traditional desktop for M-series Macs running
[Fedora Asahi Remix](https://asahilinux.org/fedora/), built to use as little
memory as possible: windows you drag, resize and overlap like on GNOME, KDE
or macOS, with title bars, a taskbar, workspaces and a desktop menu, plus a
top bar with GNOME-style quick settings, an app launcher, notifications, a
lock screen, screenshots and a wallpaper picker. Command and Control are
swapped, so Cmd+C and Cmd+V work like on macOS.

It's the stacking-window version of
[asahi-dotfiles](https://codeberg.org/gureetk/asahi-dotfiles), which does the
same with the sway tiling window manager. The window manager here is
[labwc](https://labwc.github.io), a small Wayland compositor in the spirit of
Openbox.

<!-- Add a screenshot: press Ctrl+Cmd+Shift+S, copy the file from
     ~/Pictures/Screenshots into this repo as screenshot.png, and
     uncomment the line below. -->
<!-- ![Desktop](screenshot.png) -->

## Why

On an 8 GB Mac every gigabyte matters. Measured on an M1 with 8 GB, idle
right after logging in:

<!-- TODO: fresh boot, log in, wait a minute, run `free -h`, and put the
     "used" number in the "This setup" row -->
| Desktop | RAM used at idle |
|---|---|
| GNOME (Fedora Asahi Remix default) | 2.73 GB |
| Stock sway | 1.07 GB |
| asahi-dotfiles (sway) | 1.1 GB |
| This setup | — |

Most of the savings come from not running things until you need them:

| Always running | Starts only when you use it |
|---|---|
| labwc (windows, title bars, menus) | fuzzel (launcher, Wi-Fi / Bluetooth / sound pickers, shortcut list) |
| waybar (top bar, taskbar, drop-downs) | foot (terminal) |
| mako (notifications and the volume / brightness pop-up) | pavucontrol, blueman, nm-connection-editor (full settings windows) |
| swaybg (wallpaper) | swaylock (lock screen) |
| swayidle + a small script (screen off, lock, auto-sleep) | the quick settings panel: sliders, battery, power mode (about 45 MB, only while open) |
| lxpolkit (password prompts) | grim + slurp (screenshots) |

The `~/.config/labwc/autostart` file starts everything in the left column, so
that's the one place to look for what's running.

Choices made to keep it small:

- **labwc for the windows** instead of GNOME Shell or KWin. It draws title
  bars, menus and the Alt+Tab switcher itself and leaves the rest to small
  separate programs.
- **Mako for notifications** instead of SwayNotificationCenter, which pulls in
  GTK4 and libadwaita.
- **The drop-downs are Waybar's own built-in menus**, so there's no separate
  panel process sitting in memory. Picking a Wi-Fi network, Bluetooth device
  or sound output opens a fuzzel list that closes as soon as you choose.
- **The quick settings panel only exists while it's open.** Clicking the
  volume, brightness or battery icon starts it, and closing it frees its
  memory again.
- **The volume / brightness pop-up is a mako notification** that replaces
  itself, instead of a separate on-screen-display program.
- **No tray applets** (nm-applet, blueman-applet). Full settings windows only
  start when you ask for them, and close when you're done.
- **greetd + tuigreet login screen** instead of GDM, which runs a whole GNOME
  Shell just to show the login screen.

Two Asahi notes when comparing numbers: Asahi uses 16K memory pages, so the
same programs read a bit higher than on an x86 laptop, and Fedora enables
zram swap by default, so 8 GB stretches further than it looks.

## Requirements

- A Mac that [Fedora Asahi Remix](https://asahilinux.org/fedora/) supports
- Fedora Asahi Remix installed. **Minimal** (no desktop) is the leanest
  starting point; GNOME or KDE also work, stay installed, and you can still
  pick them at login.
- labwc 0.9 and Waybar 0.14 or newer (Fedora 43 and later have both)

The installer uses `dnf`. On another distro, install the packages listed at
the top of `install.sh` yourself and copy the `config/` folders into
`~/.config/`.

## Install

<!-- TODO: put this repo's address in the first line -->
```
git clone https://codeberg.org/gureetk/YOUR-REPO.git
cd YOUR-REPO
./install.sh --greetd
```

| Command | What it does |
|---|---|
| `./install.sh` | Installs the packages, then copies the configs |
| `./install.sh --no-packages` | Copies the configs only. Use this to update after the packages are already installed |
| `./install.sh --greetd` | Also sets up the greetd + tuigreet login screen, with text sized for the Retina screen, and makes the Mac start in graphical mode (needed on Minimal; replaces GDM or SDDM on GNOME or KDE). Takes effect after a reboot |

Flags can be combined, e.g. `./install.sh --no-packages --greetd`.

On **Minimal**, connect to Wi-Fi first with
`nmcli device wifi connect "Network name" --ask` and install git with
`sudo dnf install git`. After installing, reboot and log in at the new login
screen. To try it without a login screen, type `labwc` after logging in at the
text console.

Your existing configs are backed up to `~/.config/<name>.bak-<date>` before
anything is copied, and other files in those folders are left alone.
`--greetd` also backs up `/etc/greetd/config.toml` and `/etc/vconsole.conf`,
and prints how to undo it if the login screen doesn't come up.

This setup uses the same `waybar`, `mako`, `fuzzel` and `swaylock` folders as
the sway version, so installing one replaces the other's copies of those
(they're backed up). Use one per user account.

## Windows

| To | Do |
|---|---|
| Move a window | Drag its title bar, or Ctrl+drag anywhere inside it |
| Resize | Drag an edge or corner, or Ctrl+right-drag anywhere inside it |
| Maximize / restore | Double-click the title bar, the □ button, or Ctrl+Up |
| Fill half the screen | Drag to the left or right edge, or Ctrl+Left / Ctrl+Right |
| Fill a quarter | Drag to a corner |
| Minimize | The – button or Ctrl+M; click its icon in the taskbar to bring it back |
| Close | The × button, Ctrl+Shift+Q or Option+F4 |
| Switch windows | Option+Tab or Ctrl+Tab, or click the taskbar |
| Window menu | Right-click the title bar or press Option+Space (always on top, move to workspace...) |
| Desktop menu | Right-click the desktop |

New windows open in the middle of the screen. There are four workspaces:
Ctrl+1 … Ctrl+4, the numbers on the bar, or scroll on the desktop.

## Keyboard

**Command and Control are swapped.** The **Control** key is for desktop
shortcuts, and **Command** acts like Ctrl does on other computers: Cmd+C
copies, Cmd+V pastes, Cmd+T opens a tab, Cmd+Q quits. Key names below are the
printed keys on the Mac keyboard.

Press **Ctrl+?** (Ctrl+Shift+/) at any time for a searchable list of every
shortcut.

| Keys | Action |
|---|---|
| Ctrl+? | Shortcut list (type to search, Esc to close) |
| Ctrl+D or Ctrl+Space | App launcher |
| Ctrl+Enter | Terminal |
| Ctrl+Shift+Q | Close window |
| Ctrl+Shift+E | Power menu |
| Ctrl+Cmd+Q | Lock (same as macOS) |
| Ctrl+Shift+C | Reload labwc and the bar |
| Cmd+C / X / V / Z | Copy / cut / paste / undo in apps |
| Cmd+Shift+C / V | Copy / paste in the terminal (Cmd+C stops a command there) |
| Option+Tab or Ctrl+Tab | Switch windows (add Shift to go backwards) |
| Ctrl+Up / Ctrl+Down | Maximize / back to normal size |
| Ctrl+Left / Ctrl+Right | Left / right half of the screen |
| Ctrl+M / Ctrl+F | Minimize / fullscreen |
| Ctrl+Shift+T | Keep the window above others |
| Ctrl+1…4 / Ctrl+Shift+1…4 | Go to / send window to workspace |
| Ctrl+Option+Left / Right | Previous / next workspace |
| Ctrl+Shift+S | Screenshot an area (Ctrl+Cmd+Shift+S: whole screen) |
| Ctrl+Shift+W | Change wallpaper |
| Ctrl+N | Do Not Disturb on/off |

The top-row brightness, keyboard light, media and volume keys work as on
macOS, also on the lock screen. Screenshots are saved to
`~/Pictures/Screenshots` and copied to the clipboard.

Prefer the normal layout? Delete the `XKB_DEFAULT_OPTIONS` line in
`~/.config/labwc/environment` and log out and back in. The shortcuts then move
to the Command key.

## The bar

| Where | What | Click | Right-click / scroll |
|---|---|---|---|
| Far left | Apps grid | Open the launcher | |
| Left | Workspaces 1–4 | Switch | |
| Left | Taskbar (one icon per window) | Switch to it; click the active one to minimize | Middle-click: close |
| Middle | Clock | Recent notifications (hover for a calendar) | Scroll: change the calendar month. Right-click: year view |
| Middle | Muted bell | Only shows during Do Not Disturb; click to end it | |
| Right | Wi-Fi | Menu: choose a network, Wi-Fi on/off, network settings | |
| Right | Bluetooth | Menu: connect a device, Bluetooth on/off, pair a new device | Right-click: Bluetooth on/off |
| Right | Volume | Quick settings panel (see below) | Scroll: volume. Right-click: mute |
| Right | Sun | The same panel | Scroll: brightness |
| Right | Battery | The same panel | Hover: time left |
| Far right | Sliders | Quick settings: Wi-Fi, Bluetooth, sound, on/off toggles, Do Not Disturb, screenshot, wallpaper, display scale, shortcuts, power & sleep, lock, suspend, log out, reboot, shut down | |

The **quick settings panel** drops down under the icons, like GNOME's:

- Volume slider (the speaker button mutes) and brightness slider
- Battery level with the estimated time left, or time until full while charging
- Power mode: Power Saver, Balanced or Performance. This needs Fedora's
  `tuned-ppd` (installed with GNOME and KDE) or `power-profiles-daemon`;
  without either, the row is hidden. Both run a small background service,
  so they aren't installed on Minimal by default.
- Buttons for output device, microphone, keyboard light and sound settings

Click anywhere outside it, click the icon again or press Esc to close it.

Changing the volume or brightness, with the keys or by scrolling on the
icons, shows a small pop-up at the bottom of the screen with the new level,
like GNOME. It also shows during Do Not Disturb.

The brightness and battery icons hide themselves on Macs without them
(Mac mini, Mac Studio).

## Sleep, lid and power button

Works like GNOME:

- **Closing the lid** locks the screen and puts the Mac to sleep. Opening it
  shows the lock screen (your wallpaper with a blue ring): type your password
  and press Enter.
- **A short press of the power button** also locks and sleeps. Pressing it to
  wake the Mac won't send it straight back to sleep.
- **Holding the power button** still forces the Mac off; that's the Mac
  itself, not this config.
- **When idle**, the screen locks and turns off, and later the Mac goes to
  sleep, with separate timers on battery and plugged in (see below). Videos
  playing in a browser or a video player keep the screen on.

Without this, systemd's default for the power button is to shut down
immediately; GNOME normally overrides that, and here labwc does the same while
it's running.

### Power & sleep settings

Open the sliders icon menu → **Power & sleep settings…** (or right-click the
desktop) to change:

| Setting | Default |
|---|---|
| Screen off on battery | 5 minutes |
| Sleep on battery | 15 minutes |
| Screen off when plugged in | 10 minutes |
| Sleep when plugged in | Never |
| Lock when the screen turns off | Yes |

Changes apply immediately, and switching between battery and charger is
picked up within about 15 seconds. The settings are saved in
`~/.config/labwc/power.conf`, which you can also edit by hand (then run
`~/.config/labwc/scripts/idle.sh --reload`). Re-running the installer keeps
your settings. To see what's active right now, run
`~/.config/labwc/scripts/idle.sh --status`.

## Wallpaper

Press **Ctrl+Shift+W** (or use the sliders or desktop menu) to pick an image
from `~/Pictures` or Fedora's built-in wallpapers. Keep your own in
`~/Pictures/Wallpapers` so they're easy to find. From a terminal:

```
~/.config/labwc/scripts/wallpaper.sh ~/Downloads/photo.jpg       # fill the screen
~/.config/labwc/scripts/wallpaper.sh ~/Downloads/photo.jpg fit   # or center, tile, stretch
~/.config/labwc/scripts/wallpaper.sh none                        # plain dark background
```

The image is copied into `~/.config/labwc/`, so it stays after reboots even if
the original is moved or deleted. JPG and PNG work. The lock screen uses the
same image.

## Display scale

Open the sliders icon menu → **Display scale…** to make everything bigger or
smaller: 100%, 125%, 150% (the default), 175% or 200%. It changes right away
and is saved in `~/.config/labwc/scale.conf`. From a terminal:
`~/.config/labwc/scripts/scale.sh 175%`.

**Login screen text.** The greetd login screen runs on the text console, so
it doesn't follow the display scale; its size comes from the console font.
`./install.sh --greetd` sets it to 150%. To change it, pick **Login screen
text size…** at the bottom of the Display scale menu. It asks for your
password and shows from the next restart. If you've encrypted the disk, also
run `sudo dracut -f --regenerate-all` once so the passphrase prompt at startup
uses the new size too.

## Customizing

| To change | Edit |
|---|---|
| Keyboard shortcuts, mouse, touchpad, window snapping, workspaces | `~/.config/labwc/rc.xml` |
| Title bar, menu and window switcher colors | `~/.config/labwc/themerc-override` |
| Title bar buttons and fonts | `<theme>` in `~/.config/labwc/rc.xml` |
| Desktop (right-click) menu | `~/.config/labwc/menu.xml` |
| What starts at login | `~/.config/labwc/autostart` |
| Command / Control swap, mouse pointer | `~/.config/labwc/environment` (log out and back in after editing) |
| Display scale | Sliders menu → Display scale (saved in `~/.config/labwc/scale.conf`) |
| Login screen text size | Sliders menu → Display scale → Login screen text size (or the `FONT=` line in `/etc/vconsole.conf`) |
| Screen-off, lock and sleep timers | Sliders menu → Power & sleep settings (or `~/.config/labwc/power.conf`) |
| Power button | `~/.config/labwc/scripts/power-button.sh` (e.g. change `suspend` to show the power menu) |
| Bar colors | The `@define-color` lines at the top of `~/.config/waybar/style.css` |
| Bar contents | `~/.config/waybar/config.jsonc` |
| Quick-settings menu items | `~/.config/waybar/control_menu.xml` plus `menu-actions` in `config.jsonc` |
| Drop-down menu items | `~/.config/waybar/*_menu.xml` plus that icon's `menu-actions` in `config.jsonc` |
| Shortcut list | `~/.config/labwc/keybinds.txt` (update it when you change a binding) |
| Launcher look | `~/.config/fuzzel/fuzzel.ini` |
| Notification and pop-up look | `~/.config/mako/config` (the pop-up is the `[app-name=osd]` section) |
| Quick settings panel look and buttons | The `CSS` block and buttons in `~/.config/labwc/scripts/quick-panel.py` |
| Lock screen colors | `~/.config/swaylock/config` |

The same palette is used everywhere: background `#16161e`, accent `#7aa2f7`.
Search and replace those two across the files to retheme. Press Ctrl+Shift+C
after editing. Every labwc option: `man 5 labwc-config`, `man 5 labwc-theme`.

## Repo layout

```
install.sh                 installer (packages, configs, login screen)
config/
  labwc/rc.xml             windows, keyboard shortcuts, mouse, touchpad
  labwc/menu.xml           the right-click desktop menu
  labwc/autostart          everything that runs in the background
  labwc/environment        Command / Control swap, mouse pointer
  labwc/themerc-override   title bar, menu and switcher colors
  labwc/keybinds.txt       the Ctrl+? shortcut list
  labwc/scripts/           quick settings panel (quick-panel.py), idle / power settings,
                           pop-up (osd.sh), Wi-Fi / Bluetooth / sound pickers,
                           power menu, screenshots, toggles, wallpaper, display scale,
                           shortcut list
  waybar/                  bar layout, style, and the drop-down menus (*_menu.xml)
  fuzzel/fuzzel.ini        launcher
  mako/config              notifications
  swaylock/config          lock screen
```

## Keeping memory low

- Check what's using memory: `ps -eo rss,comm --sort=-rss | head -20`
  (RSS is in KB).
- Starting from **Minimal** avoids GNOME's or KDE's background services. If
  you installed on top of GNOME and they show up in a labwc session
  (`gnome-software`, `evolution-*`, `localsearch`), disable or remove them.
- `systemctl list-units --type=service --state=running` lists the system
  services; turn off ones you don't use.
- Measure the same way every time: fresh boot, log in, wait a minute, then
  `free -h`. Different tools (htop, btop, GNOME System Monitor) count memory
  differently.
- Your browser will use more memory than everything here combined. Fewer
  open tabs helps more than any desktop tweak.

## Troubleshooting

**Bar icons show as boxes.** Check the icon font is installed with
`fc-list | grep -i awesome`. If nothing shows, run
`sudo dnf install fontawesome-fonts-all && fc-cache -f`, then Ctrl+Shift+C.

**Bar didn't appear.** Run `waybar` in a terminal; it prints the line it
doesn't like.

**No workspace numbers on the bar.** They need Waybar 0.14 or newer and labwc
0.9 or newer: check with `waybar --version` and `labwc --version`.

**A shortcut does nothing.** labwc skips lines in `rc.xml` it doesn't
understand. To see which: log out, switch to a text console (Ctrl+Option+F3),
log in and run `labwc 2>&1 | grep -i error`, then log out again from the
sliders menu.

**An app says there's no authentication agent.** Check lxpolkit is
running: `pgrep -a lxpolkit`.

**Black screen after opening the lid.** First type your password and press
Enter: if the screen comes back, it was the lock screen. If it stays black,
hold the power button to turn the Mac off, start it again, and run
`journalctl -b -1 -e | grep -iE 'swaylock|swayidle|suspend|resume'` to see what
happened during the last sleep.

**Login screen didn't come up after `--greetd`.** Press Ctrl+Option+F3
(hold fn too if needed), log in, then run the undo command the installer
printed (`sudo systemctl disable greetd`, plus re-enabling your old login
screen or text mode) and reboot.

## Uninstall

Delete `~/.config/{labwc,waybar,fuzzel,mako,swaylock}` and rename the
`.bak-<date>` folders back. If you installed on top of GNOME or KDE, they're
untouched, so you can pick them at the login screen any time.

## Credits

Built on [labwc](https://labwc.github.io), [Waybar](https://github.com/Alexays/Waybar),
[fuzzel](https://codeberg.org/dnkl/fuzzel), [mako](https://github.com/emersion/mako),
[swaylock](https://github.com/swaywm/swaylock),
[gtk-layer-shell](https://github.com/wmww/gtk-layer-shell) and
[Font Awesome](https://fontawesome.com) icons, on top of the
[Asahi Linux](https://asahilinux.org) project. Colors adapted from the
Tokyo Night palette.
