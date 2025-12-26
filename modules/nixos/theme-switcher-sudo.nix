{
  config,
  lib,
  pkgs,
  ...
}: {
  # Allow the user to run nixos-rebuild without a password for theme switching
  security.sudo.extraRules = [
    {
      users = [ config.omarchy.seamless_boot.username or "mike" ];
      commands = [
        {
          command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake /home/${config.omarchy.seamless_boot.username or "mike"}/nixos-config";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}