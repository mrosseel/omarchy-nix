inputs: {
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {

}: {
  programs.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    withUWSM = cfg.seamless_boot.enable;
  };

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
    config.hyprland.default = [ "hyprland" "gtk" ];
  };

  # Enable InputCapture portal for screen sharing applications like Deskflow
  xdg.portal.config.hyprland."org.freedesktop.impl.portal.InputCapture" = [ "hyprland" ];
}
