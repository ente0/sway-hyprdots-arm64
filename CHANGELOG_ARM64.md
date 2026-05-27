# CHANGELOG — ARM64/Sway port

All modifications relative to upstream [yurihikari/garuda-hyprdots](https://github.com/yurihikari/garuda-hyprdots).

## [arm64-sway-0.1.0] — 2026-05-27

### Added
- `sway/config` entry point (sources modular config.d).
- `sway/config.d/theme.conf` — colors, gaps, borders, font (translated from `hypr/hyprtheme.conf`).
- `sway/config.d/keybindings.conf` — full keybind set (translated from `hypr/hyprland.conf` binds section, including French AZERTY workspace codes).
- `sway/swaylock.conf` — alternative config-file variant of the lockscreen.
- `sway/swayidle.conf` — idle/sleep/lock policy (replaces `hypridle`).
- `sway/scripts/` — full copy of `hypr/scripts/` with paths and IPC rewritten.
- `sway/scripts/colorpicker` — grim+slurp+ImageMagick replacement for `hyprpicker`.
- `sway/scripts/lockscreen` — preserved upstream flag-based swaylock invocation.
- Waybar modules: `cpu`, `disk`, `idle_inhibitor`, re-enabled `custom/pacman`.
- `install.sh`: aarch64 sanity check, EndeavourOS detection, yay bootstrap from source, SwayFX `.desktop` session file.
- `PORTING_NOTES.md`, `CHANGELOG_ARM64.md`.

### Changed
- All `~/.config/hypr/...` paths → `~/.config/sway/...` in ported scripts.
- All `hyprctl ...` invocations → `swaymsg ...` (notably `scripts/screenshot:shotwin`).
- Waybar `backlight` scroll: `light` → `brightnessctl` (removes `$SWAYSOCK.wob` writes).
- Waybar `pulseaudio` scroll: removes `$SWAYSOCK.wob` writes (kept `pamixer`).
- Waybar `custom/launcher`: `nwg-drawer` → `rofi_launcher` (drops a heavy Go dep).
- Hyprland window-rule `class=` → sway `app_id=` for native Wayland apps; Xwayland apps keep `class=`.

### Removed
- `paru` (replaced by `yay`).
- `chaotic-aur` repo bootstrap (no aarch64 builds).
- `hyprland`, `hyprland-git`, `hyprlock`, `hyprpicker`, `ags-hyprpanel-git`, `rose-pine-hyprcursor` from install list.
- `bun` curl-pipe install (was only needed for hyprpanel).
- Hyprland animations, gestures, `togglegroup`/`changegroupactive`, `workspaceopt`, layer blur rules.

### Removed (cont.)
- `hypr/` directory deleted in full. Shared assets (`mako/`, `wlogout/`, `foot/`, `wallpapers/`, `cheatsheet.md`) moved under `sway/`. Hyprland-specific configs (`hyprland.conf`, `hyprlock.conf`, `hyprtheme.conf`) and the parallel `hypr/{rofi,wofi,waybar,scripts}` variants dropped. Repo is now Sway-only.
