{
  config,
  pkgs,
  lib,
  ...
}: let
  hw = config.omarchy.hardware;
in {
  config = lib.mkMerge [
    # ASUS ExpertBook B9406 (Panther Lake / Xe3) display + touchpad fixes
    # Mirrors install/config/hardware/asus/fix-asus-ptl-b9406-{display,touchpad}.sh
    (lib.mkIf hw.asus_b9406.enable {
      boot.kernelParams = [
        "xe.enable_panel_replay=0"
        "xe.enable_dpcd_backlight=1"
      ];

      environment.etc."libinput/asus-expertbook-b9406.quirks".text = ''
        [ASUS ExpertBook B9406 Touchpad]
        MatchBus=i2c
        MatchUdevType=touchpad
        MatchVendor=0x093A
        MatchProduct=0x4F05
        MatchDMIModalias=dmi:*svnASUS*:pn*B9406*
        AttrEventCode=-ABS_MT_PRESSURE;-ABS_PRESSURE;
      '';
    })

    # ASUS ROG Flow Z13 (GZ302) detachable keyboard touchpad
    # Mirrors install/config/hardware/asus/fix-z13-touchpad.sh
    (lib.mkIf hw.asus_z13.enable {
      services.udev.extraRules = ''
        ACTION=="add|change", KERNEL=="event*", ATTRS{idVendor}=="0b05", ATTRS{idProduct}=="1a30", ENV{ID_INPUT_TOUCHPAD}=="1", ENV{ID_INPUT_TOUCHPAD_INTEGRATION}="internal"
      '';
    })

    # Intel Panther Lake FRED
    # Mirrors install/config/hardware/intel/fred.sh
    (lib.mkIf hw.intel_ptl_fred.enable {
      boot.kernelParams = [ "fred=on" ];
    })

    # ASUS Zenbook UX5406AA (Panther Lake / Xe3) display backlight
    # Mirrors install/config/hardware/asus/fix-asus-ptl-display-backlight.sh.
    # Without xe.enable_dpcd_backlight=1 the panel reads as PWM-only from VBT
    # but actually wants DPCD AUX, so brightness is effectively binary.
    (lib.mkIf hw.asus_zenbook_ux5406aa.enable {
      boot.kernelParams = [ "xe.enable_dpcd_backlight=1" ];
    })

    # Intel Panther Lake hardware video acceleration
    # Mirrors install/config/hardware/intel/video-acceleration.sh
    (lib.mkIf hw.intel_ptl_video_accel.enable {
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          vpl-gpu-rt
        ];
      };
    })

    # Sound Open Firmware for non-XPS Intel PTL audio DSP
    # Mirrors install/config/hardware/intel/sof-firmware.sh
    (lib.mkIf hw.intel_ptl_sof_firmware.enable {
      hardware.firmware = [ pkgs.sof-firmware ];
    })

    # Lenovo Yoga Pro 7 14IAH10 bass speaker pin quirk
    # Mirrors install/config/hardware/lenovo/fix-yoga-pro7-bass-speakers.sh
    (lib.mkIf hw.lenovo_yoga_pro7_bass.enable {
      boot.extraModprobeConfig = ''
        options snd-sof-intel-hda-generic hda_model=alc287-yoga9-bass-spk-pin
      '';
    })
  ];
}
