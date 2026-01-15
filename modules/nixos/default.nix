inputs: {
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
  packages = import ../packages.nix {inherit pkgs config lib;};
in {
  imports = [
    (import ./hyprland.nix inputs)
    (import ./system.nix inputs)
    (import ./1password.nix)
    (import ./containers.nix)
    ./fido2.nix
    ./firewall.nix
    ./gaming.nix
    ./nvidia.nix
    ./theme-switcher-sudo.nix
    ./voxtype.nix
  ];
}
