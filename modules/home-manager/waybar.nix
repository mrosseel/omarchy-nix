inputs: {
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  home.file = {
    ".config/waybar/" = {
      source = ../../config/waybar;
      recursive = true;
    };
  };

  # Waybar reads theme from symlinked theme directory
  xdg.configFile."waybar/theme.css".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/omarchy/current/theme/waybar.css";

  # Install waybar package without generated config
  # Config is provided via static file in config/waybar/config
  # This preserves the U+E900 omarchy icon character which gets stripped by Nix's JSON encoding
  home.packages = [ pkgs.waybar ];
}
