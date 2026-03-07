{
  config,
  pkgs,
  ...
}: let
  cfg = config.omarchy;
  palette = config.colorScheme.palette;
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
      config-file = "?~/.config/omarchy/current/theme/ghostty.conf";

      # Cursor styling
      cursor-style = "block";
      cursor-style-blink = false;

      # Cursor styling + SSH session terminfo
      shell-integration-features = "no-cursor,ssh-env";

      keybind = [
        # Universal copy/paste (works with Hyprland's Super+C/V → Ctrl/Shift+Insert mapping)
        "shift+insert=paste_from_clipboard"
        "control+insert=copy_to_clipboard"
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
    themes = {
      omarchy = {
        background = "#${palette.base00}";
        foreground = "#${palette.base05}";

        selection-background = "#${palette.base02}";
        selection-foreground = "#${palette.base00}";
        palette = [
          "0=#${palette.base00}"
          "1=#${palette.base08}"
          "2=#${palette.base0B}"
          "3=#${palette.base0A}"
          "4=#${palette.base0D}"
          "5=#${palette.base0E}"
          "6=#${palette.base0C}"
          "7=#${palette.base05}"
          "8=#${palette.base03}"
          "9=#${palette.base08}"
          "10=#${palette.base0B}"
          "11=#${palette.base0A}"
          "12=#${palette.base0D}"
          "13=#${palette.base0E}"
          "14=#${palette.base0C}"
          "15=#${palette.base07}"
          "16=#${palette.base09}"
          "17=#${palette.base0F}"
          "18=#${palette.base01}"
          "19=#${palette.base02}"
          "20=#${palette.base04}"
          "21=#${palette.base06}"
        ];
      };
    };
  };
}
