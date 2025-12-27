{
  config,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
      "suppressevent maximize,class:.*"

      # Force brave into a tile to deal with --app bug
      "tile,class:^(brave-browser)$"

      # Settings management
      "float,class:^(org.pulseaudio.pavucontrol|blueberry.py)$"

      # Float Steam, fullscreen RetroArch
      "float,class:^(steam)$"
      "fullscreen,class:^(com.libretro.RetroArch)$"

      # Just dash of transparency
      "opacity 0.97 0.9,class:.*"
      # Normal chrome Youtube tabs
      "opacity 1 1,class:^(chromium|google-chrome|google-chrome-unstable)$,title:.*Youtube.*"
      "opacity 1 0.97,class:^(chromium|google-chrome|google-chrome-unstable)$"
      "opacity 0.97 0.9,initialClass:^(chrome-.*-Default)$"
      "opacity 1 1,initialClass:^(chrome-youtube.*-Default)$"
      "opacity 1 1,class:^(zoom|vlc|org.kde.kdenlive|com.obsproject.Studio)$"
      "opacity 1 1,class:^(com.libretro.RetroArch|steam)$"

      # Fix some dragging issues with XWayland
      "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"

      # Float in the middle for clipse clipboard manager
      "float,class:(clipse)"
      "size 622 652,class:(clipse)"
      "stayfocused,class:(clipse)"

      # Screensaver window rules
      "fullscreen,class:^(org.omarchy.screensaver)$"
      "float,class:^(org.omarchy.screensaver)$"
      "noblur,class:^(org.omarchy.screensaver)$"
      "noshadow,class:^(org.omarchy.screensaver)$"
      "noborder,class:^(org.omarchy.screensaver)$"

      # Prevent idle/sleep for tagged windows (e.g., during updates)
      "idleinhibit always,tag:noidle"
    ];
  };
}
