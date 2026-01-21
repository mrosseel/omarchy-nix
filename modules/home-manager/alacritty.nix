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

      font = {
        size = 12;
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
      };

      window = {
        padding = {
          x = 10;
          y = 10;
        };
        opacity = 0.95;
      };
    };
  };
}
