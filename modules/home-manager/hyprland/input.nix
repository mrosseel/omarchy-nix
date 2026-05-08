{
  config,
  lib,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    # https://wiki.hyprland.org/Configuring/Variables/#input
    # Each key uses lib.mkDefault so user path-based overrides merge cleanly.
    input.kb_layout = lib.mkDefault "us";
    input.kb_options = lib.mkDefault "compose:caps";
    input.repeat_rate = lib.mkDefault 40;
    input.repeat_delay = lib.mkDefault 250;
    input.numlock_by_default = lib.mkDefault true;
    input.follow_mouse = lib.mkDefault 1;
    input.sensitivity = lib.mkDefault 0;
    input.touchpad.natural_scroll = lib.mkDefault false;
    input.touchpad.scroll_factor = lib.mkDefault 0.4;
    input.touchpad.clickfinger_behavior = lib.mkDefault true;

    misc.key_press_enables_dpms = true;
    misc.mouse_move_enables_dpms = true;
    misc.allow_session_lock_restore = true;
  };

  wayland.windowManager.hyprland.extraConfig = ''
    # Scroll nicely in the terminal
    windowrule = match:class (Alacritty|kitty), scroll_touchpad 1.5
    windowrule = match:class com.mitchellh.ghostty, scroll_touchpad 0.2
  '';
}
