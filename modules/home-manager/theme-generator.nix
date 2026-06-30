inputs: {
  config,
  pkgs,
  lib,
  ...
}: let
  themes = import ../themes.nix;
  themeNames = builtins.attrNames themes;
  customSchemes = import ../custom-base16-schemes.nix;

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

  # base16 palette for a theme (custom scheme or nix-colors), # stripped.
  # Custom schemes (custom-base16-schemes.nix) hold base00..base0F at the top
  # level; nix-colors schemes nest them under `.palette`.
  paletteFor = themeName: let
    t = themes.${themeName};
    custom = t ? custom-scheme && t.custom-scheme;
    scheme =
      if custom
      then customSchemes.${t.base16-theme}
      else inputs.nix-colors.colorSchemes.${t.base16-theme};
    raw =
      if custom
      then scheme
      else scheme.palette;
  in builtins.mapAttrs (_: v: lib.removePrefix "#" v) raw;

  # foot per-theme colors, rendered from the base16 palette (mirrors upstream
  # default/themed/foot.ini.tpl). The omarchy-nix theme dirs ship alacritty/
  # ghostty/kitty configs but historically no foot.ini, so the foot `include=
  # current/theme/foot.ini` resolved to nothing — foot never followed the theme.
  mkFootIni = p: ''
    [colors-dark]
    foreground=${p.base05}
    background=${p.base00}
    selection-foreground=${p.base00}
    selection-background=${p.base05}
    cursor=${p.base00} ${p.base05}
    regular0=${p.base00}
    regular1=${p.base08}
    regular2=${p.base0B}
    regular3=${p.base0A}
    regular4=${p.base0D}
    regular5=${p.base0E}
    regular6=${p.base0C}
    regular7=${p.base05}
    bright0=${p.base03}
    bright1=${p.base08}
    bright2=${p.base0B}
    bright3=${p.base0A}
    bright4=${p.base0D}
    bright5=${p.base0E}
    bright6=${p.base0C}
    bright7=${p.base07}
  '';

  # Whether a theme's base16 palette is resolvable (custom or in nix-colors).
  # flexoki-light is neither (partially ported), so it gets no generated foot.ini.
  hasScheme = themeName: let
    t = themes.${themeName};
    custom = t ? custom-scheme && t.custom-scheme;
  in
    if custom
    then builtins.hasAttr t.base16-theme customSchemes
    else builtins.hasAttr t.base16-theme inputs.nix-colors.colorSchemes;

  # Theme dir = the checked-in pre-rendered configs + a generated foot.ini
  # (when the palette resolves; otherwise just the plain source dir).
  themeDir = themeName:
    if hasScheme themeName
    then
      pkgs.runCommand "omarchy-theme-${themeName}" {} ''
        cp -r ${../../config/themes/${getThemeSource themeName}} $out
        chmod -R u+w $out
        cp ${pkgs.writeText "foot-${themeName}.ini" (mkFootIni (paletteFor themeName))} $out/foot.ini
      ''
    else ../../config/themes/${getThemeSource themeName};
in {
  # Install each theme directory individually (source + generated foot.ini)
  home.file = lib.listToAttrs (map (themeName: {
    name = ".config/omarchy/themes/${themeName}";
    value = {
      source = themeDir themeName;
      recursive = true;
    };
  }) themeNames);

  # Create initial symlink to current theme
  home.activation.omarchy-theme-symlink = lib.hm.dag.entryAfter ["writeBoundary"] ''
    THEME_SYMLINK="$HOME/.local/state/omarchy/current/theme"
    CURRENT_THEME="${config.omarchy.theme}"

    mkdir -p "$(dirname "$THEME_SYMLINK")"

    # Only create symlink if it doesn't exist (don't override user's selection)
    if [[ ! -L "$THEME_SYMLINK" ]]; then
      $DRY_RUN_CMD ln -sf "$HOME/.config/omarchy/themes/$CURRENT_THEME" "$THEME_SYMLINK"
    fi
  '';
}
