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
  omarchy-screensaver = pkgs.callPackage ../packages/omarchy-screensaver.nix {};
  omarchy-local-ai = pkgs.callPackage ../packages/omarchy-local-ai.nix {};
  hype = pkgs.callPackage ../packages/hype.nix {};
  gliff = pkgs.callPackage ../packages/gliff.nix {};
  signed = pkgs.callPackage ../packages/signed.nix {};
  disktree = pkgs.callPackage ../packages/disktree.nix {};
  monologue = pkgs.callPackage ../packages/monologue.nix {};
  superwhisper = pkgs.callPackage ../packages/superwhisper.nix {};
  # fcitx5 with the addons upstream installs for Japanese, Korean and Chinese
  # (install/omarchy-base.packages). omarchy-fcitx5.service runs this build.
  fcitx5 = pkgs.qt6Packages.fcitx5-with-addons.override {
    addons = with pkgs;
      [
        fcitx5-gtk
        qt6Packages.fcitx5-qt
        fcitx5-chewing
        qt6Packages.fcitx5-chinese-addons
        fcitx5-hangul
        fcitx5-mozc
        fcitx5-table-extra
      ]
      # Superwhisper types the dictated text through its own fcitx5 addon.
      ++ lib.optionals cfg.superwhisper.enable [superwhisper];
  };
  cfg = config.omarchy;
in {
  inherit fcitx5;

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
      # Upstream base packages that the shell and bin/ scripts call.
      wl-clipboard # clipboard plugin (wl-paste --watch), notifications
      socat # omarchy-shell IPC, omarchy-hyprland-monitor-watch
      grim # omarchy-capture-qr, omarchy-capture-text
      (tesseract.override {enableLanguages = ["eng"];}) # omarchy-capture-text
      cliamp # Music TUI binding
      pulseaudio # pactl only, for the omarchy-audio-* scripts; PipeWire stays the server
      desktop-file-utils # update-desktop-database for webapp-remove
      e2fsprogs # chattr for disk-speedtest and hibernation-setup
      v4l-utils # v4l2-ctl for the screen recording webcam overlay

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
      fcitx5 # input method with addons (see the let binding above)
      fcitx5-gtk
      qt6Packages.fcitx5-qt
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
      btop
      powertop
      fastfetch
      gum
      bluetui
      inxi

      # Native Wayland screensaver (quattro replaced the terminal one). It
      # draws the branding text with ttfx effects.
      omarchy-screensaver
      ttfx

      # The engine behind `omarchy agent local`
      omarchy-local-ai

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
      localsend
      signed # quattro replaced Xournal++ with Signed for signing PDFs
      disktree # quattro replaced the dua Disk Usage TUI with Disktree
      hype # Markdown presentations
      monologue # webcam recorder
      gliff # Hyprland remote desktop over SSH
    ]
    ++ lib.optionals cfg.office_suite.enable [
      libreoffice-fresh
    ]
    ++ lib.optionals cfg.voxtype.enable [
      voxtype
      wtype
    ]
    ++ lib.optionals cfg.superwhisper.enable [
      superwhisper
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
      qtengine # QT_QPA_PLATFORMTHEME=qtengine in default/hypr/envs.lua
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
