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

DEPS=(bspwm sxhkd polybar picom dunst rofi kitty fastfetch feh fish scrot btop pamixer)

NERD_FONT_ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
NERD_FONT_DEST="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"

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

echo "-- Checking fonts --"
# polybar/kitty rely on icon glyphs (power button, workspace icons, focused_app
# icons) that only exist in these fonts. Without them the glyphs render blank.
if command -v fc-list >/dev/null 2>&1; then
  missing_fonts=()
  fc-list | grep -qi "Material Design Icons" || missing_fonts+=("fonts-materialdesignicons-webfont")
  if [ "${#missing_fonts[@]}" -gt 0 ]; then
    echo "Missing: ${missing_fonts[*]}"
    read -rp "Install missing font packages via apt now? [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      sudo apt update && sudo apt install -y "${missing_fonts[@]}"
    else
      echo "Skipping; some polybar icons may render blank until installed."
    fi
  fi

  if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    echo "JetBrainsMono Nerd Font already installed."
  else
    echo "JetBrainsMono Nerd Font not found (needed for polybar/kitty icons)."
    read -rp "Download and install it now? [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      if command -v curl >/dev/null 2>&1 && command -v unzip >/dev/null 2>&1; then
        tmp_font_dir="$(mktemp -d)"
        echo "Downloading JetBrainsMono Nerd Font..."
        if curl -fL -o "$tmp_font_dir/JetBrainsMono.zip" "$NERD_FONT_ZIP_URL"; then
          mkdir -p "$NERD_FONT_DEST"
          unzip -oq "$tmp_font_dir/JetBrainsMono.zip" "JetBrainsMonoNerdFont-*.ttf" -d "$NERD_FONT_DEST"
          fc-cache -f "$NERD_FONT_DEST" >/dev/null
          echo "Installed JetBrainsMono Nerd Font."
        else
          echo "Download failed; install manually from https://www.nerdfonts.com/"
        fi
        rm -rf "$tmp_font_dir"
      else
        echo "Need curl and unzip to install automatically; install manually from https://www.nerdfonts.com/"
      fi
    else
      echo "Skipping; polybar/kitty icons will render blank until this font is installed."
    fi
  fi
else
  echo "fc-list not found (fontconfig missing); skipping font checks."
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
