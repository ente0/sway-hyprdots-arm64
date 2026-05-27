<h1 align="center">sway-hyprdots-arm64</h1>

<p align="center">
  HyDE-inspired Sway desktop, ported to <b>EndeavourOS ARM</b> on <b>Raspberry Pi 5</b>.<br>
  Forked from <a href="https://github.com/yurihikari/garuda-hyprdots">yurihikari/garuda-hyprdots</a>.
</p>

## What this fork is

A clean ARM64 port of the upstream Hyprland/Sway dotfiles, with:

- **SwayFX** as the compositor (Sway + blur + rounded corners + shadows)
- **Waybar** (enriched: workspaces, cpu/mem/disk/temp, pacman updates, idle inhibitor, network, audio, brightness, battery, clock with calendar, cava bars)
- **swaylock-effects** + **swayidle** for lock & idle (replaces hyprlock/hypridle)
- **swww** for wallpapers (replaces hyprpaper)
- **rofi-wayland** + **wofi** launchers, **mako** notifications, **wlogout** power menu
- **yay** as AUR helper (paru bootstrap from Garuda removed; no chaotic-aur on aarch64)

## What this fork is NOT

- Not Hyprland on the Pi. Hyprland builds on aarch64 but its mesa/wlroots feature set on V3D is brittle. We use Sway.
- Not a backport — the upstream `hypr/` tree has been removed entirely. This is a Sway-only fork.

See [PORTING_NOTES.md](PORTING_NOTES.md) and [CHANGELOG_ARM64.md](CHANGELOG_ARM64.md) for the full mapping and change log.

## Requirements

- Hardware: Raspberry Pi 5 (aarch64)
- OS: [EndeavourOS ARM](https://github.com/Vouchsoft/EndeavourOS-ARM-PineAarch) (or any Arch Linux ARM derivative)
- A working network connection

## Installation

```bash
git clone https://github.com/ente0/sway-hyprdots-arm64.git
cd sway-hyprdots-arm64
./install.sh
```

The script:
1. Checks arch (`aarch64`) and OS (`EndeavourOS`).
2. Bootstraps `yay` from source if missing.
3. Installs everything via `pacman` + `yay` (no chaotic-aur).
4. Rsyncs configs into `~/.config/` (skipping the legacy `hypr/`).
5. Installs a `swayfx.desktop` Wayland session.

Reboot, pick **SwayFX (HyDE-ARM64)** from your DM (or `sway` from a TTY).

## Keybinds (excerpt)

| Key | Action |
|---|---|
| `Super+Return` | Terminal (kitty) |
| `Super+D` | rofi launcher |
| `Super+X` | rofi power menu |
| `Super+P` | color picker (grim+slurp) |
| `Super+E` | emoji picker (wofi-emoji) |
| `Super+Shift+B` | wallpaper switch (yad + swww) |
| `Super+Shift+T` | swap waybar theme |
| `Super+Shift+I` | open cheatsheet in floating foot |
| `Print` / `Super+Print` | full / area screenshot |
| `Ctrl+Alt+L` | lockscreen |
| `Super+1..0` / `Super+Shift+1..0` | workspaces / move-to (numeric **and** French AZERTY) |

Full list in [sway/config.d/keybindings.conf](sway/config.d/keybindings.conf).

## Performance notes on Pi 5

- Lower SwayFX `blur_passes` to 1–2 at 4K if you see stutters.
- `temperature` waybar module assumes `/sys/class/hwmon/hwmon1/temp1_input`. Check yours with:
  ```bash
  for d in /sys/class/hwmon/*; do echo "$d: $(cat "$d/name" 2>/dev/null)"; done
  ```

## Credits

- [yurihikari/garuda-hyprdots](https://github.com/yurihikari/garuda-hyprdots) — upstream fork base
- [HyDE](https://github.com/HyDE-Project/HyDE) — original inspiration
- [Archcraft](https://archcraft.io/) — base Hyprland config and aesthetic
- [Catppuccin](https://github.com/catppuccin/catppuccin) — palette

## License

MIT — see [LICENSE](LICENSE).
