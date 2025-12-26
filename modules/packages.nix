{pkgs, config, lib}: let
  plymouth-theme-omarchy = pkgs.callPackage ../packages/plymouth-theme-omarchy.nix {};
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

    # Terminal emulators
    ghostty
    alacritty
    kitty
    
    # App launcher and productivity
    walker
    
    # Screenshot and recording
    satty
    wf-recorder
    gpu-screen-recorder
    slurp
    
    # Audio management
    wiremix
    
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
    inxi

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
