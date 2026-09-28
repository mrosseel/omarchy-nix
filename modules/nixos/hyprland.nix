inputs: {
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;

  # Custom desktop file that uses start-hyprland wrapper
  hyprland-uwsm-fixed = pkgs.makeDesktopItem {
    name = "hyprland-uwsm";
    desktopName = "Hyprland (UWSM)";
    comment = "Hyprland compositor managed by UWSM";
    exec = "${pkgs.uwsm}/bin/uwsm start -F -- start-hyprland";
    type = "Application";
    categories = [];
  };
in {
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    withUWSM = true;
  };

  # We build Hyprland (+ aquamarine, hyprutils, portal, …) from the hyprland
  # flake, not nixpkgs, so cache.nixos.org has none of those store paths. Point
  # at the upstream Hyprland cache so consumers pull prebuilt binaries instead
  # of compiling the whole stack on every bump. Colocated with the package it
  # serves; appends to the default substituters, doesn't replace them.
  nix.settings.extra-substituters = ["https://hyprland.cachix.org"];
  nix.settings.extra-trusted-public-keys = [
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzJ6jXYv+S+rfAoja0iy6vGm7A="
  ];

  # Override the auto-generated desktop file with our fixed version.
  # SDDM picks the session whose name contains "uwsm" (see default/sddm/omarchy/Main.qml).
  environment.systemPackages = [
    (pkgs.runCommand "hyprland-uwsm-override" {} ''
            mkdir -p $out/share/wayland-sessions
            cat > $out/share/wayland-sessions/hyprland-uwsm.desktop <<EOF
      [Desktop Entry]
      Name=Hyprland (UWSM)
      Comment=Hyprland compositor managed by UWSM
      Exec=${pkgs.uwsm}/bin/uwsm start -F -- start-hyprland
      Type=Application
      EOF
    '')
  ];

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-gnome];
    config.common.default = "*";
    config.hyprland.default = ["hyprland" "gtk"];
  };

  # Deviation from Omarchy: the file chooser comes from the GNOME portal (GTK4)
  # and not the GTK portal (GTK3). The GTK3 chooser is local-only by default and
  # the GTK portal never turns that off, so Other Locations shows no network
  # hosts and no Connect to Server field. The GTK4 chooser has no such filter.
  xdg.portal.config.hyprland."org.freedesktop.impl.portal.FileChooser" = ["gnome"];

  # Enable InputCapture portal for screen sharing applications like Deskflow
  xdg.portal.config.hyprland."org.freedesktop.impl.portal.InputCapture" = ["hyprland"];
}
