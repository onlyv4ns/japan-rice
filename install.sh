#!/usr/bin/env bash
# Installer for the "japan-rice" bspwm setup.
# Symlinks the tracked configs/scripts into $HOME, backing up anything
# already there that isn't already one of our symlinks.
set -euo pipefail

RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.japan-rice-backup-$(date +%Y%m%d-%H%M%S)"

FILES=(
  .config/bspwm/bspwmrc
  .config/bspwm/dual_monitors.sh
  .config/bspwm/dunstrc
  .config/bspwm/picom_configurations/1.conf
  .config/sxhkd/sxhkdrc
  .config/polybar/config.ini
  .config/polybar/colors.ini
  .config/polybar/modules.ini
  .config/polybar/launch.sh
  .config/kitty/kitty.conf
  .config/fastfetch/config.jsonc
  .config/fish/config.fish
  .config/fish/conf.d/tokyonight.fish
  .config/fish/functions/fish_prompt.fish
  .config/rofi/config.rasi
  .config/rofi/catppuccin.rasi
  .config/gtk-3.0/settings.ini
  .Xresources
  bin/toggle-polybar
  bin/random_wallpaper
  bin/change_language.sh
  bin/powermenu
  bin/calculator
  bin/xcolor-pick
  bin/bible
  bin/screen-lock
  bin/timer
  bin/volume
  bin/brightness
  bin/battery-alert
  bin/cursor_tracker.sh
  bin/focused_app
  bin/show-desktop
  Pictures/bg.png
)

DEPS=(bspwm sxhkd polybar picom dunst rofi kitty fastfetch feh fish scrot btop)

echo "== Japan Rice Installer =="
echo "Source: $RICE_DIR"
echo

echo "-- Checking dependencies --"
missing=()
for pkg in "${DEPS[@]}"; do
  command -v "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
done
if [ "${#missing[@]}" -gt 0 ]; then
  echo "Missing: ${missing[*]}"
  read -rp "Install missing packages via apt now? [y/N] " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    sudo apt update && sudo apt install -y "${missing[@]}"
  else
    echo "Skipping package install; some features may not work until installed."
  fi
else
  echo "All dependencies already installed."
fi
echo

echo "-- Linking configs --"
backed_up=0
linked=0
for rel in "${FILES[@]}"; do
  src="$RICE_DIR/$rel"
  dest="$HOME/$rel"

  if [ ! -e "$src" ]; then
    echo "  skip (missing in repo): $rel"
    continue
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "  already linked: $rel"
    continue
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$dest" "$BACKUP_DIR/$rel"
    backed_up=$((backed_up + 1))
  fi

  ln -s "$src" "$dest"
  echo "  linked: $rel"
  linked=$((linked + 1))
done
echo

chmod +x "$RICE_DIR"/bin/* \
  "$RICE_DIR/.config/bspwm/dual_monitors.sh" \
  "$RICE_DIR/.config/polybar/launch.sh" 2>/dev/null || true

echo "-- Done --"
echo "Linked: $linked file(s)"
if [ "$backed_up" -gt 0 ]; then
  echo "Backed up $backed_up existing file(s) to: $BACKUP_DIR"
fi
echo
echo "Restart bspwm (Super+Shift+R) or relogin for everything to take effect."
