{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  config = lib.mkIf cfg.nvidia.enable {
    # Enable NVIDIA drivers
    services.xserver.videoDrivers = [ "nvidia" ];

    # NVIDIA driver configuration
    hardware.nvidia = {
      # Modesetting is required for Wayland
      modesetting.enable = true;

      # Enable power management (recommended for laptops)
      powerManagement.enable = true;

      # Use open source kernel module (if supported by your GPU)
      # Set to false for older GPUs that require proprietary module
      open = lib.mkDefault false;

      # Enable nvidia-settings menu
      nvidiaSettings = true;

      # Select the appropriate driver version
      # Use "beta" for latest features, "stable" for reliability
      # Use "legacy_470" or "legacy_390" for older GPUs
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # OpenGL configuration for NVIDIA
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;  # For 32-bit applications

      extraPackages = with pkgs; [
        nvidia-vaapi-driver  # VA-API support for video acceleration
      ];
    };

    # Environment variables for NVIDIA + Wayland + Hyprland
    environment.sessionVariables = {
      # Force NVIDIA to use Wayland
      WLR_NO_HARDWARE_CURSORS = "1";

      # Enable NVIDIA features for Wayland
      LIBVA_DRIVER_NAME = "nvidia";
      XDG_SESSION_TYPE = "wayland";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";

      # Hyprland-specific NVIDIA settings
      WLR_DRM_NO_ATOMIC = "1";
    };

    # Additional packages for NVIDIA
    environment.systemPackages = with pkgs; [
      nvtop  # NVIDIA GPU monitor (like htop for GPU)
    ];
  };
}
