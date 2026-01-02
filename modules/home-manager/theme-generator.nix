inputs: {
  config,
  pkgs,
  lib,
  ...
}: let
  themes = import ../themes.nix;
  themeNames = builtins.attrNames themes;

  # Map theme names to their actual directory (some themes share directories)
  themeSourceMap = {
    "rose-pine-dawn" = "rose-pine";
    "rose-pine-moon" = "rose-pine";
    "gruvbox-light" = "gruvbox";
  };

  # Get the source directory for a theme
  getThemeSource = themeName:
    if builtins.hasAttr themeName themeSourceMap
    then themeSourceMap.${themeName}
    else themeName;
in {
  # Install each theme directory individually
  home.file = lib.listToAttrs (map (themeName: {
    name = ".config/omarchy/themes/${themeName}";
    value = {
      source = ../../config/themes/${getThemeSource themeName};
      recursive = true;
    };
  }) themeNames);

  # Create initial symlink to current theme
  home.activation.omarchy-theme-symlink = lib.hm.dag.entryAfter ["writeBoundary"] ''
    THEME_SYMLINK="$HOME/.config/omarchy/current/theme"
    CURRENT_THEME="${config.omarchy.theme}"

    mkdir -p "$(dirname "$THEME_SYMLINK")"

    # Only create symlink if it doesn't exist (don't override user's selection)
    if [[ ! -L "$THEME_SYMLINK" ]]; then
      $DRY_RUN_CMD ln -sf "$HOME/.config/omarchy/themes/$CURRENT_THEME" "$THEME_SYMLINK"
    fi
  '';
}
