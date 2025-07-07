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
    "$terminal" = lib.mkDefault "ghostty";
    "$fileManager" = lib.mkDefault "nautilus --new-window";
    "$browser" = lib.mkDefault "chromium --new-window --ozone-platform=wayland";
    "$music" = lib.mkDefault "spotify";
    "$passwordManager" = lib.mkDefault "1password";
    "$messenger" = lib.mkDefault "signal-desktop";
    "$webapp" = lib.mkDefault "$browser --app";

    # Environment variables
    env = [
      "GDK_SCALE,2" # Change to 1 if on a 1x display

      # TODO: Flake config
      # Uncomment if running NVIDIA GPU:
      # "NVD_BACKEND,direct"
      # "LIBVA_DRIVER_NAME,nvidia"
      # "__GLX_VENDOR_LIBRARY_NAME,nvidia"
    ];

    monitor = cfg.monitors;
  };
}
