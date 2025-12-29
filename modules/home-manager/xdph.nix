{
  config,
  pkgs,
  ...
}: {
  # xdg-desktop-portal-hyprland configuration
  # Enables screen sharing with preview picker

  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
        allow_token_by_default = true
        custom_picker_binary = hyprland-preview-share-picker
    }
  '';
}
