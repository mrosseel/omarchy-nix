{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omarchy;
  # Use seamless_boot.username if set, otherwise use main username
  username =
    if cfg.seamless_boot.username != null
    then cfg.seamless_boot.username
    else cfg.username;
in {
  # Allow the user to run nixos-rebuild without a password for theme switching
  # Use wildcard to allow any nix store path version
  security.sudo.extraRules = [
    {
      users = [username];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = ["NOPASSWD" "SETENV"];
        }
      ];
    }
    # Setup > Timezone picks a zone without a password prompt.
    # Mirrors etc/sudoers.d/omarchy-tzupdate. quattro dropped the NOPASSWD on
    # tzupdate itself (it took a URL and ran as root); only the timedatectl call
    # is passwordless now.
    {
      groups = ["wheel"];
      runAs = "root";
      commands = [
        {
          command = "/run/current-system/sw/bin/timedatectl set-timezone *";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # Mirrors etc/sudoers.d/omarchy-passwd-tries: three tries is easy to burn on a
  # long passphrase typed into a lock screen prompt.
  # Mirrors etc/sudoers.d/omarchy-sudo-timeout (#17000): one sudo password
  # lasts ten minutes in a terminal.
  security.sudo.extraConfig = ''
    Defaults passwd_tries=10
    Defaults timestamp_timeout=10
  '';
}
