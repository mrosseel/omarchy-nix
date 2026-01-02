{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  # SwayOSD configuration for volume/brightness OSD
  home.file.".config/swayosd/config.toml".text = ''
    [server]
    show_percentage = true
    max_volume = 100
    style = "./style.css"
  '';

  home.file.".config/swayosd/style.css".text = ''
    @import "../omarchy/current/theme/swayosd.css";

    window {
      border-radius: 0;
      opacity: 0.97;
      border: 2px solid @border-color;

      background-color: @background-color;
    }

    label {
      font-family: 'JetBrainsMono Nerd Font';
      font-size: 11pt;

      color: @label;
    }

    image {
      color: @image;
    }

    progressbar {
      border-radius: 0;
    }

    progress {
      background-color: @progress;
    }
  '';
}
