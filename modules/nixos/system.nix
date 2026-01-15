inputs: {
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
  packages = import ../packages.nix {inherit pkgs config lib;};

  # Override elephant packages to disable PIE hardening for Go plugin compatibility
  # See: https://github.com/NixOS/nixpkgs/issues/211951
  elephantWithoutPie = inputs.elephant.packages.${pkgs.system}.elephant.overrideAttrs (old: {
    hardeningDisable = (old.hardeningDisable or []) ++ [ "pie" ];
  });

  providersWithoutPie = inputs.elephant.packages.${pkgs.system}.elephant-providers.overrideAttrs (old: {
    hardeningDisable = (old.hardeningDisable or []) ++ [ "pie" ];
  });

  elephantCombined = pkgs.stdenv.mkDerivation {
    pname = "elephant-with-providers";
    version = "2.17.2-patched";
    dontUnpack = true;

    buildInputs = [
      elephantWithoutPie
      providersWithoutPie
    ];

    nativeBuildInputs = with pkgs; [ makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin $out/lib/elephant
      cp ${elephantWithoutPie}/bin/elephant $out/bin/
      cp -r ${providersWithoutPie}/lib/elephant/providers $out/lib/elephant/
    '';

    postFixup = ''
      wrapProgram $out/bin/elephant \
        --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [
          bash  # Required for executing desktop entries (sh command)
          wl-clipboard
          libqalculate
          imagemagick
          bluez
        ])}
    '';
  };
in {
  # Create /bin/bash symlink for Omarchy script compatibility
  systemd.tmpfiles.rules = [
    "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
  ];

  security.rtkit.enable = true;

  # PAM configuration for hyprlock (required for authentication)
  security.pam.services.hyprlock = {};

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
    initrd.verbose = lib.mkIf cfg.seamless_boot.silent_boot false;
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

  # UWSM integration for Hyprland
  programs.uwsm.enable = lib.mkIf cfg.seamless_boot.enable true;

  # Login configuration
  services.greetd = let
    # Use seamless_boot.username if set, otherwise fall back to main username
    loginUser = if cfg.seamless_boot.username != null
                then cfg.seamless_boot.username
                else cfg.username;
  in {
    enable = true;
    settings = lib.mkMerge [
      # Seamless auto-login when enabled
      (lib.mkIf cfg.seamless_boot.enable {
        initial_session = {
          command = "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop";
          user = loginUser;
        };
        default_session = {
          command = "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop";
          user = loginUser;
        };
      })
      # Traditional tuigreet when disabled
      (lib.mkIf (!cfg.seamless_boot.enable) {
        default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
      })
    ];
  };

  # Binary cache for Walker (speeds up builds)
  nix.settings = {
    extra-substituters = ["https://walker.cachix.org" "https://walker-git.cachix.org"];
    extra-trusted-public-keys = [
      "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
      "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
    ];
  };

  # Install packages
  environment.systemPackages = packages.systemPackages ++ [
    inputs.walker.packages.${pkgs.system}.default
    elephantCombined
  ];
  programs.direnv.enable = true;

  # Set ELEPHANT_PROVIDER_DIR globally so walker can find providers when running elephant listproviders
  environment.sessionVariables = {
    ELEPHANT_PROVIDER_DIR = "${elephantCombined}/lib/elephant/providers";
  };

  # Elephant systemd service
  systemd.user.services.elephant = {
    description = "Elephant launcher backend";
    wantedBy = ["graphical-session.target"];
    after = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${elephantCombined}/bin/elephant";
      Restart = "on-failure";
      RestartSec = 3;
      # Import environment so launched apps have display variables
      ImportEnvironment = true;
    };
    environment = {
      ELEPHANT_PROVIDER_DIR = "${elephantCombined}/lib/elephant/providers";
    };
  };

  # Networking
  services.resolved.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
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
