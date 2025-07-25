{
  config,
  lib,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    # Environment variables
    # https://wiki.hyprland.org/Configuring/Variables/#input
    input = lib.mkDefault {
      kb_layout = "us";
      kb_variant = "dvorak";
      # kb_model =
      kb_options = "compose:caps";
      # kb_rules =

      follow_mouse = 1;

      sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

      touchpad = {
        natural_scroll = false;
      };
    };

    # https://wiki.hyprland.org/Configuring/Variables/#gestures
    gestures = lib.mkDefault {
      workspace_swipe = false;
    };
  };
}
