{pkgs, config, lib}: let
  plymouth-theme-omarchy = pkgs.callPackage ../packages/plymouth-theme-omarchy.nix {};
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
    blueberry
    clipse
    xdg-utils
    xdg-terminal-exec

    # Terminal emulators
    ghostty
    alacritty
    kitty

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
    gnome-calculator
    evince
    loupe
    krita
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

    # Don't want these right now
    # obs-studio
    # kdePackages.kdenLive
    # pinta
    # libreoffice
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
    # podman-compose
  ];

  homePackages = with pkgs; [
  ];

  # Plymouth theme
  plymouthThemes = [
    plymouth-theme-omarchy
  ];
}
