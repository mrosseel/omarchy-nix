{
  pkgs,
  config,
  lib,
}: let
  plymouth-theme-omarchy = pkgs.callPackage ../packages/plymouth-theme-omarchy.nix {};
  sddm-theme-omarchy = pkgs.callPackage ../packages/sddm-theme-omarchy.nix {};
  hyprland-preview-share-picker = pkgs.callPackage ../packages/hyprland-preview-share-picker.nix {};
  voxtype = pkgs.callPackage ../packages/voxtype.nix {};
  ttfx = pkgs.callPackage ../packages/ttfx.nix {};
  omacalc = pkgs.callPackage ../packages/omacalc.nix {};
  omasnap = pkgs.callPackage ../packages/omasnap.nix {
    layer-shell-qt = pkgs.kdePackages.layer-shell-qt;
  };
  owe = pkgs.callPackage ../packages/owe.nix {};
  elsewhen = pkgs.callPackage ../packages/elsewhen.nix {};
  cfg = config.omarchy;
in {
  # Regular packages
  systemPackages = with pkgs;
    [
      # Base system tools
      git
      vim
      # quattro added the original `vi` to the base packages. On Arch the `vi`
      # package owns /usr/bin/{vi,ex,view} and vim owns none of them, so nvi
      # takes priority here to land the same three commands.
      (lib.hiPrio nvi)
      libnotify
      pavucontrol
      brightnessctl
      ffmpeg
      nautilus
      hyprshot
      hyprpicker
      hyprsunset
      alejandra
      pamixer
      playerctl
      bibata-cursors
      gnome-themes-extra
      blueman
      xdg-utils
      xdg-terminal-exec

      # Terminal emulators
      ghostty
      alacritty
      kitty
      foot

      # Screenshot and recording
      omasnap # Custom package; replaced tensaku upstream (quattro)
      wf-recorder
      gpu-screen-recorder
      slurp
      hyprland-preview-share-picker # Custom package

      # Audio management
      wiremix

      # Omarchy 4 desktop shell deps (bar/launcher/menu/notifications/osd/lock/
      # polkit/background all live in omarchy-shell; quickshell itself is added by
      # modules/home-manager/omarchy-shell.nix).
      glib # gsettings, used by omarchy-theme-set-gnome for the GTK light/dark theme
      imagemagick # thumbnails for omarchy-menu-images (theme/background pickers), transcode, bar-text-color
      udiskie # automount removable drives (upstream autostart)
      fcitx5 # input method (upstream autostart: fcitx5 --disable notificationitem)
      fcitx5-gtk
      libsForQt5.fcitx5-qt

      # Shell tools
      fzf
      zoxide
      ripgrep
      eza
      fd
      jq
      # The clipboard watcher's capture.sh decodes mixed UTF-16 clipboard text
      # with perl (Encode + JSON::PP, both core). Arch always has perl; here it
      # has to be asked for, or every clipboard entry is dropped.
      perl
      curl
      unzip
      wget
      gnumake
      # The python scripts in bin/ (omarchy-file-select, omarchy-agent-usage-*,
      # omarchy-dev-font) run `#!/usr/bin/env python3`. Arch's python-gobject is
      # a system package there; here the interpreter on PATH has to carry it.
      (python3.withPackages (ps: [ps.pygobject3]))
      ddcutil # omarchy-brightness-display-ddc, external monitor brightness
      vips # omarchy-menu-images thumbnails (upstream libvips)
      qrencode # omarchy-network-qr, the Wi-Fi share card
      zbar # omarchy-capture-qr decodes what the region picker grabs
      libqalculate # qalc, behind the menu's inline calculator
      # Terminal multiplexer alongside tmux (quattro ships both)
      herdr

      # TUIs
      lazygit
      lazydocker
      dua # Disk Usage TUI (upstream swapped dust -> dua-cli)
      btop
      powertop
      fastfetch
      gum
      bluetui
      inxi

      # Screensaver (quattro swapped python terminaltexteffects -> ttfx)
      ttfx

      # GUIs
      (
        if cfg.browser == "brave"
        then brave
        else chromium
      )
      obsidian
      vlc
      mpv
      omacalc # quattro replaced gnome-calculator with omacalc
      loupe
      krita
      pinta
      xournalpp
      localsend

      # Video production
      obs-studio
    ]
    ++ lib.optionals (pkgs ? kdenlive) [kdenlive]
    ++ lib.optionals (pkgs ? libsForQt5.kdenlive) [libsForQt5.kdenlive]
    ++ [
    ]
    ++ lib.optionals cfg.office_suite.enable [
      libreoffice-fresh
    ]
    ++ lib.optionals cfg.voxtype.enable [
      voxtype
      wtype
    ]
    ++ [
      # Can't find this in nixpkgs!
      # Might have to make it ourselves
      # asdcontrol

      signal-desktop

      # Commercial GUIs
      typora
      dropbox
      spotify
      # zoom

      # Development tools
      github-desktop
      gh

      # Containers
      docker-compose
      docker-buildx

      # Database client libraries (needed by dev tools to connect to MySQL/PostgreSQL)
      mariadb.client
      postgresql.lib

      # Nautilus enhancements
      ffmpegthumbnailer
      sushi

      # Credential storage
      gnome-keyring
      libsecret

      # Qt Wayland and theming
      kdePackages.qtwayland
      qt5.qtwayland
    ];

  homePackages = with pkgs; [
  ];

  # Plymouth theme
  plymouthThemes = [
    plymouth-theme-omarchy
  ];

  # SDDM theme
  sddmThemes = [
    sddm-theme-omarchy
  ];
}
