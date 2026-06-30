inputs: {
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./hyprland/configuration.nix];
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # HM >= 26.05 defaults this to "lua", but our hyprland/*.nix modules use
    # extraConfig with hyprlang strings (bindings.nix, windows.nix, input.nix,
    # looknfeel.nix); in lua mode HM dumps extraConfig raw into hyprland.lua,
    # which is invalid. Migrating to lua means porting every extraConfig block
    # into structured settings = { ... } first.
    configType = "hyprlang";
  };
  # Retired by the Omarchy 4 shell (omarchy-shell owns the polkit agent via its
  # polkit plugin). Gated off when omarchy.shell.enable.
  services.hyprpolkitagent.enable = lib.mkIf (!config.omarchy.shell.enable) true;
}
