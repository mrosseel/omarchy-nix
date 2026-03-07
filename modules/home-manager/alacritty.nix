{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  programs.alacritty = {
    enable = true;
    settings = {
      # Load theme from runtime config (allows dynamic theme switching)
      general.import = ["~/.config/omarchy/current/theme/alacritty.toml"];

      env.TERM = "xterm-256color";

      terminal.osc52 = "CopyPaste";

      font = {
        size = 9;
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
      };

      window = {
        padding = {
          x = 14;
          y = 14;
        };
        decorations = "None";
      };

      # Universal copy/paste (works with Hyprland's Super+C/V → Ctrl/Shift+Insert mapping)
      keyboard.bindings = [
        { key = "Insert"; mods = "Shift"; action = "Paste"; }
        { key = "Insert"; mods = "Control"; action = "Copy"; }
      ];
    };
  };
}
