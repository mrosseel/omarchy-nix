{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  config = lib.mkIf cfg.gaming.enable {
    # Enable Steam
    programs.steam = {
      enable = true;

      # Enable Remote Play for streaming games
      remotePlay.openFirewall = true;

      # Enable dedicated server for hosting game servers
      dedicatedServer.openFirewall = true;

      # Additional packages for Steam (controllers, fonts, etc.)
      extraCompatPackages = with pkgs; [
        proton-ge-bin  # GloriousEggroll's Proton builds for better compatibility
      ];
    };

    # Enable GameMode for performance optimizations
    programs.gamemode.enable = true;

    # Hardware acceleration and 32-bit support
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;  # Required for 32-bit games
    };

    # Additional gaming packages
    environment.systemPackages = with pkgs; [
      # Game launchers
      steam

      # Performance monitoring
      mangohud  # Overlay for FPS, temps, etc.

      # Controller support
      steam-run  # Run non-Steam games with Steam runtime

      # Xbox/PlayStation controller support
      xboxdrv
      linuxConsoleTools  # jstest, jscal for controller testing
    ];

    # Enable Xbox controller support
    hardware.xone.enable = lib.mkDefault true;  # Xbox One controller support
    hardware.xpadneo.enable = lib.mkDefault true;  # Xbox One Bluetooth controller support

    # Kernel modules for controller support
    boot.kernelModules = [ "uinput" ];

    # Allow users to access controllers
    services.udev.extraRules = ''
      # Xbox controllers
      SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", MODE="0660", TAG+="uaccess"
      # PlayStation controllers
      SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", MODE="0660", TAG+="uaccess"
      # Nintendo controllers
      SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", MODE="0660", TAG+="uaccess"
    '';
  };
}
