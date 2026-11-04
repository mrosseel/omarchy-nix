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

    # The package ships hex.service as a user unit.
    # omarchy-install-dictation-hex enables it.
    systemd.packages = [hex];
  };
}
