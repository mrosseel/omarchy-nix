inputs: {
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
  packages = import ../packages.nix {inherit pkgs config lib;};
in {
  # Create /bin/bash symlink for Omarchy script compatibility
  systemd.tmpfiles.rules = [
    "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
    # Upstream scripts and the shell run /usr/bin/python3 by path, so that a
    # mise or venv python never runs them. NixOS has no /usr/bin/python3. This
    # links the same interpreter that modules/packages.nix installs.
    "L+ /usr/bin/python3 - - - - ${pkgs.python3.withPackages (ps: [ps.pygobject3])}/bin/python3"
    # The idle service, omarchy-system-lock and omarchy-launch-screensaver find
    # the screensaver at this Arch path, and some match its process by it.
    "L+ /usr/lib/omarchy-screensaver - - - - ${pkgs.callPackage ../../packages/omarchy-screensaver.nix {}}/lib/omarchy-screensaver"
  ];

  security.rtkit.enable = true;

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Seamless boot and login experience
  boot = lib.mkIf cfg.seamless_boot.enable {
    # Plymouth boot splash
    plymouth = {
      enable = true;
      theme = cfg.seamless_boot.plymouth_theme;
      themePackages = packages.plymouthThemes;
    };

    # Silent boot configuration
    consoleLogLevel = lib.mkIf cfg.seamless_boot.silent_boot 3;
    kernelParams = lib.mkIf cfg.seamless_boot.silent_boot [
      "quiet"
      "splash"
      "loglevel=3"
      "systemd.show_status=auto"
      "udev.log_priority=3"
      "rd.udev.log_level=3"
      "boot.shell_on_fail"
    ];
  };

  # UWSM integration for Hyprland (always on; SDDM relies on hyprland-uwsm.desktop)
  programs.uwsm.enable = true;

  # Login configuration (matches upstream omarchy: SDDM Wayland greeter on Hyprland).
  # Autologin path mirrors /etc/sddm.conf.d/autologin.conf from upstream install/login/sddm.sh.
  services.displayManager = let
    # Upstream default/sddm/hyprland.lua (#6896) gives the greeter the system
    # keyboard layout, read from XKBLAYOUT and XKBVARIANT in /etc/vconsole.conf.
    # Nix deviation: NixOS keeps the layout in services.xserver.xkb, not in
    # vconsole.conf, so the same rules run here at build time.
    xkb = config.services.xserver.xkb;

    # Layouts that can't type Latin letters, and the us variants that can't
    # either (Russian phonetic and Cherokee). Keep in step with
    # default/hypr/input.lua.
    nonLatinLayouts = ["af" "am" "ara" "bd" "bg" "by" "et" "ge" "gr" "il" "in" "iq" "ir" "kg" "kh" "kz" "la" "lk" "mk" "mm" "mn" "mv" "np" "rs" "ru" "sy" "th" "tj" "ua"];
    nonLatinUsVariants = ["chr" "rus"];

    layouts = lib.splitString "," xkb.layout;
    variants = lib.splitString "," xkb.variant;
    variantAt = i:
      if i < builtins.length variants
      then builtins.elemAt variants i
      else "";
    removeAt = i: list: lib.sublist 0 i list ++ lib.drop (i + 1) list;

    # A greeter that can't type Latin letters can't take a password either, so
    # a non-Latin layout gets us in front, reachable back with Left Alt + Right
    # Alt. Variants pair with layouts by position. An existing us entry moves to
    # the front with its variant instead of adding a duplicate toggle stop.
    usIndex =
      lib.findFirst
      (i: builtins.elemAt layouts i == "us" && !(lib.elem (variantAt i) nonLatinUsVariants))
      null
      (lib.range 0 (builtins.length layouts - 1));
    greeterInput =
      if lib.elem (builtins.head layouts) nonLatinLayouts
      then {
        layout = lib.concatStringsSep "," (["us"]
          ++ (
            if usIndex == null
            then layouts
            else removeAt usIndex layouts
          ));
        variant = lib.concatStringsSep "," ([
            (
              if usIndex == null
              then ""
              else variantAt usIndex
            )
          ]
          ++ (
            if usIndex != null && usIndex < builtins.length variants
            then removeAt usIndex variants
            else variants
          ));
        options = "grp:alts_toggle";
      }
      else {
        inherit (xkb) layout variant;
        options = "";
      };

    sddmHyprlandConf =
      pkgs.writeText "sddm-hyprland.conf"
      (builtins.readFile ../../default/sddm/hyprland.conf
        + ''

          input {
            kb_layout = ${greeterInput.layout}
            kb_variant = ${greeterInput.variant}
            kb_options = ${greeterInput.options}
          }
        '');
    hyprlandPkg = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    loginUser =
      if cfg.seamless_boot.username != null
      then cfg.seamless_boot.username
      else cfg.username;
  in {
    sddm = {
      enable = true;
      wayland.enable = true;
      package = pkgs.kdePackages.sddm;
      theme = "omarchy";
      extraPackages = packages.sddmThemes;
      autoNumlock = false;
      settings = {
        Theme.CursorTheme = lib.mkDefault "";
        # Wayland greeter runs on a minimal Hyprland compositor
        Wayland.CompositorCommand = "${hyprlandPkg}/bin/Hyprland --config ${sddmHyprlandConf}";
        # Match upstream: Wayland-only, no X11 fallback (omarchy commit 4eb3a919)
        General.DisplayServer = "wayland";
      };
    };
    defaultSession = "hyprland-uwsm";
    autoLogin = lib.mkIf cfg.seamless_boot.enable {
      enable = true;
      user = loginUser;
    };
  };

  # Upstream installs /etc/pam.d/sddm and then strips the gnome-keyring auth/password
  # lines to avoid creating an encrypted login keyring that conflicts with
  # passwordless Default_keyring auto-unlock. NixOS exposes that knob directly.
  security.pam.services.sddm.enableGnomeKeyring = false;
  security.pam.services.sddm-autologin.enableGnomeKeyring = false;

  # Omarchy 4 shell lock screen authenticates against this PAM service
  # (shell/plugins/lock PamContext config:"omarchy-lock-password"). The default
  # NixOS PAM stack provides the unix password auth it needs; the fingerprint
  # counterpart (omarchy-lock-fingerprint) is added in fido2.nix when enabled.
  security.pam.services.omarchy-lock-password = {};

  # Install packages
  environment.systemPackages = packages.systemPackages;
  programs.direnv.enable = true;

  # nix-ld for running unpatched binaries (e.g., Python venvs with native deps)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [stdenv.cc.cc];

  environment.sessionVariables = {
    OMARCHY_PATH = "$HOME/.local/share/omarchy";
  };

  # Upstream ships bin/ in /usr/bin; here it's under $HOME and home.sessionPath
  # only reaches interactive shells. Add it in /etc/profile so `bash -l`
  # (omarchy-shell menu actions, SSH) finds omarchy-* too.
  environment.extraInit = ''
    case ":$PATH:" in
      *":$HOME/.local/share/omarchy/bin:"*) ;;
      *) export PATH="$HOME/.local/share/omarchy/bin:$PATH" ;;
    esac
  '';

  # Raise soft fd limit (omarchy install/config/increase-fd-limit.sh equivalent)
  systemd.settings.Manager.DefaultLimitNOFILESoft = 65536;

  # Network service discovery and file manager network browsing
  # (Arch provides these implicitly with most desktop setups)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    browseDomains = ["local"];
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
  services.gvfs.enable = true;

  # Printing support (CUPS stack - matches Omarchy's cups/cups-browsed/cups-filters/cups-pdf)
  services.printing = {
    enable = true;
    browsing = true;
  };

  # Power management profiles (performance/balanced/power-saver)
  services.power-profiles-daemon.enable = true;
  # The shell's battery service and power panel read Quickshell.Services.UPower,
  # and omarchy-battery-status runs the upower CLI.
  services.upower.enable = true;
  # Upstream #14737 replaces stock power-profiles-daemon with
  # omarchy-power-profiles-daemon, which adds the CPU drivers that ARM laptops
  # need. The NixOS module installs the D-Bus service and powerprofilesctl from
  # this package.
  services.power-profiles-daemon.package = lib.mkDefault (pkgs.callPackage ../../packages/omarchy-power-profiles-daemon.nix {});

  # Credential storage for apps (gnome-keyring); SDDM PAM lines configured above.
  services.gnome.gnome-keyring.enable = true;

  # Notice dropped SSH connections within a minute instead of hanging until TCP
  # gives up, so the shell's ssh wrapper can clean up and reconnect. ~/.ssh/config
  # is read first and wins, so per-host overrides still apply.
  # Mirrors install/config/ssh-keepalive.sh.
  programs.ssh.extraConfig = ''
    Host *
      ServerAliveInterval 15
      ServerAliveCountMax 3
      ConnectTimeout 10
  '';

  # Networking
  services.resolved.enable = true;
  hardware.bluetooth.enable = true;

  # NetworkManager owns Wi-Fi, on its default wpa_supplicant backend. Upstream
  # left iwd in b19dc7ea (May 2026) and retires the iwd + impala pair together in
  # omarchy-upgrade-to-quattro; we had switched to iwd for the impala TUI back
  # when Omarchy still used it. The shell's own network panel replaced that TUI,
  # and the quattro network scripts (omarchy-network-{password,qr,band}) read the
  # passphrase out of NetworkManager, which only holds it on this backend.
  networking = {
    networkmanager.enable = true;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.caskaydia-mono
    nerd-fonts.jetbrains-mono
  ];
}
