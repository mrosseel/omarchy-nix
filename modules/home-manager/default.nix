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
    # https://github.com/NixOS/nixpkgs/issues/XXXXX
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

  colorScheme = selectedColorScheme;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = if isLightModeEnabled then "prefer-light" else "prefer-dark";
    };
  };

  gtk = {
    enable = true;
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
  programs.neovim.enable = true;
}
