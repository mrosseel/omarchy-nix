{
  config,
  pkgs,
  ...
}: {
  # Chromium browser configuration
  # Flags are applied via XDG config file for Chromium/Chrome/Brave compatibility

  home.file.".local/share/omarchy/default/chromium/extensions/copy-url" = {
    source = ../../default/chromium/extensions/copy-url;
    recursive = true;
  };

  xdg.configFile."chromium-flags.conf".text = ''
    --ozone-platform=wayland
    --ozone-platform-hint=wayland
    --enable-features=TouchpadOverscrollHistoryNavigation
    --load-extension=~/.local/share/omarchy/default/chromium/extensions/copy-url
    # Chromium crash workaround for Wayland color management on Hyprland
    # See https://github.com/hyprwm/Hyprland/issues/11957
    --disable-features=WaylandWpColorManagerV1
  '';

  # Chromium preferences for dark mode
  xdg.configFile."chromium/Default/Preferences".text = builtins.toJSON {
    extensions = {
      theme = {
        id = "";
        use_system = false;
        use_custom = false;
      };
    };
    browser = {
      theme = {
        color_scheme = 2;  # Dark mode
        user_color = 2;
      };
    };
  };
}
