{
  config,
  pkgs,
  lib,
  ...
}: {
  systemd.user.services.omarchy-battery-monitor = {
    Unit = {
      Description = "Omarchy Battery Monitor";
      After = ["graphical-session.target"];
    };

    Service = {
      Type = "simple";
      ExecStart = "${config.home.homeDirectory}/.local/share/omarchy/bin/omarchy-battery-monitor";
      Restart = "on-failure";
      RestartSec = 10;
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
