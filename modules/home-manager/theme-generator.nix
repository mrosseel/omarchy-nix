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

  # Generate foot's per-theme colors from the SAME source the other terminals
  # use — the theme's pre-rendered alacritty.toml — so foot matches ghostty/
  # alacritty/kitty exactly. Deriving from base16 base00 diverged for themes
  # whose terminal background isn't base00 (e.g. vantablack: bg #0d0d0d vs base00
  # #000000). This also works for every theme, including flexoki-light which has
  # no base16 scheme.
  strip = v: lib.removePrefix "0x" (lib.removePrefix "#" v);
  mkFootIni = themeName: let
    alac = builtins.fromTOML (builtins.readFile ../../config/themes/${getThemeSource themeName}/alacritty.toml);
    c = alac.colors;
    p = c.primary;
    n = c.normal;
    b = c.bright;
  in ''
    [colors-dark]
    foreground=${strip p.foreground}
    background=${strip p.background}
    regular0=${strip n.black}
    regular1=${strip n.red}
    regular2=${strip n.green}
    regular3=${strip n.yellow}
    regular4=${strip n.blue}
    regular5=${strip n.magenta}
    regular6=${strip n.cyan}
    regular7=${strip n.white}
    bright0=${strip b.black}
    bright1=${strip b.red}
    bright2=${strip b.green}
    bright3=${strip b.yellow}
    bright4=${strip b.blue}
    bright5=${strip b.magenta}
    bright6=${strip b.cyan}
    bright7=${strip b.white}
  '';

  # Theme dir = the checked-in pre-rendered configs + a foot.ini derived from the
  # theme's alacritty.toml (the foot port shipped no foot.ini, so foot never
  # followed the theme).
  themeDir = themeName:
    pkgs.runCommand "omarchy-theme-${themeName}" {} ''
      cp -r ${../../config/themes/${getThemeSource themeName}} $out
      chmod -R u+w $out
      cp ${pkgs.writeText "foot-${themeName}.ini" (mkFootIni themeName)} $out/foot.ini
    '';
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
