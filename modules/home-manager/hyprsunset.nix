{
  config,
  pkgs,
  lib,
  ...
}: {
  # Hyprsunset - Blue light filter with manual toggle support
  # Default configuration disables automatic tinting
  # Use omarchy-toggle-nightlight to toggle nightlight mode

  xdg.configFile."hypr/hyprsunset.conf".text = ''
    # Makes hyprsunset do nothing to the screen by default
    # Without this, the default applies some tint to the monitor
    profile {
        time = 07:00
        identity = true
    }

    # To enable auto switch to nightlight, uncomment the following:
    # profile {
    #     time = 20:00
    #     temperature = 4000
    # }
  '';

  # Systemd user service for hyprsunset
  systemd.user.services.hyprsunset = {
    Unit = {
      Description = "Hyprsunset - Blue light filter for Hyprland";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };

    Service = {
      ExecStart = "${pkgs.hyprsunset}/bin/hyprsunset";
      Restart = "on-failure";
      RestartSec = 3;
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
