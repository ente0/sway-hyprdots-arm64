#!/bin/bash
# sway-hyprdots-arm64 installer
# Target: EndeavourOS ARM (Raspberry Pi 5 — aarch64)
# See PORTING_NOTES.md and CHANGELOG_ARM64.md for full porting details.

set -e

echo "###############################################################################################################"
echo "# sway-hyprdots-arm64 installer"
echo "# Target  : EndeavourOS ARM on Raspberry Pi 5 (aarch64)"
echo "# WM      : SwayFX (Sway + blur + rounded corners)"
echo "# Helpers : pacman + yay (AUR)"
echo "###############################################################################################################"

# --- Sanity checks --------------------------------------------------------
ARCH="$(uname -m)"
if [[ "$ARCH" != "aarch64" && "$ARCH" != "arm64" ]]; then
	echo "[!] Detected arch '$ARCH'. This fork targets aarch64 (Raspberry Pi 5)."
	read -rp "Continue anyway? (y/N) " ans
	[[ "$ans" =~ ^[Yy]$ ]] || exit 1
fi

if [[ ! -f /etc/os-release ]] || ! grep -qi 'endeavouros' /etc/os-release; then
	echo "[!] /etc/os-release does not look like EndeavourOS. This script is tuned for EndeavourOS ARM."
	read -rp "Continue anyway? (y/N) " ans
	[[ "$ans" =~ ^[Yy]$ ]] || exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo
read -rp "Update the system first (recommended)? (Y/n) " ans
if [[ ! "$ans" =~ ^[Nn]$ ]]; then
	sudo pacman -Syu --noconfirm
fi

# --- yay ------------------------------------------------------------------
if ! command -v yay >/dev/null 2>&1; then
	echo "[*] Installing yay from source (no prebuilt aarch64 in extra)."
	sudo pacman -S --needed --noconfirm base-devel git go
	tmp=$(mktemp -d)
	git clone https://aur.archlinux.org/yay.git "$tmp/yay"
	(cd "$tmp/yay" && makepkg -si --noconfirm)
	rm -rf "$tmp"
fi

# --- Helpers --------------------------------------------------------------
pac_install() {
	for p in "$@"; do
		if ! pacman -Qi "$p" &>/dev/null; then
			echo "  pacman: $p"
			sudo pacman -S --needed --noconfirm "$p"
		fi
	done
}

aur_install() {
	for p in "$@"; do
		if ! pacman -Qi "$p" &>/dev/null; then
			echo "  yay   : $p"
			yay -S --needed --noconfirm "$p"
		fi
	done
}

# --- Official repos -------------------------------------------------------
# Everything here is available in [extra]/[community] for aarch64 via the
# Arch Linux ARM repos that EndeavourOS ARM inherits.
echo "[*] Installing core packages from pacman"
pac_install \
	sway swaybg swayidle swaylock \
	waybar \
	foot kitty alacritty \
	rofi wofi mako wlogout \
	grim slurp jq imagemagick wl-clipboard \
	brightnessctl pamixer pulsemixer playerctl \
	pavucontrol \
	pipewire wireplumber pipewire-pulse pipewire-alsa \
	networkmanager network-manager-applet \
	bluez bluez-utils blueberry \
	thunar geany \
	xdg-user-dirs xdg-desktop-portal-wlr \
	gnome-keyring polkit-gnome \
	mpd mpc cava btop \
	fastfetch fish micro \
	ttf-jetbrains-mono-nerd ttf-font-awesome noto-fonts \
	qt5-wayland qt6-wayland \
	gtk3 gtk4

# --- AUR ------------------------------------------------------------------
# SwayFX = blur + rounded corners (your non-negotiable).
# rose-pine-cursor (XCursor) replaces rose-pine-hyprcursor.
# wofi-emoji and rofi-emoji for the emoji picker keybind.
# NOTE: hyprpicker dropped on purpose — see PORTING_NOTES.md.
echo "[*] Installing AUR packages via yay"
aur_install \
	swayfx \
	swaylock-effects \
	swww \
	rose-pine-cursor \
	nwg-look \
	wofi-emoji \
	oh-my-posh-bin

# --- Deploy configs -------------------------------------------------------
echo "[*] Deploying configs to ~/.config"
mkdir -p "$HOME/.config"
rsync -av \
	--exclude='.git' --exclude='.gitignore' \
	--exclude='LICENSE' --exclude='README.md' \
	--exclude='PORTING_NOTES.md' --exclude='CHANGELOG_ARM64.md' \
	--exclude='install.sh' \
	"$DIR"/ "$HOME/.config/"

# btop theme
mkdir -p "$HOME/.config/btop"
grep -q 'color_theme' "$HOME/.config/btop/btop.conf" 2>/dev/null || \
	echo "color_theme = $HOME/.config/btop/themes/catppuccin_macchiato.theme" >> "$HOME/.config/btop/btop.conf"

# Ensure scripts executable
chmod +x "$HOME/.config/sway/scripts/"* 2>/dev/null || true
chmod +x "$HOME/.config/waybar/scripts/"* 2>/dev/null || true

# --- Session file ---------------------------------------------------------
# Use SwayFX binary if present, otherwise plain sway.
if pacman -Qi swayfx &>/dev/null && [[ ! -f /usr/share/wayland-sessions/swayfx.desktop ]]; then
	echo "[*] Installing SwayFX wayland session file"
	sudo tee /usr/share/wayland-sessions/swayfx.desktop >/dev/null <<EOF
[Desktop Entry]
Name=SwayFX (HyDE-ARM64)
Comment=Sway with effects — HyDE-ported config
Exec=sway
Type=Application
EOF
fi

echo
echo "[*] Done."
echo "Log out and pick the 'SwayFX (HyDE-ARM64)' session from your display manager,"
echo "or run 'sway' from a TTY."
read -rp "Reboot now? (y/N) " ans
[[ "$ans" =~ ^[Yy]$ ]] && sudo reboot now
