inputs: {
  config,
  pkgs,
  lib,
  ...
}: let
  packages = import ../packages.nix {inherit pkgs config lib;};

  themes = import ../themes.nix;
  customSchemes = import ../custom-base16-schemes.nix;

  # Light theme detection logic
  lightModeFilePath = "${config.home.homeDirectory}/.config/omarchy/theme/light.mode";
  isLightModeEnabled = config.omarchy.light_theme_detection.enable && builtins.pathExists lightModeFilePath;

  # Determine effective theme
  effectiveTheme =
    if isLightModeEnabled && builtins.hasAttr config.omarchy.theme config.omarchy.light_theme_detection.light_theme_mappings
    then config.omarchy.light_theme_detection.light_theme_mappings.${config.omarchy.theme}
    else config.omarchy.theme;

  selectedTheme = themes.${effectiveTheme};

  # Get color scheme - use custom scheme if marked, otherwise use nix-colors
  selectedColorScheme =
    if selectedTheme ? custom-scheme && selectedTheme.custom-scheme
    then customSchemes.${selectedTheme.base16-theme}
    else inputs.nix-colors.colorSchemes.${selectedTheme.base16-theme};
in {
  imports = [
    (import ./hyprland.nix inputs)
    (import ./hyprlock.nix inputs)
    (import ./swaybg.nix)
    (import ./swayosd.nix)
    (import ./hypridle.nix)
    (import ./ghostty.nix)
    (import ./alacritty.nix)
    (import ./kitty.nix)
    (import ./foot.nix)
    (import ./btop.nix)
    (import ./direnv.nix)
    (import ./git.nix)
    (import ./mako.nix)
    (import ./starship.nix)
    (import ./vscode.nix)
    (import ./waybar.nix inputs)
    (import ./walker.nix)
    (import ./zoxide.nix)
    (import ./zsh.nix)
    ./chromium.nix
    ./brave.nix
    ./xdph.nix
    ./hyprland-preview-share-picker.nix
    ./hyprsunset.nix
    ./desktop-entries.nix
    ./light-theme-monitor.nix
    ./battery-monitor.nix
    ./voxtype.nix
    ./fonts.nix
    ./imv.nix
    ./evince.nix
    ./zellij.nix
    ./tmux.nix
    (import ./theme-generator.nix inputs)
  ];

  home.file = {
    ".local/share/omarchy/bin" = {
      source = ../../bin;
      recursive = true;
    };
    ".config/omarchy/branding" = {
      source = ../../config/branding;
      recursive = true;
    };
    # Deploy logo.txt to ~/.local/share/omarchy/ (read-only source)
    ".local/share/omarchy/logo.txt".source = ../../config/branding/logo.txt;
    ".config/omarchy/screensaver" = {
      source = ../../config/screensaver;
      recursive = true;
    };
    ".config/omarchy/webapp-icons" = {
      source = ../../config/webapp-icons;
      recursive = true;
    };
    ".config/elephant/menus" = {
      source = ../../default/elephant;
      recursive = true;
    };
    ".local/share/omarchy/default/walker/themes" = {
      source = ../../default/walker/themes;
      recursive = true;
    };
    ".config/walker/config.toml" = {
      source = ../../config/walker/config.toml;
    };
    ".config/xdg-terminals.list" = {
      source = ../../config/xdg-terminals.list;
    };
    # Disable bluetooth GUI tray apps - we use bluetui TUI instead
    ".config/autostart/blueberry-tray.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
    ".config/autostart/blueman.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
    # Hide duplicate Brave entry (nixpkgs bug: NoDisplay=true is outside [Desktop Entry] section)
    ".local/share/applications/com.brave.Browser.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
    ".config/elephant/calc.toml" = {
      source = ../../config/elephant/calc.toml;
    };
    ".config/elephant/desktopapplications.toml" = {
      source = ../../config/elephant/desktopapplications.toml;
    };
    ".local/share/omarchy/default/bash" = {
      source = ../../default/bash;
      recursive = true;
    };
    ".local/share/omarchy/version".source = ../../default/omarchy-version;
    ".local/share/omarchy/default/hypr" = {
      source = ../../default/hypr;
      recursive = true;
    };
    ".local/share/omarchy/default/themed" = {
      source = ../../default/themed;
      recursive = true;
    };
    # Hook sample tree (read-only source under $OMARCHY_PATH); the activation
    # below seeds copies into ~/.config/omarchy/hooks/ so users can rename
    # *.sample to enable a hook.
    ".local/share/omarchy/default/hooks" = {
      source = ../../config/omarchy/hooks;
      recursive = true;
    };
    # Waybar helper scripts referenced from the static waybar config via
    # $OMARCHY_PATH/default/waybar/...
    ".local/share/omarchy/default/waybar" = {
      source = ../../default/waybar;
      recursive = true;
    };
    # Nautilus-python extensions (Send via LocalSend, Transcode) — upstream
    # install/config/nautilus-python.sh copies these to the same location.
    ".local/share/nautilus-python/extensions" = {
      source = ../../default/nautilus-python/extensions;
      recursive = true;
    };
  };
  home.packages = packages.homePackages;

  # Add omarchy bin directory to PATH
  home.sessionPath = [
    "$HOME/.local/share/omarchy/bin"
  ];

  # Copy logo.txt to screensaver.txt on first use (user-customizable)
  home.activation.copyScreensaverTxt = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -f "$HOME/.config/omarchy/branding/screensaver.txt" ]; then
      mkdir -p "$HOME/.config/omarchy/branding"
      cp "$HOME/.local/share/omarchy/logo.txt" "$HOME/.config/omarchy/branding/screensaver.txt"
    fi
  '';

  # Seed Hyprland toggle state dir (omarchy install/config/omarchy-toggles.sh equivalent)
  home.activation.seedHyprToggles = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$HOME/.local/state/omarchy/toggles/hypr"
    if [ ! -f "$HOME/.local/state/omarchy/toggles/hypr/flags.conf" ]; then
      cp "$HOME/.local/share/omarchy/default/hypr/toggles/flags.conf" \
         "$HOME/.local/state/omarchy/toggles/hypr/flags.conf"
    fi
  '';

  # Seed ~/.config/omarchy/hooks/ with .sample files from the read-only source
  # tree. The user renames *.sample (drops the extension) to enable a hook.
  # Existing files are never overwritten - this is one-shot bootstrap per name.
  home.activation.seedOmarchyHookSamples = lib.hm.dag.entryAfter ["writeBoundary"] ''
    src="$HOME/.local/share/omarchy/default/hooks"
    dst="$HOME/.config/omarchy/hooks"
    if [ -d "$src" ]; then
      while IFS= read -r -d ''' rel; do
        target="$dst/$rel"
        if [ ! -e "$target" ]; then
          mkdir -p "$(dirname "$target")"
          cp "$src/$rel" "$target"
          chmod 755 "$target"
        fi
      done < <(cd "$src" && find . -type f -name '*.sample' -printf '%P\0')
    fi
  '';

  # Restart walker / elephant daemons after every switch so they pick up
  # the new binaries instead of holding onto a stale /nix/store path. Without
  # this, any walker --dmenu the user opens after an update would talk to a
  # daemon from before the switch — accumulating zombies that the menu's
  # toggle logic can't close, and breaking the menu until manual cleanup.
  # Using -f (match command line) instead of -x (match comm), because Nix's
  # wrapper binary has comm `.walker-wrapped` rather than `walker`.
  # `.elephant-wrapped` is the matching token for elephant's wrapper.
  home.activation.restartWalkerStack = lib.hm.dag.entryAfter ["writeBoundary"] ''
    pkill -9 -f "walker.*--dmenu" 2>/dev/null || true
    pkill -f "walker --gapplication-service" 2>/dev/null || true
    pkill -9 -f "\.elephant-wrapped" 2>/dev/null || true
  '';

  # Recover internal display when no external monitor is attached at session start.
  # Mirrors upstream config/systemd/user/omarchy-recover-internal-monitor.service.
  systemd.user.services.omarchy-recover-internal-monitor = {
    Unit = {
      Description = "Recover the internal monitor toggle when no external display is connected";
      Before = [ "graphical-session-pre.target" ];
      ConditionPathExists = "%h/.local/state/omarchy/toggles/hypr/internal-monitor-disable.conf";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "%h/.local/share/omarchy/bin/omarchy-hw-recover-internal-monitor";
    };
    Install.WantedBy = [ "graphical-session-pre.target" ];
  };

  # XDG user directories (omarchy install/config/user-dirs.sh equivalent)
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    download = "${config.home.homeDirectory}/Downloads";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
    desktop = config.home.homeDirectory;
    publicShare = config.home.homeDirectory;
    templates = config.home.homeDirectory;
  };

  colorScheme = selectedColorScheme;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = if isLightModeEnabled then "prefer-light" else "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    gtk4.theme = null;
    theme = {
      name = if isLightModeEnabled then "Adwaita" else "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    cursorTheme = {
      name = if isLightModeEnabled then "Bibata-Modern-Classic" else "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    name = if isLightModeEnabled then "Bibata-Modern-Classic" else "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
  };

  # TODO: Add an actual nvim config
  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
  };
}
