{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  programs.foot = {
    enable = lib.mkDefault true;

    # Mirror upstream config/foot/foot.ini behavior. Theme loads dynamically
    # from the omarchy theme runtime path so theme switches take effect on
    # new foot windows (and via omarchy-theme-set-foot for live ones).
    settings = lib.mkDefault {
      main = {
        include = "~/.config/omarchy/current/theme/foot.ini";
        term = "xterm-256color";
        font = "JetBrainsMono Nerd Font:size=9";
        pad = "14x14";
        initial-window-mode = "windowed";
        workers = 0;
      };

      scrollback.lines = 10000;

      cursor = {
        style = "block";
        blink = "no";
      };

      # Universal copy/paste — pairs with Hyprland's Super+C/V → Ctrl/Shift+Insert
      # remap so the standard omarchy keystrokes hit the system clipboard.
      key-bindings = {
        clipboard-copy = "Control+Insert";
        primary-paste = "none";
        clipboard-paste = "Shift+Insert";
      };
    };
  };
}
