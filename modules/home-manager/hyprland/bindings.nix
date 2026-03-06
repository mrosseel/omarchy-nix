{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
  # OSD client for the currently focused monitor
  osdclient = "swayosd-client --monitor \"$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')\"";

  # Convert binding lists to extraConfig strings
  mkBindd = bindings: lib.concatMapStringsSep "\n" (binding: "bindd = ${binding}") bindings;
  mkBinddr = bindings: lib.concatMapStringsSep "\n" (binding: "binddr = ${binding}") bindings;
  mkBindeld = bindings: lib.concatMapStringsSep "\n" (binding: "bindeld = ${binding}") bindings;
  mkBindld = bindings: lib.concatMapStringsSep "\n" (binding: "bindld = ${binding}") bindings;
  mkBindmd = bindings: lib.concatMapStringsSep "\n" (binding: "bindmd = ${binding}") bindings;

  # Dictation bindings (only when voxtype is enabled)
  dictationBindings = lib.optionals cfg.voxtype.enable [
    "SUPER CTRL, X, Toggle dictation, exec, voxtype record toggle"
  ];

  # Main descriptive bindings
  mainBindings = [
    # Menus
    "SUPER, SPACE, Launch apps, exec, omarchy-launch-walker"
    "SUPER CTRL, E, Emoji picker, exec, omarchy-launch-walker -m symbols"
    "SUPER CTRL, C, Capture menu, exec, omarchy-menu capture"
    "SUPER CTRL, O, Toggle menu, exec, omarchy-menu toggle"
    "SUPER ALT, SPACE, Omarchy menu, exec, omarchy-menu"
    "SUPER, ESCAPE, System menu, exec, omarchy-menu system"
    "SUPER, K, Show key bindings, exec, omarchy-show-keybindings"

    # Aesthetics
    "SUPER SHIFT, SPACE, Toggle top bar, exec, omarchy-toggle-waybar"
    "SUPER CTRL, SPACE, Theme background menu, exec, omarchy-menu background"
    "SUPER SHIFT CTRL, SPACE, Theme menu, exec, omarchy-menu theme"
    "SUPER, BACKSPACE, Toggle window transparency, exec, hyprctl dispatch setprop \"address:$(hyprctl activewindow -j | jq -r '.address')\" opaque toggle"
    "SUPER SHIFT, BACKSPACE, Toggle window gaps, exec, omarchy-hyprland-window-gaps-toggle"
    "SUPER CTRL, BACKSPACE, Toggle single-window square aspect, exec, omarchy-hyprland-window-single-square-aspect-toggle"

    # Notifications
    "SUPER, COMMA, Dismiss last notification, exec, makoctl dismiss"
    "SUPER SHIFT, COMMA, Dismiss all notifications, exec, makoctl dismiss --all"
    "SUPER CTRL, COMMA, Toggle silencing notifications, exec, omarchy-toggle-notification-silencing"
    "SUPER ALT, COMMA, Invoke last notification, exec, makoctl invoke"
    "SUPER SHIFT ALT, COMMA, Restore last notification, exec, makoctl restore"

    # Toggles
    "SUPER CTRL, I, Toggle locking on idle, exec, omarchy-toggle-idle"
    "SUPER CTRL, N, Toggle nightlight, exec, omarchy-toggle-nightlight"

    # Control Apple Display brightness
    "CTRL, F1, Apple Display brightness down, exec, omarchy-brightness-display -5000"
    "CTRL, F2, Apple Display brightness up, exec, omarchy-brightness-display +5000"
    "SHIFT CTRL, F2, Apple Display full brightness, exec, omarchy-brightness-display +60000"

    # Captures
    ", PRINT, Screenshot, exec, omarchy-cmd-screenshot"
    "ALT, PRINT, Screenrecording, exec, omarchy-menu screenrecord"
    "SUPER, PRINT, Color picker, exec, pkill hyprpicker || hyprpicker -a"

    # File sharing
    "SUPER CTRL, S, Share, exec, omarchy-menu share"

    # Waybar-less information
    "SUPER CTRL ALT, T, Show time, exec, notify-send \"    $(date +\"%A %H:%M  —  %d %B W%V %Y\")\""
    "SUPER CTRL ALT, B, Show battery remaining, exec, notify-send \"󰁹    Battery is at $(omarchy-battery-remaining)%\""

    # Control panels
    "SUPER CTRL, A, Audio controls, exec, omarchy-launch-audio"
    "SUPER CTRL, B, Bluetooth controls, exec, omarchy-launch-bluetooth"
    "SUPER CTRL, W, Wifi controls, exec, omarchy-launch-wifi"
    "SUPER CTRL, T, Activity, exec, omarchy-launch-tui btop"

    # Zoom
    "SUPER CTRL, Z, Zoom in, exec, hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float + 1')"
    "SUPER CTRL ALT, Z, Reset zoom, exec, hyprctl keyword cursor:zoom_factor 1"

    # Lock system
    "SUPER CTRL, L, Lock system, exec, omarchy-lock-screen"

    # Close windows
    "SUPER, W, Close window, killactive,"
    "CTRL ALT, DELETE, Close all windows, exec, omarchy-hyprland-window-close-all"

    # Control tiling
    "SUPER, J, Toggle window split, layoutmsg, togglesplit"
    "SUPER, P, Pseudo window, pseudo, # dwindle"
    "SUPER, T, Toggle window floating/tiling, togglefloating,"
    "SUPER, F, Full screen, fullscreen, 0"
    "SUPER CTRL, F, Tiled full screen, fullscreenstate, 0 2"
    "SUPER ALT, F, Full width, fullscreen, 1"
    "SUPER, O, Pop window out (float & pin), exec, omarchy-hyprland-window-pop"
    "SUPER, L, Toggle workspace layout, exec, omarchy-hyprland-workspace-layout-toggle"

    # Move focus with SUPER + arrow keys
    "SUPER, LEFT, Move window focus left, movefocus, l"
    "SUPER, RIGHT, Move window focus right, movefocus, r"
    "SUPER, UP, Move window focus up, movefocus, u"
    "SUPER, DOWN, Move window focus down, movefocus, d"

    # Switch workspaces with SUPER + [1-9; 0]
    "SUPER, code:10, Switch to workspace 1, workspace, 1"
    "SUPER, code:11, Switch to workspace 2, workspace, 2"
    "SUPER, code:12, Switch to workspace 3, workspace, 3"
    "SUPER, code:13, Switch to workspace 4, workspace, 4"
    "SUPER, code:14, Switch to workspace 5, workspace, 5"
    "SUPER, code:15, Switch to workspace 6, workspace, 6"
    "SUPER, code:16, Switch to workspace 7, workspace, 7"
    "SUPER, code:17, Switch to workspace 8, workspace, 8"
    "SUPER, code:18, Switch to workspace 9, workspace, 9"
    "SUPER, code:19, Switch to workspace 10, workspace, 10"

    # Move active window to a workspace with SUPER + SHIFT + [1-9; 0]
    "SUPER SHIFT, code:10, Move window to workspace 1, movetoworkspace, 1"
    "SUPER SHIFT, code:11, Move window to workspace 2, movetoworkspace, 2"
    "SUPER SHIFT, code:12, Move window to workspace 3, movetoworkspace, 3"
    "SUPER SHIFT, code:13, Move window to workspace 4, movetoworkspace, 4"
    "SUPER SHIFT, code:14, Move window to workspace 5, movetoworkspace, 5"
    "SUPER SHIFT, code:15, Move window to workspace 6, movetoworkspace, 6"
    "SUPER SHIFT, code:16, Move window to workspace 7, movetoworkspace, 7"
    "SUPER SHIFT, code:17, Move window to workspace 8, movetoworkspace, 8"
    "SUPER SHIFT, code:18, Move window to workspace 9, movetoworkspace, 9"
    "SUPER SHIFT, code:19, Move window to workspace 10, movetoworkspace, 10"

    # Move active window silently to a workspace with SUPER + SHIFT + ALT + [1-9; 0]
    "SUPER SHIFT ALT, code:10, Move window silently to workspace 1, movetoworkspacesilent, 1"
    "SUPER SHIFT ALT, code:11, Move window silently to workspace 2, movetoworkspacesilent, 2"
    "SUPER SHIFT ALT, code:12, Move window silently to workspace 3, movetoworkspacesilent, 3"
    "SUPER SHIFT ALT, code:13, Move window silently to workspace 4, movetoworkspacesilent, 4"
    "SUPER SHIFT ALT, code:14, Move window silently to workspace 5, movetoworkspacesilent, 5"
    "SUPER SHIFT ALT, code:15, Move window silently to workspace 6, movetoworkspacesilent, 6"
    "SUPER SHIFT ALT, code:16, Move window silently to workspace 7, movetoworkspacesilent, 7"
    "SUPER SHIFT ALT, code:17, Move window silently to workspace 8, movetoworkspacesilent, 8"
    "SUPER SHIFT ALT, code:18, Move window silently to workspace 9, movetoworkspacesilent, 9"
    "SUPER SHIFT ALT, code:19, Move window silently to workspace 10, movetoworkspacesilent, 10"

    # Control scratchpad
    "SUPER, S, Toggle scratchpad, togglespecialworkspace, scratchpad"
    "SUPER ALT, S, Move window to scratchpad, movetoworkspacesilent, special:scratchpad"

    # TAB between workspaces
    "SUPER, TAB, Next workspace, workspace, e+1"
    "SUPER SHIFT, TAB, Previous workspace, workspace, e-1"
    "SUPER CTRL, TAB, Former workspace, workspace, previous"

    # Move workspaces to other monitors
    "SUPER SHIFT ALT, LEFT, Move workspace to left monitor, movecurrentworkspacetomonitor, l"
    "SUPER SHIFT ALT, RIGHT, Move workspace to right monitor, movecurrentworkspacetomonitor, r"
    "SUPER SHIFT ALT, UP, Move workspace to up monitor, movecurrentworkspacetomonitor, u"
    "SUPER SHIFT ALT, DOWN, Move workspace to down monitor, movecurrentworkspacetomonitor, d"

    # Swap active window with the one next to it with SUPER + SHIFT + arrow keys
    "SUPER SHIFT, LEFT, Swap window to the left, swapwindow, l"
    "SUPER SHIFT, RIGHT, Swap window to the right, swapwindow, r"
    "SUPER SHIFT, UP, Swap window up, swapwindow, u"
    "SUPER SHIFT, DOWN, Swap window down, swapwindow, d"

    # Cycle through applications on active workspace
    "ALT, TAB, Cycle to next window, cyclenext"
    "ALT SHIFT, TAB, Cycle to prev window, cyclenext, prev"
    "ALT, TAB, Reveal active window on top, bringactivetotop"
    "ALT SHIFT, TAB, Reveal active window on top, bringactivetotop"

    # Resize active window
    "SUPER, code:20, Expand window left, resizeactive, -100 0"
    "SUPER, code:21, Shrink window left, resizeactive, 100 0"
    "SUPER SHIFT, code:20, Shrink window up, resizeactive, 0 -100"
    "SUPER SHIFT, code:21, Expand window down, resizeactive, 0 100"

    # Scroll through existing workspaces with SUPER + scroll
    "SUPER, mouse_down, Scroll active workspace forward, workspace, e+1"
    "SUPER, mouse_up, Scroll active workspace backward, workspace, e-1"

    # Toggle groups
    "SUPER, G, Toggle window grouping, togglegroup"
    "SUPER ALT, G, Move active window out of group, moveoutofgroup"

    # Join groups
    "SUPER ALT, LEFT, Move window to group on left, moveintogroup, l"
    "SUPER ALT, RIGHT, Move window to group on right, moveintogroup, r"
    "SUPER ALT, UP, Move window to group on top, moveintogroup, u"
    "SUPER ALT, DOWN, Move window to group on bottom, moveintogroup, d"

    # Navigate a single set of grouped windows
    "SUPER ALT, TAB, Next window in group, changegroupactive, f"
    "SUPER ALT SHIFT, TAB, Previous window in group, changegroupactive, b"

    # Window navigation for grouped windows
    "SUPER CTRL, LEFT, Move grouped window focus left, changegroupactive, b"
    "SUPER CTRL, RIGHT, Move grouped window focus right, changegroupactive, f"

    # Scroll through a set of grouped windows with SUPER + ALT + scroll
    "SUPER ALT, mouse_down, Next window in group, changegroupactive, f"
    "SUPER ALT, mouse_up, Previous window in group, changegroupactive, b"

    # Activate window in a group by number
    "SUPER ALT, code:10, Switch to group window 1, changegroupactive, 1"
    "SUPER ALT, code:11, Switch to group window 2, changegroupactive, 2"
    "SUPER ALT, code:12, Switch to group window 3, changegroupactive, 3"
    "SUPER ALT, code:13, Switch to group window 4, changegroupactive, 4"
    "SUPER ALT, code:14, Switch to group window 5, changegroupactive, 5"

    # Cycle monitor scaling
    "SUPER, Slash, Cycle monitor scaling, exec, omarchy-hyprland-monitor-scaling-cycle"

    # Copy / Paste / Cut
    "SUPER, C, Universal copy, sendshortcut, CTRL, Insert,"
    "SUPER, V, Universal paste, sendshortcut, SHIFT, Insert,"
    "SUPER, X, Universal cut, sendshortcut, CTRL, X,"
    "SUPER CTRL, V, Clipboard manager, exec, omarchy-launch-walker -m clipboard"
  ];

  # Mouse bindings (bindmd)
  mouseBindings = [
    "SUPER, mouse:272, Move window, movewindow"
    "SUPER, mouse:273, Resize window, resizewindow"
  ];

  # Multimedia bindings (bindeld - repeat enabled, works when locked)
  multimediaBindings = [
    ",XF86AudioRaiseVolume, Volume up, exec, ${osdclient} --output-volume raise"
    ",XF86AudioLowerVolume, Volume down, exec, ${osdclient} --output-volume lower"
    ",XF86AudioMute, Mute, exec, ${osdclient} --output-volume mute-toggle"
    ",XF86AudioMicMute, Mute microphone, exec, ${osdclient} --input-volume mute-toggle"
    ",XF86MonBrightnessUp, Brightness up, exec, omarchy-brightness-display +5%"
    ",XF86MonBrightnessDown, Brightness down, exec, omarchy-brightness-display 5%-"
    ",XF86KbdBrightnessUp, Keyboard brightness up, exec, omarchy-brightness-keyboard up"
    ",XF86KbdBrightnessDown, Keyboard brightness down, exec, omarchy-brightness-keyboard down"

    # Precise 1% multimedia adjustments with Alt modifier
    "ALT, XF86AudioRaiseVolume, Volume up precise, exec, ${osdclient} --output-volume +1"
    "ALT, XF86AudioLowerVolume, Volume down precise, exec, ${osdclient} --output-volume -1"
    "ALT, XF86MonBrightnessUp, Brightness up precise, exec, omarchy-brightness-display +1%"
    "ALT, XF86MonBrightnessDown, Brightness down precise, exec, omarchy-brightness-display 1%-"
  ];

  # Keyboard backlight cycle (bindld - works when locked)
  kbdBacklightBindings = [
    ",XF86KbdLightOnOff, Keyboard backlight cycle, exec, omarchy-brightness-keyboard cycle"
  ];

  # Media player bindings (bindld - works when locked)
  mediaPlayerBindings = [
    ", XF86AudioNext, Next track, exec, ${osdclient} --playerctl next"
    ", XF86AudioPause, Pause, exec, ${osdclient} --playerctl play-pause"
    ", XF86AudioPlay, Play, exec, ${osdclient} --playerctl play-pause"
    ", XF86AudioPrev, Previous track, exec, ${osdclient} --playerctl previous"

    # Switch audio output with Super + Mute
    "SUPER, XF86AudioMute, Switch audio output, exec, omarchy-cmd-audio-switch"

    # Power menu
    ", XF86PowerOff, Power menu, exec, omarchy-menu system"

    # Calculator
    ", XF86Calculator, Calculator, exec, gnome-calculator"
  ];
in {
  wayland.windowManager.hyprland = {
    extraConfig = ''
      # Quick app bindings
      ${mkBindd cfg.quick_app_bindings}

      # Main descriptive bindings
      ${mkBindd mainBindings}

      # Dictation bindings
      ${mkBindd dictationBindings}

      # Mouse bindings
      ${mkBindmd mouseBindings}

      # Multimedia bindings (repeat enabled, works when locked)
      ${mkBindeld multimediaBindings}

      # Keyboard backlight cycle (works when locked)
      ${mkBindld kbdBacklightBindings}

      # Media player bindings (works when locked)
      ${mkBindld mediaPlayerBindings}
    '';
  };
}
