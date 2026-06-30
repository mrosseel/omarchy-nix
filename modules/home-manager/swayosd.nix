{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  # Retired by the Omarchy 4 shell (omarchy-shell owns the OSD). Gated off when
  # omarchy.shell.enable so the shell's osd plugin handles volume/brightness.
  config = lib.mkIf (!cfg.shell.enable) {
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

    # Run swayosd-server as a session systemd unit instead of an
    # exec-once in autostart.conf (upstream commit fa1ed01c). Pairs with
    # the omarchy-restart-swayosd update from the bulk re-port, which now
    # prefers `systemctl --user restart swayosd-server.service` when the
    # unit is enabled.
    systemd.user.services.swayosd-server = {
      Unit = {
        Description = "SwayOSD server";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.swayosd}/bin/swayosd-server";
        Restart = "always";
        RestartSec = 2;
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
