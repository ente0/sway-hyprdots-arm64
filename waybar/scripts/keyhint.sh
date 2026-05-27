#!/bin/sh
yad --title="SwayFX (HyDE-ARM64) keybindings — macOS style" \
    --no-buttons --geometry=640x600-15-400 --list \
    --column=key: --column=description: --column=command: \
    "Esc" "close this popup" "" \
    "⌘ = Mod4" "modkey" "(Super)" \
    "⌘+Return" "Terminal" "(kitty)" \
    "⌘+Shift+Return" "Terminal (floating)" "(kitty -f)" \
    "⌘+T" "Terminal (fullscreen)" "(kitty -F)" \
    "⌘+Space / ⌘+D" "App launcher" "(rofi drun)" \
    "⌘+R" "Run command" "(rofi run)" \
    "⌘+E" "Emoji picker" "(wofi-emoji)" \
    "⌘+P" "Color picker" "(grim+slurp)" \
    "⌘+X" "Power menu" "(rofi)" \
    "⌘+A" "Screenshot menu" "(rofi)" \
    "⌘+N" "File manager" "(thunar)" \
    "⌘+Shift+E" "Editor" "(geany)" \
    "⌘+Shift+W" "Browser" "(brave)" \
    "⌘+W / ⌘+Q" "Close window" "(kill)" \
    "⌘+F" "Fullscreen toggle" "" \
    "⌘+Shift+F" "Floating toggle" "" \
    "⌘+H / ⌘+M" "Minimize (scratchpad)" "" \
    "⌘+Shift+H / ⌘+\`" "Unhide last" "(scratchpad show)" \
    "⌘+Tab / ⌘+Shift+Tab" "Focus next / prev" "" \
    "⌘+←↑↓→" "Focus direction" "" \
    "⌘+Shift+←↑↓→" "Move window" "" \
    "⌘+Ctrl+←↑↓→" "Resize window" "" \
    "Ctrl+← / Ctrl+→" "Workspace prev / next" "" \
    "Ctrl+↑" "Window switcher" "(Mission Control)" \
    "⌘+1..0" "Switch workspace" "" \
    "⌘+Shift+1..0" "Move window to workspace" "" \
    "⌘+Shift+P" "Pin (sticky toggle)" "" \
    "⌘+Shift+B" "Wallpaper switch" "(yad + swww)" \
    "⌘+Shift+T" "Swap waybar theme" "" \
    "⌘+Shift+I" "Open cheatsheet" "(foot + micro)" \
    "Ctrl+Alt+L" "Lockscreen" "(swaylock)" \
    "Ctrl+Alt+Delete" "Exit sway" "(swaymsg exit)" \
    "Print" "Screenshot — full" "" \
    "⌘+Print" "Screenshot — area" "" \
    "Ctrl+Print" "Screenshot — window" ""
