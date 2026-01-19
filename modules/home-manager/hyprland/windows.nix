{
  config,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    # New windowrule syntax (hyprland 0.45+)
    windowrule = [
      # Fullscreen screensaver
      "fullscreen on, match:class org.omarchy.screensaver"
      "float on, match:class org.omarchy.screensaver"
      "opacity 1 1, match:class org.omarchy.screensaver"
    ];

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
      "opacity 1 1,class:^(com.libretro.RetroArch)$"
      "idleinhibit fullscreen,class:^(com.libretro.RetroArch)$"

      # DaVinci Resolve - keep floating dialogs focused
      "stayfocused,class:.*[Rr]esolve.*,floating:1"

      # JetBrains IDEs - complex window management
      "tag +jetbrains-splash,class:^(jetbrains-.*)$,title:^(splash)$,floating:1"
      "center,tag:jetbrains-splash"
      "nofocus,tag:jetbrains-splash"
      "noborder,tag:jetbrains-splash"
      "tag +jetbrains,class:^(jetbrains-.*),title:^()$,floating:1"
      "center,tag:jetbrains"
      "stayfocused,tag:jetbrains"
      "noborder,tag:jetbrains"
      "size >50% >50%,class:^(jetbrains-.*),title:^()$,floating:1"
      "noinitialfocus,class:^(jetbrains-.*)$,title:^(win.*)$,floating:1"
      "nofollowmouse,class:^(jetbrains-.*)$"

      # QEMU - disable transparency
      "opacity 1 1,class:^(qemu)$"

      # Webcam overlay for screen recording
      "float,title:^(WebcamOverlay)$"
      "pin,title:^(WebcamOverlay)$"
      "noinitialfocus,title:^(WebcamOverlay)$"
      "nodim,title:^(WebcamOverlay)$"
      "move 100%-w-40 100%-w-40,title:^(WebcamOverlay)$"

      # Picture-in-picture overlays
      "tag +pip,title:(Picture.?in.?[Pp]icture)"
      "float,tag:pip"
      "pin,tag:pip"
      "size 600 338,tag:pip"
      "keepaspectratio,tag:pip"
      "noborder,tag:pip"
      "opacity 1 1,tag:pip"
      "move 100%-w-40 4%,tag:pip"

      # LocalSend and Share dialogs
      "float,class:(Share|localsend)"
      "center,class:(Share|localsend)"

      # Floating windows - system TUI apps and dialogs
      "tag +floating-window,class:(org.omarchy.bluetui|org.omarchy.impala|org.omarchy.wiremix|org.omarchy.btop|org.omarchy.terminal|org.omarchy.bash|org.gnome.NautilusPreviewer|org.gnome.Evince|com.gabm.satty|Omarchy|About|TUI.float|imv|mpv)"
      "tag +floating-window,class:(xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus),title:^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)"
      "float,tag:floating-window"
      "center,tag:floating-window"
      "size 875 600,tag:floating-window"

      # Bitwarden - float by default
      "float,class:^(Bitwarden|bitwarden)$"

      # Calculator always floats
      "float,class:^(org.gnome.Calculator)$"

      # Pop window rounding
      "rounding 8,tag:pop"

      # Just dash of transparency
      "opacity 0.97 0.9,class:.*"
      # Normal chrome Youtube tabs
      "opacity 1 1,class:^(chromium|google-chrome|google-chrome-unstable)$,title:.*Youtube.*"
      "opacity 1 0.97,class:^(chromium|google-chrome|google-chrome-unstable)$"
      "opacity 0.97 0.9,initialClass:^(chrome-.*-Default)$"
      "opacity 1 1,initialClass:^(chrome-youtube.*-Default)$"
      # No transparency on media windows
      "opacity 1 1,class:^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$"
      "opacity 1 1,class:^(com.libretro.RetroArch|steam)$"

      # Fix some dragging issues with XWayland
      "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"

      # Float in the middle for clipse clipboard manager
      "float,class:(clipse)"
      "size 622 652,class:(clipse)"
      "stayfocused,class:(clipse)"

      # Prevent idle/sleep for tagged windows (e.g., during updates)
      "idleinhibit always,tag:noidle"
    ];

    # Layer rules
    layerrule = [
      # Disable animations for selection layer (screenshot tool)
      "no_anim on, match:namespace selection"
    ];
  };
}
