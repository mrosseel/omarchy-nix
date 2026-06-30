{pkgs, config, lib}: let
  plymouth-theme-omarchy = pkgs.callPackage ../packages/plymouth-theme-omarchy.nix {};
  sddm-theme-omarchy = pkgs.callPackage ../packages/sddm-theme-omarchy.nix {};
  hyprland-preview-share-picker = pkgs.callPackage ../packages/hyprland-preview-share-picker.nix {};
  voxtype = pkgs.callPackage ../packages/voxtype.nix {};
  terminaltexteffects = pkgs.callPackage ../packages/terminaltexteffects.nix {};
  cfg = config.omarchy;
in {
  # Regular packages
  systemPackages = with pkgs; [
    # Base system tools
    git
    vim
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
    clipse
    xdg-utils
    xdg-terminal-exec

    # Terminal emulators
    ghostty
    alacritty
    kitty
    foot

    # Screenshot and recording
    satty
    wf-recorder
    gpu-screen-recorder
    slurp
    hyprland-preview-share-picker  # Custom package
    
    # Audio management
    wiremix

    # OSD (On-Screen Display)
    swayosd

    # Background management
    swaybg

    # Shell tools
    fzf
    zoxide
    ripgrep
    eza
    fd
    jq
    curl
    unzip
    wget
    gnumake

    # TUIs
    lazygit
    lazydocker
    dua # Disk Usage TUI (upstream swapped dust -> dua-cli)
    btop
    powertop
    fastfetch
    gum
    bluetui
    impala
    inxi

    # Screensaver (custom package for v0.14.2 with --random-effect support)
    terminaltexteffects

    # GUIs
    (if cfg.browser == "brave" then brave else chromium)
    obsidian
    vlc
    mpv
    gnome-calculator
    loupe
    krita
    pinta
    xournalpp
    localsend

    # Video production
    obs-studio
  ]
  ++ lib.optionals (pkgs ? kdenlive) [ kdenlive ]
  ++ lib.optionals (pkgs ? libsForQt5.kdenlive) [ libsForQt5.kdenlive ]
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
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
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
