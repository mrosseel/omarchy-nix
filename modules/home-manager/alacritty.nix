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

      # Colors from nix-colors base16 scheme
      colors = with config.colorScheme.palette; {
        primary = {
          background = "#${base00}";
          foreground = "#${base05}";
        };

        cursor = {
          text = "#${base00}";
          cursor = "#${base05}";
        };

        normal = {
          black = "#${base00}";
          red = "#${base08}";
          green = "#${base0B}";
          yellow = "#${base0A}";
          blue = "#${base0D}";
          magenta = "#${base0E}";
          cyan = "#${base0C}";
          white = "#${base05}";
        };

        bright = {
          black = "#${base03}";
          red = "#${base08}";
          green = "#${base0B}";
          yellow = "#${base0A}";
          blue = "#${base0D}";
          magenta = "#${base0E}";
          cyan = "#${base0C}";
          white = "#${base07}";
        };
      };
    };
  };
}
