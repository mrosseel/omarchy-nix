{
  lib,
  fetchurl,
  fetchFromGitHub,
  runCommand,
  linuxManualConfig,
  # linuxPackagesFor re-invokes this through `override` when it builds the
  # package set, so the arguments it passes have to be accepted here.
  features ? {},
  ...
}: let
  # Upstream's own kernel: mainline plus 94 patches and Arch's config, made the
  # default in quattro `ff85faf8` (every machine bar T2 Macs). Arch builds it as
  # `linux-omarchy` from omarchy-pkgs.
  #
  # There is no binary cache for this. Selecting it means compiling a kernel
  # with -O3 and CONFIG_RUST on every machine, and again on every upstream
  # pkgrel bump. Upstream shipped six of those in the package's first four days.
  # `omarchy.kernel = "zen"` gets most of the scheduler and mm work from the
  # NixOS cache instead.
  version = "7.2.5";

  # Pins the patch series and the config together, so a bump is a rev, a hash
  # and whatever `patches` gained or lost.
  pkgsSrc = fetchFromGitHub {
    owner = "omacom";
    repo = "omarchy-pkgs";
    rev = "b850ae31320706723a7794b44dbf44ed7a6f5c63";
    hash = "sha256-xg8Mn/ddCyYy+nA/YeGw5TSZPw6OMq3unHOGnosp65w=";
  };

  pkgDir = "${pkgsSrc}/pkgbuilds/linux-omarchy";

  # The PKGBUILD applies the series in filename order. Listed rather than
  # globbed, because globbing the fetched tree would need import-from-derivation
  # and because the list is the record of what we carry.
  patches = [
    "0010-archlinux-base.patch"
    "0011-kbuild-optimize-for-performance-o3.patch"
    "0120-tlbpull.patch"
    "0121-smp-preempt.patch"
    "0130-sched-detach-tasks.patch"
    "0131-sched-avg-idle.patch"
    "0140-sched-always-inline.patch"
    "0141-sched-urgent-fixes.patch"
    "0142-sched-itmt-no-debugfs-dependency.patch"
    "0143-sched-hybrid-cluster-balancing.patch"
    "0144-sched-nohz-idle-core.patch"
    "0145-sched-eevdf-tunables.patch"
    "0200-idle.patch"
    "0210-pstate.patch"
    "0211-amd-pstate-fixes.patch"
    "0212-amd-pstate-epp-cache.patch"
    "0220-x86-amd-zen5-tlb-sizes.patch"
    "0250-zsmalloc.patch"
    "0260-mglru-exec-protect.patch"
    "0270-ksm-rmap-walk.patch"
    "0280-mm-updates.patch"
    "0290-zstd-bmi2-fallback-aliases.patch"
    "0291-zstd-bmi2-cpu-feature-dispatch.patch"
    "0292-crypto-zstd-defer-cstream-init.patch"
    "0293-crypto-zstd-defer-dstream-init.patch"
    "0295-af-alg-restrict.patch"
    "0296-x86-mm-pmd-modify-keep-dirty-bit.patch"
    "0300-btrfs.patch"
    "0301-btrfs-fixes.patch"
    "0302-btrfs-zstd-decompress-direct-to-page.patch"
    "0310-fuse-eof-zeroing.patch"
    "0311-fuse-perf.patch"
    "0312-fuse-writethrough-uptodate.patch"
    "0313-fuse-background-wakeup.patch"
    "0350-drm-edid-populate-monitor-range-from-displayid-adaptive-sync.patch"
    "0360-gpu-mem-cgroup.patch"
    "0361-drm-ttm-swapped-out-resource-leaves-bulk-move.patch"
    "0400-drm-i915-alpm-limit-pr-alpm-to-panel-replay.patch"
    "0401-drm-i915-psr-exit-panel-replay-for-alpm-lag.patch"
    "0402-psr2-early-transport-panels.patch"
    "0411-drm-xe-display-no-stolen-framebuffers.patch"
    "0420-safe-window.patch"
    "0430-fbc.patch"
    "0440-xe3-peak-bandwidth.patch"
    "0450-amd-hdmi-vrr-allm.patch"
    "0451-amd-vtem-tmds-links.patch"
    "0452-amd-hdmi-frl-default.patch"
    "0460-vesa-displayid-dsc-bpp.patch"
    "0461-vesa-dsc-passthru-mode-match-fix.patch"
    "0472-amdgpu-userq-post-reset-error.patch"
    "0473-i915-ptl-cdclk-sanitize.patch"
    "0474-amd-display-oled-vesa-backlight.patch"
    "0475-revert-drm-i915-dp-as-sdp-vrr-or-pr.patch"
    "0510-sound-updates.patch"
    "0511-sound-updates-fixes.patch"
    "0512-sound-fixes.patch"
    "0513-xps13-sof-quirk.patch"
    "0514-rt766-stream-config-type.patch"
    "0516-hda-realtek-rog-strix-g733zw-speakers.patch"
    "0517-asoc-amd-yc-acer-aspire-a314-23p.patch"
    "0540-media-ipu-bridge-ivsc-no-cvs-lookup.patch"
    "0541-cvs-nova-lake-acpi-id.patch"
    "0542-media-cvs-wake-irq-without-claiming-gpio.patch"
    "0560-input.patch"
    "0565-i2c-asue140d-touchpad-100khz.patch"
    "0566-hid-asus-no-keyboard-init-reports-to-touchpads.patch"
    "0600-usb4stream-fixes.patch"
    "0601-usb4stream-busy-poll.patch"
    "0610-typec-cable-altmode-check.patch"
    "0620-usb-string-sanitize.patch"
    "0650-wireguard-tstamp-type.patch"
    "0660-btusb-mediatek-mt7922-13d3-3625.patch"
    "0661-rtw89-command-offload-source.patch"
    "0662-iwlwifi-mld-skip-tx-when-firmware-dead.patch"
    "0700-pci-target-speed-quirk.patch"
    "0750-applesmc-cache-race.patch"
    "0751-applesmc-key-backlight-workqueue-leak.patch"
    "0770-acpi-pm-acer-swift3-sf314-56g-power-resource.patch"
    "0800-platform-updates.patch"
    "0801-amd-pmf-util-unbind-use-after-free.patch"
    "0850-futex-wait-multiple.patch"
    "0851-futex-wait-multiple-fixes.patch"
    "0852-futex-wait-multiple-abi-fixes.patch"
    "8201-xe-shrinker-return-freed-page-count.patch"
    "8202-xe-shrinker-runtime-pm-for-non-system-memory.patch"
    "8203-xe-shrinker-release-through-the-put-helper.patch"
    "8204-mm-opportunistic-compaction.patch"
    "8205-mm-hint-uses-allocation-order.patch"
    "8206-mm-carry-order-and-hint-in-one-word.patch"
    "8207-mm-classify-huge-page-allocations-as-failable.patch"
    "8208-mm-thp-deferred-split-uses-hint.patch"
    "8209-xe-shrinker-use-opportunistic-hint.patch"
    "8210-xe-shrinker-single-backup-decision.patch"
    "9999-bpftool-strip-wformat-bootstrap.patch"
  ];

  kernelPatches =
    map (name: {
      inherit name;
      patch = "${pkgDir}/${name}";
    })
    patches;

  # Arch's config, minus three settings that fight a Nix build:
  #   LOCALVERSION_AUTO  derives the release string from the source tree, so
  #                      modDirVersion could not be stated up front.
  #   MODULE_SIG_ALL     signs modules with a key generated inside the build.
  #                      Out-of-tree modules build in their own derivations,
  #                      where that key is gone. MODULE_SIG_FORCE is off, so
  #                      unsigned modules still load and only the taint flag
  #                      changes.
  #   LOCALVERSION       named so the module directory and the boot entry say
  #                      which kernel this is.
  configfile =
    runCommand "linux-omarchy-config" {
      src = "${pkgDir}/config.x86_64";
    } ''
      sed -e 's/^CONFIG_LOCALVERSION_AUTO=y/# CONFIG_LOCALVERSION_AUTO is not set/' \
          -e 's/^CONFIG_MODULE_SIG_ALL=y/# CONFIG_MODULE_SIG_ALL is not set/' \
          -e 's/^CONFIG_LOCALVERSION=""/CONFIG_LOCALVERSION="-omarchy"/' \
          $src > $out
    '';
in
  linuxManualConfig {
    inherit version configfile kernelPatches features;

    modDirVersion = "${version}-omarchy";

    src = fetchurl {
      url = "https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-${version}.tar.xz";
      hash = "sha256-Vd3w34Ml2drZb8/3vZOXfSLj9QrwZSdXKvWbd8djK3g=";
    };

    # Reads the config at eval time so the NixOS module system can answer
    # system.requiredKernelConfig.
    allowImportFromDerivation = true;

    extraMeta = {
      description = "Omarchy Linux kernel";
      homepage = "https://github.com/omacom/omarchy-pkgs";
      platforms = ["x86_64-linux"];
    };
  }
