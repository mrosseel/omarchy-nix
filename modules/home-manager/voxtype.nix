{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
  voxtype = pkgs.callPackage ../../packages/voxtype.nix {};
in {
  config = lib.mkIf cfg.voxtype.enable {
    # Deploy default voxtype config
    home.file.".config/voxtype/config.toml" = {
      source = ../../default/voxtype/config.toml;
    };

    # Systemd user service for voxtype daemon
    systemd.user.services.voxtype = {
      Unit = {
        Description = "Voxtype voice dictation daemon";
        After = ["graphical-session.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${voxtype}/bin/voxtype daemon";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
