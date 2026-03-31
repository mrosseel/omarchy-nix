{
  config,
  lib,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    # https://wiki.hyprland.org/Configuring/Variables/#input
    input = lib.mkDefault {
      kb_layout = "us";
      kb_options = "compose:caps";

      repeat_rate = 40;
      repeat_delay = 600;

      numlock_by_default = true;

      follow_mouse = 1;

      sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

      touchpad = {
        natural_scroll = false;
        scroll_factor = 0.4;
      };
    };

    misc = {
      key_press_enables_dpms = true;
      mouse_move_enables_dpms = true;
      allow_session_lock_restore = true;
    };
  };

  wayland.windowManager.hyprland.extraConfig = ''
    # Scroll nicely in the terminal
    windowrule = match:class (Alacritty|kitty), scroll_touchpad 1.5
    windowrule = match:class com.mitchellh.ghostty, scroll_touchpad 0.2
  '';
}
