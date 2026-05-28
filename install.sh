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

# Build an AUR pkg whose PKGBUILD wrongly excludes aarch64.
# $1 = pkgname (must match the AUR repo name).
aur_build_ignorearch() {
	local pkg="$1"
	if pacman -Qi "$pkg" &>/dev/null; then return; fi
	echo "  [arm64 patch] building $pkg from AUR source..."
	local tmp; tmp=$(mktemp -d)
	git clone "https://aur.archlinux.org/${pkg}.git" "$tmp/$pkg"
	sed -i "s/arch=('x86_64')/arch=('x86_64' 'aarch64')/" "$tmp/$pkg/PKGBUILD" || true
	(cd "$tmp/$pkg" && makepkg -si --noconfirm --ignorearch --skippgpcheck)
	rm -rf "$tmp"
}

# --- Official repos -------------------------------------------------------
# Everything here is available in [extra]/[community] for aarch64 via the
# Arch Linux ARM repos that EndeavourOS ARM inherits.
echo "[*] Installing core packages from pacman"
pac_install \
	sway swaybg swayidle swaylock \
	waybar \
	foot kitty alacritty \
	wofi mako \
	grim slurp jq imagemagick wl-clipboard unzip curl \
	brightnessctl pamixer pulsemixer playerctl \
	pavucontrol \
	pipewire wireplumber pipewire-pulse pipewire-alsa \
	networkmanager network-manager-applet \
	bluez bluez-utils blueman \
	dolphin geany \
	xdg-user-dirs xdg-desktop-portal-wlr \
	gnome-keyring polkit-gnome \
	mpd mpc cava btop \
	fastfetch fish nano \
	pacman-contrib \
	ttf-jetbrains-mono-nerd ttf-font-awesome ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono awesome-terminal-fonts noto-fonts noto-fonts-emoji \
	qt5-wayland qt6-wayland \
	gtk3 gtk4

# --- AUR ------------------------------------------------------------------
# SwayFX = blur + rounded corners (your non-negotiable).
# rose-pine-cursor (XCursor) replaces rose-pine-hyprcursor.
# wofi-emoji and rofi-emoji for the emoji picker keybind.
# NOTE: hyprpicker dropped on purpose — see PORTING_NOTES.md.
echo "[*] Installing AUR packages via yay"
# Packages whose PKGBUILD restricts to x86_64 but code is portable.
# Build order matters: scenefx0.4 is a swayfx dep.
aur_build_ignorearch wlogout
aur_build_ignorearch scenefx0.4
aur_build_ignorearch swww
# swayfx provides sway → remove the base package first to avoid a conflict.
if pacman -Qi sway &>/dev/null && ! pacman -Qi swayfx &>/dev/null; then
	echo "[*] Removing 'sway' to make room for 'swayfx' (provides sway)"
	sudo pacman -Rdd --noconfirm sway
fi
aur_build_ignorearch swayfx

# swaylock-effects provides swaylock → remove base package first.
if pacman -Qi swaylock &>/dev/null && ! pacman -Qi swaylock-effects &>/dev/null; then
	echo "[*] Removing 'swaylock' to make room for 'swaylock-effects' (provides swaylock)"
	sudo pacman -Rdd --noconfirm swaylock
fi

# rofi-wayland provides rofi for Wayland; remove the X11 rofi first.
if pacman -Qi rofi &>/dev/null && ! pacman -Qi rofi-wayland &>/dev/null; then
	echo "[*] Removing X11 'rofi' to make room for 'rofi-wayland'"
	sudo pacman -Rdd --noconfirm rofi
fi

aur_install \
	swaylock-effects \
	rofi-wayland \
	rose-pine-cursor \
	nwg-look \
	wofi-emoji \
	oh-my-posh-bin \
	catppuccin-gtk-theme-macchiato \
	tela-circle-icon-theme

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

# --- SDDM greeter ---------------------------------------------------------
# Install SDDM + Qt deps + Catppuccin Macchiato theme, then enable the unit.
echo "[*] Installing SDDM greeter"
pac_install sddm qt5-quickcontrols2 qt5-graphicaleffects qt5-svg \
	ttf-jetbrains-mono ttf-roboto

# Temporary: use sddm-astronaut-theme (catppuccin-macchiato variant) until the
# proper catppuccin/sddm path is settled. Ships Main.qml at root, no build.
THEME_NAME='sddm-astronaut-theme'
THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"
ASTRONAUT_VARIANT='cat_waves_mocha'

for old in /usr/share/sddm/themes/catppuccin-macchiato \
           /usr/share/sddm/themes/catppuccin-macchiato-mauve; do
	if [[ -d "$old" && ! -f "$old/Main.qml" ]]; then
		echo "[*] Removing broken theme dir: $old"
		sudo rm -rf "$old"
	fi
done

if [[ ! -f "$THEME_DIR/Main.qml" ]]; then
	echo "[*] Installing sddm-astronaut-theme (catppuccin-macchiato variant)"
	sudo rm -rf "$THEME_DIR"
	sudo mkdir -p /usr/share/sddm/themes
	if sudo git clone --depth=1 \
		https://github.com/Keyitdev/sddm-astronaut-theme.git "$THEME_DIR"; then
		# Pick variant — try exact name, then any case/separator variation.
		variant_file=$(find "$THEME_DIR/Themes" -maxdepth 1 -iname "${ASTRONAUT_VARIANT}.conf" -o \
			-iname "$(echo "$ASTRONAUT_VARIANT" | tr '_' '-').conf" 2>/dev/null | head -1)
		if [[ -n "$variant_file" ]]; then
			sudo cp "$variant_file" "$THEME_DIR/theme.conf.user"
			echo "  variant: $(basename "$variant_file")"
		else
			echo "[!] Variant '$ASTRONAUT_VARIANT' not found. Available:"
			ls "$THEME_DIR/Themes" 2>/dev/null | sed 's/^/    /'
		fi
		echo "  installed at $THEME_DIR"
	else
		echo "[!] Could not install sddm-astronaut-theme — SDDM will use default."
		THEME_NAME='breeze'
	fi
fi

echo "[*] Writing /etc/sddm.conf.d/10-sway-hyprdots.conf"
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/10-sway-hyprdots.conf >/dev/null <<EOF
[Theme]
Current=$THEME_NAME

[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Wayland]
SessionDir=/usr/share/wayland-sessions
EOF

# Drop any tty1 autostart block we wrote previously — SDDM owns the login now.
for rc in "$HOME/.zprofile" "$HOME/.bash_profile" "$HOME/.profile"; do
	[[ -f "$rc" ]] || continue
	if grep -qF '# >>> sway autostart (sway-hyprdots-arm64) >>>' "$rc"; then
		echo "[*] Removing old tty1 autostart block from $rc"
		# Delete lines between the markers (inclusive). BSD/GNU sed compat.
		sed -i.bak '/# >>> sway autostart (sway-hyprdots-arm64) >>>/,/# <<< sway autostart (sway-hyprdots-arm64) <<</d' "$rc" && rm -f "$rc.bak"
	fi
done

# Enable SDDM, disable any conflicting DM that may be present.
for other in lightdm gdm lxdm greetd; do
	if systemctl is-enabled "$other" >/dev/null 2>&1; then
		echo "[*] Disabling $other.service (replaced by SDDM)"
		sudo systemctl disable "$other"
	fi
done
sudo systemctl enable sddm.service

echo
echo "[*] Done."
echo "On reboot SDDM will start; pick 'SwayFX (HyDE-ARM64)' from the session menu."
read -rp "Reboot now? (y/N) " ans
[[ "$ans" =~ ^[Yy]$ ]] && sudo reboot now
