inputs: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omarchy;
  hex = pkgs.callPackage ../../packages/hex.nix {hexSrc = inputs.hex;};
in {
  config = lib.mkIf cfg.hex.enable {
    environment.systemPackages = [hex];

    # The package ships hex.service as a user unit. Upstream's installer runs
    # `systemctl --user enable hex.service`. On NixOS that puts a link to the
    # store path in ~/.config/systemd/user, and the link breaks after an update
    # and a garbage collection. So NixOS enables the unit here, and the
    # installer does not.
    systemd.packages = [hex];
    systemd.user.services.hex = {
      overrideStrategy = "asDropin";
      wantedBy = ["graphical-session.target"];
    };
  };
}
