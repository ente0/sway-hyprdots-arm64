# Porting Notes — Hyprland → SwayFX on EndeavourOS ARM64

This fork ports [yurihikari/garuda-hyprdots](https://github.com/yurihikari/garuda-hyprdots) (in turn derived from HyDE) from **Hyprland on x86_64** to **SwayFX on aarch64 (Raspberry Pi 5)**, running on **EndeavourOS ARM**.

## Component map

| Hyprland | Sway / SwayFX equivalent | Notes |
|---|---|---|
| `hyprland` / `hyprland-git` | `swayfx` (AUR) | SwayFX = Sway with blur + rounded corners + shadows. |
| `hyprland.conf` | `sway/config` + `sway/config.d/*.conf` | Modularized into `theme.conf` and `keybindings.conf`. |
| `hyprtheme.conf` | `sway/config.d/theme.conf` | Colors mapped to `client.*` directives. |
| `hyprctl` | `swaymsg` | All script callsites updated. Active-window geometry via `swaymsg -t get_tree \| jq`. |
| `hyprlock` / `hyprlock.conf` | `swaylock-effects` + `sway/swaylock.conf` (and `scripts/lockscreen`) | Two delivery modes: a flag-based script (default) and a config file. |
| `hypridle` | `swayidle` + `sway/swayidle.conf` | Started from `scripts/startup`. |
| `hyprpaper` | `swww` + `swww-daemon` | Already used upstream. |
| `hyprcursor` / `rose-pine-hyprcursor` | `rose-pine-cursor` (XCursor) | hyprcursor format is Hyprland-only. |
| `hyprpicker` | grim + slurp + ImageMagick (`scripts/colorpicker`) | **DROPPED** per user preference. The fallback samples a 1×1 PPM and parses the pixel. |
| `ags-hyprpanel-git` | **Removed** | Hard dep on Hyprland IPC. Replaced by an enriched Waybar (CPU, memory, disk, pacman updates, idle inhibitor). |
| `nwg-drawer` launcher button | `rofi` launcher | The launcher Waybar button now calls `scripts/rofi_launcher`. |
| Hyprland `windowrule` / `windowrulev2` | `for_window [...] ...` | Class → `app_id` for native Wayland apps; legacy `class` kept for Xwayland apps. |
| Hyprland animations | Sway has none; SwayFX has limited fade only | Animation directives dropped. |
| Hyprland gestures (`workspace_swipe`) | Not supported in Sway | Dropped. |
| Hyprland `togglegroup` / `changegroupactive` | No tabbed/stacked group equiv. in same form | Use sway `layout tabbed` / `layout stacking` instead (see below). |
| Hyprland `pin` | `sticky toggle` | Mapped to same `$mod+Shift+P`. |

## Hyprland features without a Sway equivalent

| Feature | Decision |
|---|---|
| `togglegroup`, `changegroupactive` (`SUPER+G/H/L`) | Removed; use sway built-in `layout toggle split tabbed`. |
| `workspaceopt allfloat`, `allpseudo` | Removed (no per-workspace overrides in sway). |
| `swallow_regex` (terminal swallowing) | Not supported by sway. |
| VRR / `vfr` | Sway has experimental `adaptive_sync on` per-output; not enabled by default. |
| `dim_inactive`, `inactive_opacity` | Approximated via SwayFX `default_dim_inactive` and `opacity` rules; falls back to no-op on vanilla Sway. |
| `hyprpicker` | Dropped (user choice). Replacement script is good enough for HEX-copy. |

## Package map (x86 → aarch64)

| Original | aarch64 source | Notes |
|---|---|---|
| `paru` | replaced by **`yay`** | yay built from AUR via `makepkg`. |
| `chaotic-aur` | **removed** | Not built for aarch64. |
| `hyprland-git`, `hyprlock`, `hyprpicker`, `ags-hyprpanel-git`, `rose-pine-hyprcursor` | dropped | See above. |
| `swayfx`, `swaylock-effects`, `swww`, `wofi-emoji`, `rose-pine-cursor`, `nwg-look`, `oh-my-posh-bin` | AUR (`yay`) | All have aarch64 build recipes. |
| `light` | replaced by **`brightnessctl`** | aarch64-friendly, no setuid. |
| `grimblast` | replaced by inline `grim + slurp` | One less dep. |
| `blueberry` / `gnome-bluetooth` | replaced by **`blueman`** | gnome-bluetooth is x86_64-only; blueman is in [extra] for aarch64. |
| `wlogout`, `swayfx`, `scenefx0.4` | built via `makepkg --ignorearch` | arch=('x86_64') in PKGBUILD is arbitrary — code compiles fine on aarch64. Use the `aur_build_ignorearch` helper in `install.sh`. |
| `bun` (curl install) | dropped | Only needed by ags-hyprpanel. |

## Repository layout after port

```
sway/
  config                    # main entry — sources config.d/*
  config.d/
    theme.conf              # ex hyprtheme.conf
    keybindings.conf        # ex hyprland.conf binds section
  swaylock.conf             # ex hyprlock.conf (alternative to scripts/lockscreen)
  swayidle.conf             # ex hypridle equivalent
  scripts/                  # ported (paths + IPC fixed)
  mako/  wlogout/  foot/  wallpapers/  cheatsheet.md
waybar/                     # tweaked: enriched modules, ARM-safe scripts
install.sh                  # ARM64/EndeavourOS-aware
```

## Known limitations on Raspberry Pi 5

- **SwayFX blur cost**: on V3D/VC4 the blur passes can drop frames at 4K; lower `blur_passes` to 1–2 if needed.
- **Hardware video decode** in browsers requires `mesa` ≥ 24 with V3D enabled (default in EndeavourOS ARM).
- `hwmon` paths in waybar (`/sys/class/hwmon/hwmon1/temp1_input`) may differ — check `for d in /sys/class/hwmon/*; do echo "$d: $(cat $d/name 2>/dev/null)"; done` and adjust.
