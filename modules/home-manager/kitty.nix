{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  programs.kitty = {
    enable = lib.mkDefault true;

    font = {
      name = lib.mkDefault "JetBrainsMono Nerd Font";
      size = lib.mkDefault 12;
    };

    settings = lib.mkDefault {
      # Load theme from runtime config (allows dynamic theme switching)
      include = "~/.config/omarchy/current/theme/kitty.conf";

      # Window appearance
      window_padding_width = 10;
      background_opacity = "0.95";

      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";
    };

    keybindings = {
      # Universal copy/paste (works with Hyprland's Super+C/V → Ctrl/Shift+Insert mapping)
      "ctrl+insert" = "copy_to_clipboard";
      "shift+insert" = "paste_from_clipboard";
    };
  };
}
