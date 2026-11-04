{
  config,
  lib,
  pkgs,
  ...
}: let
  # Upstream ships these system files in its omarchy-settings package, from
  # etc/ and default/systemd/. Each block below names the upstream file.
  # systemd-sleep runs hooks without a login PATH. Nix deviation: each hook sets
  # PATH to the store paths of the tools it calls. The rest is upstream's code.
  sleepHook = name: tools: body:
    pkgs.writeShellScript name ''
      PATH=${lib.makeBinPath tools}:$PATH

      ${body}
    '';

  # default/systemd/system-sleep/unmount-fuse
  unmountFuse = sleepHook "unmount-fuse" [pkgs.coreutils pkgs.fuse3 pkgs.fuse config.systemd.package] ''
    # Lazy-unmount gvfsd-fuse filesystems before suspend/hibernate to prevent the
    # kernel's process freeze from timing out. FUSE daemons (like gvfsd-fuse from
    # Nautilus) can block in uninterruptible sleep during freeze, causing suspend
    # to silently fail. After wake, restart gvfs so the FUSE mount is restored.

    if [[ $1 == "pre" ]]; then
      while IFS=' ' read -r _ mountpoint fstype _; do
        if [[ $fstype == fuse.gvfsd-fuse ]]; then
          mountpoint=$(printf '%b' "$mountpoint")
          fusermount3 -uz "$mountpoint" 2>/dev/null || fusermount -uz "$mountpoint" 2>/dev/null || true
        fi
      done < /proc/mounts
    fi

    if [[ $1 == "post" ]]; then
      # Hand the restart to a timer unit: systemd kills anything this hook leaves behind when the
      # sleep service ends, and user.slice stays frozen until the hook returns.
      for uid_dir in /run/user/*; do
        uid=$(basename "$uid_dir")
        if [[ -S $uid_dir/bus ]]; then
          systemd-run --quiet --no-block --collect --on-active=5 --timer-property=AccuracySec=1s --uid="$uid" \
            --setenv=DBUS_SESSION_BUS_ADDRESS="unix:path=$uid_dir/bus" \
            --setenv=XDG_RUNTIME_DIR="$uid_dir" \
            systemctl --user restart gvfs-daemon.service 2>/dev/null || true
        fi
      done
    fi
  '';

  # default/systemd/system-sleep/fprintd-resume
  fprintdResume = sleepHook "fprintd-resume" [config.systemd.package] ''
    # Suspend can wedge fprintd's claim; restart it after resume to clear it.
    # Upstream: https://gitlab.freedesktop.org/libfprint/fprintd/-/issues/173

    if [[ $1 == "post" ]]; then
      # user.slice stays frozen until this hook returns; enqueue rather than wait.
      systemctl --no-block try-restart fprintd.service 2>/dev/null || true
    fi
  '';

  # The 50 languages that Setup > Language offers.
  languages = builtins.fromJSON (builtins.readFile ../../default/i18n/locales.json);

  # glibc's localedata/SUPPORTED spells these without the codeset (hi_IN/UTF-8),
  # and NixOS accepts only the spelling SUPPORTED uses. localedef still adds the
  # locale as hi_IN.utf8 too. Upstream's helper handles the same case in
  # locale.gen. A new registry language that SUPPORTED spells this way fails the
  # glibc-locales build, which names it.
  noCodesetLocales = ["bn_BD" "fa_IR" "fil_PH" "hi_IN" "si_LK" "sr_RS" "sw_TZ" "ta_LK" "ur_PK" "vi_VN"];
  supportedName = locale: let
    base = lib.removeSuffix ".UTF-8" locale;
  in
    if lib.elem base noCodesetLocales
    then "${base}/UTF-8"
    else "${locale}/UTF-8";
in {
  config = lib.mkMerge [
    {
      # etc/NetworkManager/conf.d/omarchy-connectivity.conf
      # Check connectivity against Omarchy's own endpoint instead of the
      # distribution's. It must stay plain HTTP so a captive portal can
      # intercept it, and the network panel opens the same URL to reach the
      # portal's sign-in page. The endpoint answers 204, so no body is expected.
      networking.networkmanager.settings.connectivity = {
        uri = "http://ping.omacom.io/nm-check.txt";
        response = "";
      };

      # default/systemd/timesyncd.conf.d/10-omarchy.conf
      # Time servers for when nothing else names one. NTP= and servers that a
      # network hands out still come first. This replaces the NixOS pool, which
      # NixOS puts in FallbackNTP= through networking.timeServers. Set
      # services.timesyncd.servers to use other servers.
      services.timesyncd.fallbackServers = lib.mkDefault ["ntp.omarchy.org" "time.cloudflare.com"];

      # etc/pipewire/{client,jack}.conf.d/50-omarchy-rtkit.conf
      # Ask rtkit for realtime directly, as PipeWire's own pipewire.conf does,
      # rather than through xdg-desktop-portal. A portal started before rtkit
      # reports a realtime budget of zero, and module-rt applies that as a hard
      # RLIMIT_RTTIME of 0, which the kernel enforces with SIGKILL. NixOS option
      # in place of the upstream drop-in files.
      services.pipewire.extraConfig.client."50-omarchy-rtkit" = {
        "module.rt.args" = {"rtportal.enabled" = false;};
      };
      services.pipewire.extraConfig.jack."50-omarchy-rtkit" = {
        "module.rt.args" = {"rtportal.enabled" = false;};
      };

      # etc/mpv/mpv.conf
      # nixpkgs builds mpv with /etc/mpv as its system config directory.
      environment.etc."mpv/mpv.conf".text = ''
        # Decode video on the GPU through mpv's list of reliable hardware decoders,
        # falling back to software when none applies. ~/.config/mpv/mpv.conf overrides this.
        hwdec=auto-safe
      '';

      # etc/systemd/system.conf.d/20-mount-events.conf
      # The default five mount events per second can defer local filesystems and
      # binfmt registration during boot. Raise the allowance to thirty events per
      # second. NixOS option in place of the upstream drop-in.
      systemd.managerEnvironment.SYSTEMD_DEFAULT_MOUNT_RATE_LIMIT_BURST = "30";

      # Upstream generates a language's locale on first use, through
      # bin/omarchy-locale-generate and a passwordless rule in
      # etc/sudoers.d/omarchy-locale-generate. Nix deviation: NixOS builds the
      # locale archive at build time, so build every locale in the registry
      # (default/i18n/locales.json). omarchy-language then finds the locale
      # present and never asks for root.
      i18n.extraLocales = lib.unique (lib.mapAttrsToList (_: language: supportedName language.locale) languages);
    }

    # etc/systemd/system/systemd-binfmt.service.d/10-eager-mount.conf and
    # etc/systemd/system/proc-sys-fs-binfmt_misc.mount.d/10-omarchy-conditions.conf.
    # NixOS adds these units only when binfmt registrations exist.
    (lib.mkIf (config.boot.binfmt.registrations != {}) {
      # The upstream service orders itself after this mount but does not pull it
      # in. Mount it before registration instead of waiting on the automount.
      systemd.services.systemd-binfmt.wants = ["proc-sys-fs-binfmt_misc.mount"];

      # Keep the automount's guards when registration pulls the mount in directly.
      systemd.units."proc-sys-fs-binfmt_misc.mount" = {
        overrideStrategy = "asDropin";
        text = ''
          [Unit]
          ConditionPathExists=/proc/sys/fs/binfmt_misc/
          ConditionPathIsReadWrite=/proc/sys/
        '';
      };
    })

    # default/systemd/system-sleep/unmount-fuse. Nautilus mounts through
    # gvfsd-fuse, which services.gvfs provides.
    (lib.mkIf config.services.gvfs.enable {
      environment.etc."systemd/system-sleep/unmount-fuse".source = unmountFuse;
    })

    # default/systemd/system-sleep/fprintd-resume and
    # default/systemd/system/fprintd.service.d/10-stop-timeout.conf
    (lib.mkIf config.services.fprintd.enable {
      environment.etc."systemd/system-sleep/fprintd-resume".source = fprintdResume;

      # A stale device handle can make fprintd ignore SIGTERM after resume.
      # mkDefault keeps an administrator's own value first, as the upstream
      # drop-in's numeric prefix does.
      systemd.services.fprintd.serviceConfig.TimeoutStopSec = lib.mkDefault "3s";
    })
  ];
}
