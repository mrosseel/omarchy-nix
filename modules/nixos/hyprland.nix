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
  # The key that hyprland.cachix.org publishes. With a wrong key, Nix rejects
  # every substitute from the cache and builds Hyprland from source.
  nix.settings.extra-trusted-public-keys = [
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
  ];

  # Upstream default/uwsm/default. Hyprland 0.57 asks rtkit for realtime
  # scheduling, which caps its main thread at 200 ms of CPU without a break. A
  # single slow kernel call (a monitor probe, a wake from DPMS off, a busy
  # Xwayland game) can cross that cap, and the kernel then SIGKILLs the
  # compositor before its SIGXCPU fallback can run. Remove once
  # hyprwm/Hyprland#16648 is fixed. Nix deviation: omarchy-nix does not deploy
  # the uwsm defaults file, so the session variable is set here.
  environment.sessionVariables.HYPRLAND_NO_RT = "1";

  # Upstream etc/systemd/user/wayland-wm@hyprland.desktop.service.d/10-keep-shell.conf:
  # let start-hyprland stop the compositor before its shell clients are killed.
  # A SIGTERM to the whole group removes the wallpaper during teardown.
  # A raw unit text, because systemd.user.services would also write a minimal
  # PATH into the drop-in and replace the session PATH of the compositor.
  systemd.user.units."wayland-wm@hyprland.desktop.service" = {
    overrideStrategy = "asDropin";
    text = ''
      [Service]
      KillMode=mixed
    '';
  };

  # Upstream etc/xkb: Omarchy's own XKB option omarchy:shift_caps_compose, which
  # default/hypr/input.lua sets. libxkbcommon reads /etc/xkb before the system
  # rules (nixpkgs builds it with xkb-config-extra-path=/etc/xkb).
  environment.etc."xkb/rules/evdev".source = ../../etc/xkb/rules/evdev;
  environment.etc."xkb/symbols/omarchy".source = ../../etc/xkb/symbols/omarchy;

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
    # Upstream config/xdg-desktop-portal/hyprland-portals.conf. The gnome-keyring
    # portal comes from services.gnome.gnome-keyring (modules/nixos/system.nix).
    config.hyprland."org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
  };

  # Deviation from Omarchy: the file chooser comes from the GNOME portal (GTK4)
  # and not the GTK portal (GTK3). The GTK3 chooser is local-only by default and
  # the GTK portal never turns that off, so Other Locations shows no network
  # hosts and no Connect to Server field. The GTK4 chooser has no such filter.
  xdg.portal.config.hyprland."org.freedesktop.impl.portal.FileChooser" = ["gnome"];

  # Enable InputCapture portal for screen sharing applications like Deskflow
  xdg.portal.config.hyprland."org.freedesktop.impl.portal.InputCapture" = ["hyprland"];
}
