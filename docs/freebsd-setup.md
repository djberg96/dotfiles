# FreeBSD 15 Setup

This document describes a practical way to run this ML4W fork on a FreeBSD 15 laptop with Hyprland already installed.

It is written for a user-managed workstation, not for the original ML4W Linux installer flow.

## Scope

The repo does **not** currently ship a native FreeBSD installer.

The supported approach is:

1. Install the packages this config expects.
2. Copy the contents of `dotfiles/` into your home directory.
3. Override the default app launchers in `~/.config/ml4w/settings/` to match the FreeBSD packages you actually use.

## Package Checklist

The package names below were checked against FreeBSD ports/package listings on **May 20, 2026**.

### Core ML4W desktop runtime

Install these first:

```sh
sudo pkg install \
  hyprland \
  hyprlock \
  hyprpaper \
  waybar \
  swaync \
  quickshell \
  wlogout \
  wl-clipboard \
  grim \
  slurp \
  cliphist \
  rofi \
  qt6ct \
  fastfetch \
  btop \
  playerctl \
  pavucontrol \
  foot \
  firefox \
  thunar \
  neovim \
  xdg-utils
```

### Recommended ML4W extras

These enable more of the shipped UI:

```sh
sudo pkg install \
  nwg-dock-hyprland \
  py311-waypaper \
  py311-nwg-displays \
  nwg-look \
  hyprpicker \
  hyprsunset \
  networkmgr
```

### Portals, audio, and policy agent

These are strongly recommended for screensharing, file pickers, notifications, and desktop integration:

```sh
sudo pkg install \
  pipewire \
  wireplumber \
  xdg-desktop-portal \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk \
  polkit \
  mate-polkit
```

### Optional but useful

These power extra scripts:

```sh
sudo pkg install \
  tesseract \
  ImageMagick
```

### One package that may need ports instead of pkg

`hypridle` exists in ports, but package availability can lag depending on branch/build status. Try:

```sh
sudo pkg install hypridle
```

If that fails, build `x11/hypridle` from ports, or temporarily disable the ML4W hypridle integration.

## Services

If Hyprland already works on your system, some of this may already be done.

The most commonly needed FreeBSD services are:

```sh
sudo sysrc dbus_enable=YES
sudo sysrc seatd_enable=YES

sudo service dbus start
sudo service seatd start
```

For user-session multimedia and portals, make sure your session starts PipeWire, WirePlumber, and the XDG portal stack.

## Install The Dotfiles

From a clone of this repo:

```sh
cd ~/path/to/this/repo
rsync -a --backup --suffix='.pre-ml4w' dotfiles/ ~/
```

If you want a safer first pass, only copy the desktop-facing parts:

```sh
cd ~/path/to/this/repo

mkdir -p ~/.config

rsync -a --backup --suffix='.pre-ml4w' \
  dotfiles/.config/hypr \
  dotfiles/.config/waybar \
  dotfiles/.config/swaync \
  dotfiles/.config/wlogout \
  dotfiles/.config/rofi \
  dotfiles/.config/ml4w \
  dotfiles/.config/quickshell \
  dotfiles/.config/waypaper \
  dotfiles/.config/qt6ct \
  ~/.config/
```

## Recommended FreeBSD Launcher Overrides

After copying the dotfiles, set the app commands to match your installed tools:

```sh
printf '%s\n' 'foot' > ~/.config/ml4w/settings/terminal.sh
printf '%s\n' 'firefox' > ~/.config/ml4w/settings/browser.sh
printf '%s\n' 'thunar' > ~/.config/ml4w/settings/filemanager
printf '%s\n' 'nvim' > ~/.config/ml4w/settings/editor.sh
printf '%s\n' 'btop' > ~/.config/ml4w/settings/system-monitor
printf '%s\n' 'networkmgr' > ~/.config/ml4w/settings/networkmanager.sh
printf '%s\n' 'nwg-displays' > ~/.config/ml4w/settings/monitor-manager.sh
printf '%s\n' 'nwg-look' > ~/.config/ml4w/settings/theme-gtk.sh
printf '%s\n' 'qt6ct' > ~/.config/ml4w/settings/theme-qt.sh
printf '%s\n' 'flatpak run com.ml4w.hyprlandsettings' > ~/.config/ml4w/settings/hyprland-settings.sh
```

Notes:

- The package is `py311-nwg-displays`, but the command is `nwg-displays`.
- The package is `py311-waypaper`, but the command is `waypaper`.
- If you do not use Flatpak for Hyprland Settings, replace `hyprland-settings.sh` with your preferred command or leave that feature unused.

## ThinkPad X1 Gen 9 Note

This fork now prefers FreeBSD's built-in `backlight(8)` when available, so brightness keys and Hypridle dim/restore behavior should work more naturally on a modern laptop than earlier versions of this fork.

If brightness still does not behave correctly on your hardware, check:

```sh
backlight -q
backlight incr 10
backlight decr 10
```

## First Login

For the first full test, log out and start a fresh Hyprland session instead of only running `hyprctl reload`.

That matters because ML4W uses multiple `exec-once` hooks.

## If Something Is Missing

The most common first-run failures are:

- `quickshell` missing
- `swaync` missing
- `waybar` missing
- `hyprlock` or `hyprpaper` missing
- `hypridle` unavailable
- launcher defaults still pointing to apps you do not have installed

When in doubt, check `~/.config/ml4w/settings/` first before editing the QML or Hyprland config directly.

## Recovering A Stuck Hyprland Session

This fork now includes a small recovery helper:

```sh
~/.config/ml4w/scripts/ml4w-reset-hyprland
```

Run it from a TTY if Hyprland crashes with stale runtime or lockfile errors. It will:

- stop common Hyprland session processes like `Hyprland`, `hyprlock`, `hypridle`, and `qs`
- remove stale runtime state in `$XDG_RUNTIME_DIR/hypr` and `/tmp/hypr`

If you want it to immediately relaunch Hyprland after cleanup:

```sh
~/.config/ml4w/scripts/ml4w-reset-hyprland --restart
```

If you suspect `hypridle` is part of the startup problem, you can do a one-shot minimal restart:

```sh
~/.config/ml4w/scripts/ml4w-reset-hyprland --restart --minimal
```

That temporarily switches `~/.config/hypr/conf/autostart.conf` into a much smaller startup mode before relaunching. It disables ML4W autostart extras such as Quickshell startup, `swaync`, `hypridle`, wallpaper restore, cliphist watching, listeners, and the Hyprland Settings hook, then saves a backup as `~/.config/hypr/conf/autostart.conf.pre-ml4w-safe`.

It also swaps `~/.config/hypr/conf/monitor.conf` to the generic fallback preset `~/.config/hypr/conf/monitors/default.conf` for that troubleshooting pass, and saves a backup as `~/.config/hypr/conf/monitor.conf.pre-ml4w-safe`.

To restore the original autostart file later:

```sh
~/.config/ml4w/scripts/ml4w-reset-hyprland --restore-autostart
```

To print the newest Hyprland log from a TTY:

```sh
~/.config/ml4w/scripts/ml4w-reset-hyprland --show-log
```
