{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  programs.zellij = {
    enable = lib.mkDefault true;

    settings = lib.mkDefault {
      theme = "omarchy";
      default_shell = "nu";
      pane_frames = false;
      default_layout = "default";
      default_mode = "normal";
      mouse_mode = true;
      copy_on_select = true;
      scrollback_editor = "nvim";
    };
  };

  # Load theme from runtime config (allows dynamic theme switching)
  xdg.configFile."zellij/themes/omarchy.kdl".source =
    config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/omarchy/current/theme/zellij.kdl";
}
