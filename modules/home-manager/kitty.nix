{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };

    settings = {
      # Window appearance
      window_padding_width = 10;
      background_opacity = "0.95";

      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";

      # Colors from nix-colors base16 scheme
      foreground = "#${config.colorScheme.palette.base05}";
      background = "#${config.colorScheme.palette.base00}";
      selection_foreground = "#${config.colorScheme.palette.base00}";
      selection_background = "#${config.colorScheme.palette.base05}";

      # Cursor colors
      cursor = "#${config.colorScheme.palette.base05}";
      cursor_text_color = "#${config.colorScheme.palette.base00}";

      # URL underline color when hovering
      url_color = "#${config.colorScheme.palette.base0D}";

      # Tab bar colors
      active_tab_foreground = "#${config.colorScheme.palette.base00}";
      active_tab_background = "#${config.colorScheme.palette.base0D}";
      inactive_tab_foreground = "#${config.colorScheme.palette.base05}";
      inactive_tab_background = "#${config.colorScheme.palette.base01}";

      # Normal colors
      color0 = "#${config.colorScheme.palette.base00}";  # black
      color1 = "#${config.colorScheme.palette.base08}";  # red
      color2 = "#${config.colorScheme.palette.base0B}";  # green
      color3 = "#${config.colorScheme.palette.base0A}";  # yellow
      color4 = "#${config.colorScheme.palette.base0D}";  # blue
      color5 = "#${config.colorScheme.palette.base0E}";  # magenta
      color6 = "#${config.colorScheme.palette.base0C}";  # cyan
      color7 = "#${config.colorScheme.palette.base05}";  # white

      # Bright colors
      color8 = "#${config.colorScheme.palette.base03}";   # bright black
      color9 = "#${config.colorScheme.palette.base08}";   # bright red
      color10 = "#${config.colorScheme.palette.base0B}";  # bright green
      color11 = "#${config.colorScheme.palette.base0A}";  # bright yellow
      color12 = "#${config.colorScheme.palette.base0D}";  # bright blue
      color13 = "#${config.colorScheme.palette.base0E}";  # bright magenta
      color14 = "#${config.colorScheme.palette.base0C}";  # bright cyan
      color15 = "#${config.colorScheme.palette.base07}";  # bright white
    };
  };
}
