{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
  # Omarchy 4 shell mode: route launcher/menu/notifications/panels/OSD/media at
  # the omarchy-shell IPC instead of walker/mako/swayosd (which are retired).
  shell = cfg.shell.enable;
  # OSD client for the currently focused monitor
  osdclient = "swayosd-client --monitor \"$(omarchy-hyprland-monitor-focused)\"";
  # Volume control: swayosd-client (classic) vs omarchy-audio-output-volume,
  # which drives the shell's own OSD (Omarchy 4). Both take the same args.
  volctl =
    if shell
    then "omarchy-audio-output-volume"
    else "${osdclient} --output-volume";

  # Convert binding lists to extraConfig strings
  mkBindd = bindings: lib.concatMapStringsSep "\n" (binding: "bindd = ${binding}") bindings;
  mkBinddr = bindings: lib.concatMapStringsSep "\n" (binding: "binddr = ${binding}") bindings;
  mkBindeld = bindings: lib.concatMapStringsSep "\n" (binding: "bindeld = ${binding}") bindings;
  mkBindld = bindings: lib.concatMapStringsSep "\n" (binding: "bindld = ${binding}") bindings;
  mkBindmd = bindings: lib.concatMapStringsSep "\n" (binding: "bindmd = ${binding}") bindings;
  mkBindl = bindings: lib.concatMapStringsSep "\n" (binding: "bindl = ${binding}") bindings;

  # Dictation bindings (only when voxtype is enabled)
  dictationBindings = lib.optionals cfg.voxtype.enable [
    "SUPER CTRL, X, Toggle dictation, exec, voxtype record toggle"
    ", F9, Start dictation (push-to-talk), exec, voxtype record start"
  ];

  # Push-to-talk release for voxtype (only when enabled)
  dictationReleaseBindings = lib.optionals cfg.voxtype.enable [
    ", F9, Stop dictation (push-to-talk), exec, voxtype record stop"
  ];

  # Main descriptive bindings
  mainBindings = [
    # Menus
    "SUPER, SPACE, Launch apps, exec, ${
      if shell
      then "omarchy-shell shell toggle omarchy.launcher \"{}\""
      else "omarchy-launch-walker"
    }"
    "SUPER CTRL, E, Emoji picker, exec, ${
      if shell
      then "omarchy-shell shell toggle omarchy.emojis"
      else "omarchy-launch-walker -m symbols"
    }"
    "SUPER CTRL, C, Capture menu, exec, omarchy-menu capture"
    "SUPER CTRL, O, Toggle menu, exec, omarchy-menu toggle"
    "SUPER ALT, SPACE, Omarchy menu, exec, omarchy-menu"
    "SUPER SHIFT, code:201, Omarchy menu, exec, omarchy-menu"
    "SUPER, ESCAPE, System menu, exec, omarchy-menu system"
    "SUPER, K, Show key bindings, exec, omarchy-show-keybindings"

    # Aesthetics
    "SUPER SHIFT, SPACE, Toggle top bar, exec, ${
      if shell
      then "omarchy-toggle-bar"
      else "omarchy-toggle-waybar"
    }"
    "SUPER CTRL, SPACE, Theme background menu, exec, omarchy-menu background"
    "SUPER SHIFT CTRL, SPACE, Theme menu, exec, omarchy-menu theme"
    "SUPER, BACKSPACE, Toggle window transparency, exec, omarchy-hyprland-active-window-transparency-toggle"
    "SUPER SHIFT, BACKSPACE, Toggle window gaps, exec, omarchy-hyprland-window-gaps-toggle"
    "SUPER CTRL, BACKSPACE, Toggle single-window square aspect, exec, omarchy-hyprland-window-single-square-aspect-toggle"

    # Notifications
    "SUPER, COMMA, Dismiss last notification, exec, ${
      if shell
      then "omarchy-shell notifications dismissOne"
      else "makoctl dismiss"
    }"
    "SUPER SHIFT, COMMA, Dismiss all notifications, exec, ${
      if shell
      then "omarchy-shell notifications dismissAll"
      else "makoctl dismiss --all"
    }"
    "SUPER CTRL, COMMA, Toggle silencing notifications, exec, omarchy-toggle-notification-silencing"
    "SUPER ALT, COMMA, Invoke last notification, exec, ${
      if shell
      then "omarchy-shell notifications invokeLast"
      else "makoctl invoke"
    }"
    "SUPER SHIFT ALT, COMMA, Restore last notification, exec, ${
      if shell
      then "omarchy-shell notifications showHistory"
      else "makoctl restore"
    }"

    # Toggles
    "SUPER CTRL, I, Toggle locking on idle, exec, omarchy-toggle-idle"
    "SUPER CTRL, N, Toggle nightlight, exec, omarchy-toggle-nightlight"
    "SUPER CTRL, Delete, Toggle laptop display, exec, omarchy-hyprland-monitor-internal toggle"
    "SUPER CTRL ALT, Delete, Toggle laptop display mirroring, exec, omarchy-hyprland-monitor-internal-mirror toggle"

    # Hardware menu (capture/toggle menus already in Menus group above)
    "SUPER CTRL, H, Hardware menu, exec, omarchy-menu hardware"

    # Control Apple Display brightness
    "CTRL, F1, Apple Display brightness down, exec, omarchy-brightness-display -5000"
    "CTRL, F2, Apple Display brightness up, exec, omarchy-brightness-display +5000"
    "SHIFT CTRL, F2, Apple Display full brightness, exec, omarchy-brightness-display +60000"

    # Captures
    ", PRINT, Screenshot, exec, omarchy-capture-screenshot"
    "ALT, PRINT, Screenrecording, exec, omarchy-menu screenrecord"
    "SUPER, PRINT, Color picker, exec, pkill hyprpicker || hyprpicker -a"

    # File sharing
    "SUPER CTRL, S, Share, exec, omarchy-menu share"

    # Waybar-less information
    "SUPER CTRL ALT, T, Show time, exec, notify-send -u low \"    $(date +\"%A %H:%M  ·  %d %B %Y  ·  Week %V\")\""
    "SUPER CTRL ALT, B, Show battery remaining, exec, notify-send -u low \"$(omarchy-battery-status)\""

    # Control panels
    "SUPER CTRL, A, Audio controls, exec, ${
      if shell
      then "omarchy-shell omarchy.audio toggle"
      else "omarchy-launch-audio"
    }"
    "SUPER CTRL, B, Bluetooth controls, exec, ${
      if shell
      then "omarchy-shell omarchy.bluetooth toggle"
      else "omarchy-launch-bluetooth"
    }"
    "SUPER CTRL, W, Wifi controls, exec, ${
      if shell
      then "omarchy-shell omarchy.network toggle"
      else "omarchy-launch-wifi"
    }"
    "SUPER CTRL, T, Activity, exec, omarchy-launch-tui btop"

    # Zoom
    "SUPER CTRL, Z, Zoom in, exec, hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float + 1')"
    "SUPER CTRL ALT, Z, Reset zoom, exec, hyprctl keyword cursor:zoom_factor 1"

    # Lock system
    "SUPER CTRL, L, Lock system, exec, omarchy-system-lock"

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

    # Switch workspaces with SUPER + F1-F10 (workspaces 11-20)
    "SUPER, F1, Switch to workspace 11, workspace, 11"
    "SUPER, F2, Switch to workspace 12, workspace, 12"
    "SUPER, F3, Switch to workspace 13, workspace, 13"
    "SUPER, F4, Switch to workspace 14, workspace, 14"
    "SUPER, F5, Switch to workspace 15, workspace, 15"
    "SUPER, F6, Switch to workspace 16, workspace, 16"
    "SUPER, F7, Switch to workspace 17, workspace, 17"
    "SUPER, F8, Switch to workspace 18, workspace, 18"
    "SUPER, F9, Switch to workspace 19, workspace, 19"
    "SUPER, F10, Switch to workspace 20, workspace, 20"

    # Move active window to workspace with SUPER + SHIFT + F1-F10
    "SUPER SHIFT, F1, Move window to workspace 11, movetoworkspace, 11"
    "SUPER SHIFT, F2, Move window to workspace 12, movetoworkspace, 12"
    "SUPER SHIFT, F3, Move window to workspace 13, movetoworkspace, 13"
    "SUPER SHIFT, F4, Move window to workspace 14, movetoworkspace, 14"
    "SUPER SHIFT, F5, Move window to workspace 15, movetoworkspace, 15"
    "SUPER SHIFT, F6, Move window to workspace 16, movetoworkspace, 16"
    "SUPER SHIFT, F7, Move window to workspace 17, movetoworkspace, 17"
    "SUPER SHIFT, F8, Move window to workspace 18, movetoworkspace, 18"
    "SUPER SHIFT, F9, Move window to workspace 19, movetoworkspace, 19"
    "SUPER SHIFT, F10, Move window to workspace 20, movetoworkspace, 20"

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
    "SUPER, C, Universal copy, sendshortcut, CTRL, Insert, activewindow"
    "SUPER, V, Universal paste, sendshortcut, SHIFT, Insert, activewindow"
    "SUPER, X, Universal cut, sendshortcut, CTRL, X, activewindow"
    "SUPER CTRL, V, Clipboard manager, exec, ${
      if shell
      then "omarchy-shell shell toggle omarchy.clipboard"
      else "omarchy-launch-walker -m clipboard"
    }"
  ];

  # Shell-only panel bindings new in Omarchy 4 (Display + Power popouts).
  shellOnlyBindings = lib.optionals shell [
    "SUPER CTRL, D, Display, exec, omarchy-shell omarchy.monitor toggle"
    "SUPER CTRL, P, Power, exec, omarchy-shell omarchy.power toggle"
  ];

  # Mouse bindings (bindmd)
  mouseBindings = [
    "SUPER, mouse:272, Move window, movewindow"
    "SUPER, mouse:273, Resize window, resizewindow"
  ];

  # Multimedia bindings (bindeld - repeat enabled, works when locked)
  multimediaBindings = [
    ",XF86AudioRaiseVolume, Volume up, exec, ${volctl} raise"
    ",XF86AudioLowerVolume, Volume down, exec, ${volctl} lower"
    ",XF86AudioMute, Mute, exec, ${volctl} mute-toggle"
    ",XF86AudioMicMute, Mute microphone, exec, omarchy-audio-input-mute"
    ",XF86MonBrightnessUp, Brightness up, exec, omarchy-brightness-display +5%"
    ",XF86MonBrightnessDown, Brightness down, exec, omarchy-brightness-display 5%-"
    ",XF86KbdBrightnessUp, Keyboard brightness up, exec, omarchy-brightness-keyboard up"
    ",XF86KbdBrightnessDown, Keyboard brightness down, exec, omarchy-brightness-keyboard down"

    # Precise 1% multimedia adjustments with Alt modifier
    "ALT, XF86AudioRaiseVolume, Volume up precise, exec, ${volctl} +1"
    "ALT, XF86AudioLowerVolume, Volume down precise, exec, ${volctl} -1"
    "ALT, XF86MonBrightnessUp, Brightness up precise, exec, omarchy-brightness-display +1%"
    "ALT, XF86MonBrightnessDown, Brightness down precise, exec, omarchy-brightness-display 1%-"
  ];

  # Keyboard backlight cycle (bindld - works when locked)
  kbdBacklightBindings = [
    ",XF86KbdLightOnOff, Keyboard backlight cycle, exec, omarchy-brightness-keyboard cycle"
    ",XF86TouchpadToggle, Toggle touchpad, exec, omarchy-toggle-touchpad"
    ",XF86TouchpadOn, Enable touchpad, exec, omarchy-toggle-touchpad on"
    ",XF86TouchpadOff, Disable touchpad, exec, omarchy-toggle-touchpad off"
  ];

  # Lid switch bindings (bindl - works when locked, no description form)
  switchBindings = [
    ", switch:on:Lid Switch, exec, omarchy-hw-external-monitors && omarchy-hyprland-monitor-internal off"
    ", switch:off:Lid Switch, exec, omarchy-hyprland-monitor-internal on"
  ];

  # Media player bindings (bindld - works when locked)
  mediaPlayerBindings = [
    ", XF86AudioNext, Next track, exec, ${
      if shell
      then "omarchy-shell media next"
      else "${osdclient} --playerctl next"
    }"
    ", XF86AudioPause, Pause, exec, ${
      if shell
      then "omarchy-shell media playPause"
      else "${osdclient} --playerctl play-pause"
    }"
    ", XF86AudioPlay, Play, exec, ${
      if shell
      then "omarchy-shell media playPause"
      else "${osdclient} --playerctl play-pause"
    }"
    ", XF86AudioPrev, Previous track, exec, ${
      if shell
      then "omarchy-shell media previous"
      else "${osdclient} --playerctl previous"
    }"

    # Switch audio output with Super + Mute
    "SUPER, XF86AudioMute, Switch audio output, exec, omarchy-audio-output-switch"

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
      ${mkBindd (mainBindings ++ shellOnlyBindings)}

      # Dictation bindings
      ${mkBindd dictationBindings}
      ${mkBinddr dictationReleaseBindings}

      # Mouse bindings
      ${mkBindmd mouseBindings}

      # Multimedia bindings (repeat enabled, works when locked)
      ${mkBindeld multimediaBindings}

      # Keyboard backlight cycle (works when locked)
      ${mkBindld kbdBacklightBindings}

      # Media player bindings (works when locked)
      ${mkBindld mediaPlayerBindings}

      # Lid switch (works when locked)
      ${mkBindl switchBindings}
    '';
  };
}
