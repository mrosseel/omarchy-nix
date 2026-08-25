{
  config,
  lib,
  pkgs,
  ...
}: {
  # Chromium browser configuration
  # Flags are applied via XDG config file for Chromium/Chrome/Brave compatibility

  home.file.".local/share/omarchy/default/chromium/extensions/copy-url" = {
    source = ../../default/chromium/extensions/copy-url;
    recursive = true;
  };

  # Slims WhatsApp Web's chrome down and follows the system light/dark mode.
  home.file.".local/share/omarchy/default/chromium/extensions/whatsapp-slim" = {
    source = ../../default/chromium/extensions/whatsapp-slim;
    recursive = true;
  };

  # Copy URL now hands the URL to a native messaging host, which owns the
  # Wayland clipboard write and the confirmation toast (the old in-page
  # clipboard write only worked on focused, non-restricted pages).
  home.file.".local/share/omarchy/default/chromium/native-messaging-hosts/com.omarchy.copy_url.json".source =
    ../../default/chromium/native-messaging-hosts/com.omarchy.copy_url.json;

  # Upstream registers the host from the installer/migration. The manifest has
  # to name an absolute path per browser profile dir, so run the same script on
  # activation instead of writing each NativeMessagingHosts file declaratively.
  home.activation.registerChromiumCopyUrlHost = lib.hm.dag.entryAfter ["writeBoundary"] ''
    OMARCHY_PATH="$HOME/.local/share/omarchy" \
      $DRY_RUN_CMD "$HOME/.local/share/omarchy/bin/omarchy-install-chromium-copy-url" || true
  '';

  xdg.configFile."chromium-flags.conf".text = ''
    --ozone-platform=wayland
    --ozone-platform-hint=wayland
    --password-store=gnome-libsecret
    --enable-features=TouchpadOverscrollHistoryNavigation
    --load-extension=~/.local/share/omarchy/default/chromium/extensions/copy-url,~/.local/share/omarchy/default/chromium/extensions/whatsapp-slim
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
        color_scheme = 2; # Dark mode
        user_color = 2;
      };
    };
  };
}
