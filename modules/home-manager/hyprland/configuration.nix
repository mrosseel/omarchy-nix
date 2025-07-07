{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  imports = [
    ./autostart.nix
    ./bindings.nix
    ./envs.nix
    ./looknfeel.nix
    ./windows.nix
  ];
  wayland.windowManager.hyprland.settings = {
    # Default applications
    "$terminal" = lib.mkDefault "kitty";
    "$fileManager" = lib.mkDefault "nautilus --new-window";
    "$browser" = lib.mkDefault "brave --new-window --ozone-platform=wayland";
    "$music" = lib.mkDefault "spotify";
    "$passwordManager" = lib.mkDefault "keepassx";
    "$messenger" = lib.mkDefault "signal-desktop";
    "$webapp" = lib.mkDefault "$browser --app";

    

    monitor = cfg.monitors;
  };
}
