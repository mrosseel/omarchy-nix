{
  config,
  pkgs,
  lib,
  ...
}: let
  hw = config.omarchy.hardware;

  # The v4l2-relayd command line the Cam Link drop-in runs. Kept out of the
  # unit text so the shell's own ${...} expansions are not Nix interpolations.
  camlinkRelay = pkgs.writeShellScript "omarchy-camlink-relay" ''
    DEVICE=$(${pkgs.gnugrep}/bin/grep -l -m1 -E "^$CARD_LABEL$" /sys/devices/virtual/video4linux/*/name | ${pkgs.coreutils}/bin/cut -d/ -f6)
    exec ${pkgs.v4l2-relayd}/bin/v4l2-relayd -i "$VIDEOSRC" ''${SPLASHSRC:+-s "$SPLASHSRC"} \
      -o "appsrc name=appsrc caps=video/x-raw,format=$FORMAT,width=$WIDTH,height=$HEIGHT,framerate=$FRAMERATE ! videoconvert ! v4l2sink name=v4l2sink sync=false device=/dev/$DEVICE" \
      $EXTRA_OPTS
  '';
in {
  config = lib.mkMerge [
    # Apple Macs with Broadcom Wi-Fi
    # Mirrors install/hardware/apple/fix-brcmfmac-supplicant.sh. Upstream detects
    # the PCI IDs at install time; on Nix this is a per-machine opt-in.
    (lib.mkIf hw.apple_brcmfmac_supplicant.enable {
      boot.extraModprobeConfig = ''
        # Broadcom's firmware supplicant and authenticator fail the WPA four-way
        # handshake on Apple hardware, which surfaces as a rejected password.
        # Disable both so wpa_supplicant performs the handshake instead.
        options brcmfmac feature_disable=0x82000
      '';
    })

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
      boot.kernelParams = ["fred=on"];
    })

    # ASUS Zenbook UX5406AA (Panther Lake / Xe3) display backlight
    # Mirrors install/config/hardware/asus/fix-asus-ptl-display-backlight.sh.
    # Without xe.enable_dpcd_backlight=1 the panel reads as PWM-only from VBT
    # but actually wants DPCD AUX, so brightness is effectively binary.
    (lib.mkIf hw.asus_zenbook_ux5406aa.enable {
      boot.kernelParams = ["xe.enable_dpcd_backlight=1"];
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
      hardware.firmware = [pkgs.sof-firmware];
    })

    # Elgato Cam Link 4K as a fixed 16:9 virtual camera
    # Mirrors install/hardware/fix-elgato-camlink-4k.sh plus the udev rule,
    # v4l2-relayd drop-in and loopback unit it installs. Browsers ask the raw
    # node for 640x480, which it fills by cropping, and the 4:3 frame is then
    # stretched into a 16:9 tile. Hide the raw node and relay it at 1280x720
    # under the same name.
    (lib.mkIf hw.elgato_camlink_4k.enable {
      boot.extraModulePackages = [config.boot.kernelPackages.v4l2loopback];

      # The module's own default device would otherwise show up in browsers as
      # "Dummy video device" on machines without another relay.
      boot.extraModprobeConfig = ''
        options v4l2loopback exclusive_caps=1
      '';

      environment.systemPackages = [pkgs.v4l2-relayd pkgs.v4l-utils];

      # The v4l2-relayd@.service template ships with the package.
      systemd.packages = [pkgs.v4l2-relayd];

      environment.etc."v4l2-relayd.d/camlink.conf".text = ''
        # Elgato Cam Link 4K relayed as a fixed 16:9 virtual camera. Browser
        # meeting apps send 720p at most; raise WIDTH/HEIGHT (up to 3840x2160)
        # for apps that can use more.
        VIDEOSRC="v4l2src device=/dev/camlink4k"
        FORMAT=NV12
        WIDTH=1280
        HEIGHT=720
        FRAMERATE=30/1
        CARD_LABEL="Cam Link 4K"
      '';

      # Keep the raw capture node away from users and hand it to the
      # v4l2-relayd instance. Sorted after 70-uaccess adds the tag and before
      # 73-seat-late applies its ACL.
      services.udev.extraRules = ''
        SUBSYSTEM=="video4linux", ENV{ID_VENDOR_ID}=="0fd9", ENV{ID_MODEL}=="Cam_Link_4K", ENV{ID_V4L_CAPABILITIES}==":capture:", \
          TAG-="uaccess", OWNER="root", GROUP="root", MODE="0600", SYMLINK+="camlink4k", \
          TAG+="systemd", ENV{SYSTEMD_ALIAS}="/dev/camlink4k", ENV{SYSTEMD_WANTS}="v4l2-relayd@camlink.service"
      '';

      systemd.services.camlink-4k-loopback = {
        description = "Create the Cam Link 4K virtual camera";
        after = ["systemd-modules-load.service"];
        path = [pkgs.kmod pkgs.v4l-utils pkgs.gnugrep];
        serviceConfig.Type = "oneshot";
        # Reruns on every relay start, so a deleted or unloaded device comes back.
        script = ''
          modprobe v4l2loopback
          grep -qsx "Cam Link 4K" /sys/devices/virtual/video4linux/*/name ||
            v4l2loopback-ctl add -n "Cam Link 4K" -x 1
        '';
      };

      # A drop-in on the packaged template instance, written as an /etc file
      # because systemd.services cannot name a template instance.
      environment.etc."systemd/system/v4l2-relayd@camlink.service.d/camlink.conf".text = ''
        [Unit]
        # udev starts this when the Cam Link 4K appears. Only the device's stop
        # is tied in: a start dependency on it would leave a job waiting
        # whenever the base v4l2-relayd.service is started with no Cam Link
        # attached.
        ConditionPathExists=/dev/camlink4k
        StopPropagatedFrom=dev-camlink4k.device
        Requires=camlink-4k-loopback.service
        After=camlink-4k-loopback.service

        [Service]
        RestartSec=2
        # The packaged command line, plus sync=false on the sink. v4l2src stamps
        # each frame with its capture time, so by the time it reaches the sink it
        # is already past due and a synced sink drops every one of them.
        ExecStart=
        ExecStart=${camlinkRelay}
      '';
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
