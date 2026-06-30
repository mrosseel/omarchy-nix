inputs: {
  config,
  pkgs,
  lib,
  ...
}: let
  palette = config.colorScheme.palette;
  convert = inputs.nix-colors.lib.conversions.hexToRGBString;
  backgroundRgb = "rgba(${convert ", " palette.base00}, 0.8)";
  surfaceRgb = "rgb(${convert ", " palette.base02})";
  foregroundRgb = "rgb(${convert ", " palette.base05})";
  foregroundMutedRgb = "rgb(${convert ", " palette.base04})";
  cfg = config.omarchy;
in {
  # Retired by the Omarchy 4 shell (omarchy-shell owns the lock screen via its
  # lock plugin). Gated off when omarchy.shell.enable.
  programs.hyprlock = lib.mkIf (!cfg.shell.enable) {
    enable = true;
    settings = {
      general = {
        ignore_empty_input = true;
      };
      animations = {
        enabled = false;
      };
      auth = {
        fingerprint.enabled = true;
      };
      background = {
        monitor = "";
        path = "~/.config/omarchy/current/background";
        color = backgroundRgb;
        blur_passes = 3;
      };

      input-field = {
        monitor = "";
        size = "600, 100";
        position = "0, 0";
        halign = "center";
        valign = "center";

        inner_color = surfaceRgb;
        outer_color = foregroundRgb; # #d3c6aa
        outline_thickness = 4;

        font_family = "CaskaydiaMono Nerd Font";
        # font_size removed in newer hyprlock - using default
        font_color = foregroundRgb;

        # placeholder_color removed in newer hyprlock - using default
        placeholder_text = "  Enter Password 󰈷 ";
        check_color = "rgba(131, 192, 146, 1.0)";
        fail_text = "<i>$FAIL ($ATTEMPTS)</i>";

        rounding = 0;
        shadow_passes = 0;
        fade_on_empty = false;
      };

      label = {
        monitor = "";
        text = "\$FPRINTPROMPT";
        text_align = "center";
        color = "rgb(211, 198, 170)";
        font_size = 24;
        font_family = "CaskaydiaMono Nerd Font";
        position = "0, -100";
        halign = "center";
        valign = "center";
      };
    };
  };
}
