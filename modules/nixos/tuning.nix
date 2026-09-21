{
  config,
  lib,
  ...
}: {
  # Memory / swap tuning ported from quattro's etc/ drop-ins:
  #   default/systemd/zram-generator.conf.d/90-omarchy.conf
  #   etc/tmpfiles.d/omarchy-zswap.conf
  #   etc/sysctl.d/99-omarchy-sysctl.conf
  #   etc/systemd/logind.conf.d/20-inhibit-delay.conf
  #   etc/NetworkManager/conf.d/omarchy-wifi-powersave.conf

  # Compressed swap in RAM. zstd averages around 3:1, so even a full device
  # occupies roughly a third of RAM. Priority sits above the disk swapfile.
  zramSwap = {
    enable = lib.mkDefault true;
    algorithm = lib.mkDefault "zstd";
    memoryPercent = lib.mkDefault 100;
    priority = lib.mkDefault 100;
  };

  # zswap in front of swap-on-zram just double-compresses pages and breaks
  # zramctl accounting. Boot-only, so flipping it on by hand for an experiment
  # sticks until reboot.
  boot.kernelParams = ["zswap.enabled=0"];

  boot.kernel.sysctl = {
    # Solve common flakiness with SSH (MTU discovery on flaky links).
    "net.ipv4.tcp_mtu_probing" = lib.mkDefault 1;

    # BBR estimates bottleneck bandwidth and minimum RTT and paces to them,
    # where cubic keeps pushing until packets drop. That cuts queueing latency
    # (bufferbloat) on fast links. fq is the qdisc BBR is built to pace through.
    "net.core.default_qdisc" = lib.mkDefault "fq";
    "net.ipv4.tcp_congestion_control" = lib.mkDefault "bbr";

    # Tune reclaim for swap on zram, which is orders of magnitude faster than
    # the disk swapfile these defaults assume.
    "vm.swappiness" = lib.mkDefault 150;
    "vm.vfs_cache_pressure" = lib.mkDefault 50;
    "vm.page-cluster" = lib.mkDefault 0;
    "vm.watermark_boost_factor" = lib.mkDefault 0;
    "vm.watermark_scale_factor" = lib.mkDefault 125;
    "vm.dirty_background_bytes" = lib.mkDefault 67108864;
    "vm.dirty_bytes" = lib.mkDefault 268435456;
    "vm.dirty_writeback_centisecs" = lib.mkDefault 1500;
  };

  # omarchy-system-sleep-lock holds a delay inhibitor so the session locks
  # before suspend. Five seconds is not enough when closing the lid also
  # reconfigures displays, because Quickshell waits for the screen set to settle.
  # Written as the upstream drop-in rather than services.logind.settings, which
  # only exists on recent nixpkgs.
  environment.etc."systemd/logind.conf.d/20-inhibit-delay.conf".text = ''
    [Login]
    InhibitDelayMaxSec=15
  '';

  # An OOM daemon between "memory is tight" and "processes die at random".
  # systemd-oomd keys on PSI stall time, so it acts while the machine is still
  # thrashing instead of after an allocation already failed. 50% means half of a
  # ten-second window spent stalled on reclaim; held 20s the desktop is already
  # unusable and losing one app is the cheaper outcome.
  # (quattro etc/systemd/oomd.conf.d/10-omarchy.conf)
  systemd.oomd = {
    enable = lib.mkDefault true;
    settings.OOM = {
      DefaultMemoryPressureDurationSec = "20s";
      DefaultMemoryPressureLimit = "50%";
    };
    # Which cgroups are eligible is set on app.slice in the user manager (below),
    # so the compositor — which runs in session.slice — is structurally
    # ineligible: oomd takes the browser or terminal that caused the pressure and
    # the session survives to show the notification. NixOS' own enableUserSlices
    # would put the whole user slice, compositor included, back in the pool.
    enableRootSlice = false;
    enableSystemSlice = false;
    enableUserSlices = false;
  };

  # quattro default/systemd/user/app.slice.d/10-oomd.conf. Swap kill is the
  # backstop for the slower shape of the same problem, where swap fills before
  # pressure spikes; it uses the global SwapUsedLimit.
  systemd.user.slices."app" = {
    overrideStrategy = "asDropin";
    sliceConfig = {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMSwap = "kill";
    };
  };

  # Kyber keeps reads in their own queue and throttles the depth it submits to
  # hold a 2ms read latency target, so interactive reads keep flowing while a
  # large build, copy, or package upgrade floods the disk with writes. The
  # kernel's own pick (none or mq-deadline, depending on the device) does not
  # regulate latency once the queue fills. Whole disks only: partitions have no
  # scheduler of their own, and zram is memory with nothing to schedule.
  # (quattro etc/udev/rules.d/60-omarchy-io-scheduler.rules)
  boot.kernelModules = ["kyber-iosched"];
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", KERNEL=="nvme*|sd*|mmcblk*|vd*", ATTR{queue/scheduler}="kyber"
  '';

  # Keep Wi-Fi power save off: it trades 20-300ms latency spikes on idle links
  # for a fraction of a watt, and broken firmware (Intel BE200/BE211) drops the
  # link outright when it naps.
  networking.networkmanager.settings.connection = {
    "wifi.powersave" = 2;
  };
}
