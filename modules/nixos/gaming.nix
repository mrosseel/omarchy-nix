{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
  gaming = cfg.gaming;
  # Anything below requires the umbrella `gaming.enable` to be on. Per-component
  # switches default to `gaming.enable` for the core stack (steam,
  # xboxControllers, gpuLib32) and `false` for the opt-in extras
  # (heroic, lutris, moonlight, retroarch, xboxCloud, geforceNow).
  any = gaming.enable;
in {
  config = lib.mkMerge [
    # GameMode + mangohud + steam-run are useful whenever any gaming feature is
    # enabled (small, generally-applicable utilities).
    (lib.mkIf any {
      programs.gamemode.enable = true;
      environment.systemPackages = with pkgs; [
        mangohud
        steam-run
      ];
    })

    # Steam (default-on with umbrella)
    (lib.mkIf gaming.steam.enable {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        extraCompatPackages = with pkgs; [ proton-ge-bin ];
      };
      environment.systemPackages = [ pkgs.steam ];
    })

    # 32-bit GPU libraries (default-on with umbrella; required by most games)
    # Also wires up Vulkan video driver hint per upstream "Set vulkan video driver"
    (lib.mkIf gaming.gpuLib32.enable {
      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };
    })

    # Xbox controllers (default-on with umbrella)
    (lib.mkIf gaming.xboxControllers.enable {
      hardware.xone.enable = lib.mkDefault true;
      hardware.xpadneo.enable = lib.mkDefault true;
      boot.kernelModules = [ "uinput" ];
      environment.systemPackages = with pkgs; [
        xboxdrv
        linuxConsoleTools
      ];
      services.udev.extraRules = ''
        # Xbox controllers
        SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", MODE="0660", TAG+="uaccess"
        # PlayStation controllers
        SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", MODE="0660", TAG+="uaccess"
        # Nintendo controllers
        SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", MODE="0660", TAG+="uaccess"
      '';
    })

    # Heroic Games Launcher (Epic / GOG)
    (lib.mkIf gaming.heroic.enable {
      environment.systemPackages = [ pkgs.heroic ];
    })

    # Lutris (also covers Battle.net via runtime install scripts)
    (lib.mkIf gaming.lutris.enable {
      environment.systemPackages = with pkgs; [
        lutris
        wineWowPackages.stable
        winetricks
      ];
    })

    # Moonlight game streaming client
    (lib.mkIf gaming.moonlight.enable {
      environment.systemPackages = [ pkgs.moonlight-qt ];
    })

    # RetroArch with assets and a default cores selection
    (lib.mkIf gaming.retroarch.enable {
      environment.systemPackages = with pkgs; [
        (retroarch.override {
          cores = with libretro; [
            snes9x
            mgba
            mupen64plus
            beetle-psx
            genesis-plus-gx
          ];
        })
        retroarch-assets
      ];
    })

    # Xbox Cloud Gaming (PWA — installed via webapp pipeline, no native package)
    (lib.mkIf gaming.xboxCloud.enable {
      # Provided through default/applications and omarchy-launch-webapp at runtime.
      # Marker so a future home-manager activation can drop the .desktop entry.
    })

    # GeForce NOW (PWA — same model as Xbox Cloud)
    (lib.mkIf gaming.geforceNow.enable {
      # Provided through default/applications and omarchy-launch-webapp at runtime.
    })
  ];
}
