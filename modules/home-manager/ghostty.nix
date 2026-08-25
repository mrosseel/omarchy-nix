{
  config,
  pkgs,
  ...
}: let
  cfg = config.omarchy;
in {
  programs.ghostty = {
    enable = true;
    settings = {
      # Window settings
      window-padding-x = 14;
      window-padding-y = 14;
      window-theme = "ghostty";
      resize-overlay = "never";
      gtk-toolbar-style = "flat";

      font-family = "JetBrainsMono Nerd Font";
      font-style = "Regular";
      font-size = 9;

      # Load theme from runtime config (allows dynamic theme switching)
      config-file = "?~/.local/state/omarchy/current/theme/ghostty.conf";

      # Cursor styling
      cursor-style = "block";
      cursor-style-blink = false;

      # Cursor styling + SSH session terminfo
      shell-integration-features = "no-cursor,ssh-env";

      keybind = [
        # Universal copy/paste (works with Hyprland's Super+C/V → Ctrl/Shift+Insert mapping)
        "shift+insert=paste_from_clipboard"
        "control+insert=copy_to_clipboard"
        # Send Shift+Return / Alt+Shift+Return as CSI-u so TUIs and tmux can
        # distinguish them from Return / Alt+Return.
        "shift+enter=csi:13;2u"
        "alt+shift+enter=csi:13;4u"
        # Split resize (Super+Ctrl+Shift+Alt+Arrow)
        "super+control+shift+alt+arrow_down=resize_split:down,100"
        "super+control+shift+alt+arrow_up=resize_split:up,100"
        "super+control+shift+alt+arrow_left=resize_split:left,100"
        "super+control+shift+alt+arrow_right=resize_split:right,100"
      ];

      # Slowdown mouse scrolling
      mouse-scroll-multiplier = 0.95;

      # Disable "potentially unsafe paste" warning
      clipboard-paste-protection = false;

      # Disable close confirmation dialog
      confirm-close-surface = false;

      # Fix general slowness on Hyprland
      async-backend = "epoll";
    };
  };
}
