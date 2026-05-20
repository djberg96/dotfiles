#!/usr/bin/env bash
# __  ______   ____
# \ \/ /  _ \ / ___|
#  \  /| | | | |  _
#  /  \| |_| | |_| |
# /_/\_\____/ \____|
#

# shellcheck source=/dev/null
source "$HOME/.config/ml4w/scripts/ml4w-platform"

# Setup Timers
_sleep1="0.1"
_sleep2="0.5"
_sleep3="2"
_sleep4="1"

stop_user_service() {
    ml4w_command_exists systemctl || return 0
    systemctl --user stop "$1" >/dev/null 2>&1 || true
}

start_user_service() {
    ml4w_command_exists systemctl || return 0
    systemctl --user start "$1" >/dev/null 2>&1 || true
}

start_portal_binary() {
    local binary_name="$1"
    local binary_path

    binary_path="$(command -v "$binary_name" 2>/dev/null)" || return 0
    "$binary_path" &
}

sleep $_sleep4

# Kill all possible running xdg-desktop-portals
pkill -x xdg-desktop-portal-hyprland >/dev/null 2>&1 || true
pkill -x xdg-desktop-portal-gnome >/dev/null 2>&1 || true
pkill -x xdg-desktop-portal-kde >/dev/null 2>&1 || true
pkill -x xdg-desktop-portal-lxqt >/dev/null 2>&1 || true
pkill -x xdg-desktop-portal-wlr >/dev/null 2>&1 || true
pkill -x xdg-desktop-portal-gtk >/dev/null 2>&1 || true
pkill -x xdg-desktop-portal >/dev/null 2>&1 || true

# Set required environment variables
"$HOME/.config/ml4w/scripts/ml4w-session" dbus-update-env WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=hyprland

# Stop all services
stop_user_service pipewire
stop_user_service wireplumber
stop_user_service xdg-desktop-portal
stop_user_service xdg-desktop-portal-gnome
stop_user_service xdg-desktop-portal-kde
stop_user_service xdg-desktop-portal-wlr
stop_user_service xdg-desktop-portal-hyprland
sleep $_sleep1

# Start xdg-desktop-portal-hyprland
start_portal_binary xdg-desktop-portal-hyprland
sleep $_sleep3

# Start xdg-desktop-portal-gtk
if command -v xdg-desktop-portal-gtk >/dev/null 2>&1; then
    start_portal_binary xdg-desktop-portal-gtk
    sleep $_sleep1
fi

# Start xdg-desktop-portal
start_portal_binary xdg-desktop-portal
sleep $_sleep2

# Start required services
start_user_service pipewire
start_user_service wireplumber
start_user_service xdg-desktop-portal
start_user_service xdg-desktop-portal-hyprland

# Run waybar
sleep $_sleep3
# ~/.config/waybar/launch.sh
