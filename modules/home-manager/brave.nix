{
  config,
  pkgs,
  ...
}: {
  # Brave browser configuration
  # Brave uses Chromium flags via brave-flags.conf

  xdg.configFile."brave-flags.conf".text = ''
    --ozone-platform=wayland
    --ozone-platform-hint=wayland
    --enable-features=TouchpadOverscrollHistoryNavigation
    # Chromium crash workaround for Wayland color management on Hyprland
    # See https://github.com/hyprwm/Hyprland/issues/11957
    --disable-features=WaylandWpColorManagerV1
  '';
}
