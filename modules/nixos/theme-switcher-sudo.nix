{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omarchy;
  # Use seamless_boot.username if set, otherwise use main username
  username = if cfg.seamless_boot.username != null
             then cfg.seamless_boot.username
             else cfg.username;
in {
  # Allow the user to run nixos-rebuild without a password for theme switching
  # Use wildcard to allow any nix store path version
  security.sudo.extraRules = [
    {
      users = [ username ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" "SETENV" ];
        }
      ];
    }
  ];
}