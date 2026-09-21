{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;

  linux-omarchy = pkgs.callPackage ../../packages/linux-omarchy.nix {
    linuxManualConfig = pkgs.linuxKernel.manualConfig;
  };
in {
  # quattro `ff85faf8` makes `linux-omarchy` the default kernel on every machine
  # bar T2 Macs, replacing the older per-machine `linux-ptl` swap. On Arch that
  # is a package install. Here it is a choice, because building it has a cost
  # Arch users never pay: there is no binary cache for it, so every switch that
  # touches the kernel compiles one. See the option in config.nix.
  config = lib.mkMerge [
    (lib.mkIf (cfg.kernel == "zen") {
      boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;
    })

    (lib.mkIf (cfg.kernel == "omarchy") {
      boot.kernelPackages = lib.mkDefault (pkgs.linuxPackagesFor linux-omarchy);

      # Upstream keeps T2 Macs on linux-t2, which carries the Apple bridge
      # drivers this kernel has no patches for. omarchy-nix cannot detect the
      # machine at build time, so say it here instead of booting the wrong one.
      warnings =
        lib.optional (cfg.hardware.apple_brcmfmac_supplicant.enable)
        ''
          omarchy.kernel = "omarchy" is set alongside the Apple Broadcom Wi-Fi
          workaround. Upstream keeps T2 Macs on linux-t2 instead. If this is a T2
          Mac, leave omarchy.kernel at "default".
        '';
    })
  ];
}
