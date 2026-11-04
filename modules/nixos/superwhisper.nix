{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omarchy;
  superwhisper = pkgs.callPackage ../../packages/superwhisper.nix {};
in {
  config = lib.mkIf cfg.superwhisper.enable {
    # The OPR package installs the app to /opt/superwhisper, the launcher to
    # /usr/bin and setup-user to /usr/share/superwhisper. setup-user and
    # omarchy-remove-dictation-superwhisper link and unlink those paths in the
    # home directory, so they point at the current build here.
    systemd.tmpfiles.rules = [
      "d /opt 0755 root root -"
      "L+ /opt/superwhisper - - - - ${superwhisper}/opt/superwhisper"
      "L+ /usr/bin/superwhisper - - - - ${superwhisper}/bin/superwhisper"
      "L+ /usr/share/superwhisper - - - - ${superwhisper}/share/superwhisper"
    ];

    # The package ships superwhisper.service as a user unit. setup-user
    # enables it.
    systemd.packages = [superwhisper];

    # The recording pill draws its status text with this font.
    fonts.packages = [superwhisper];
  };
}
