inputs: {
  config,
  pkgs,
  ...
}: let
  packages = import ../packages.nix {inherit pkgs;};

  themes = import ../themes.nix;

  # Light theme detection logic
  lightModeFilePath = "${config.home.homeDirectory}/.config/omarchy/theme/light.mode";
  isLightModeEnabled = config.omarchy.light_theme_detection.enable && builtins.pathExists lightModeFilePath;

  # Determine effective theme
  effectiveTheme =
    if isLightModeEnabled && builtins.hasAttr config.omarchy.theme config.omarchy.light_theme_detection.light_theme_mappings
    then config.omarchy.light_theme_detection.light_theme_mappings.${config.omarchy.theme}
    else config.omarchy.theme;

  selectedTheme = themes.${effectiveTheme};
in {
  imports = [
    (import ./hyprland.nix inputs)
    (import ./hyprlock.nix inputs)
    (import ./swaybg.nix)
    (import ./hypridle.nix)
    (import ./ghostty.nix)
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
    ./light-theme-monitor.nix
  ];

  home.file = {
    ".local/share/omarchy/bin" = {
      source = ../../bin;
      recursive = true;
    };
  };
  home.packages = packages.homePackages;

  colorScheme = inputs.nix-colors.colorSchemes.${selectedTheme.base16-theme};

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
  };

  # TODO: Add an actual nvim config
  programs.neovim.enable = true;
}
