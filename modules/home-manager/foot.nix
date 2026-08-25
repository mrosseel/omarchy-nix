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
        include = "~/.local/state/omarchy/current/theme/foot.ini";
        term = "xterm-256color";
        font = "JetBrainsMono Nerd Font:size=9";
        pad = "14x14";
        initial-window-mode = "windowed";
        workers = 0;
      };

      scrollback = {
        lines = 10000;
        multiplier = 7.0;
      };

      cursor = {
        style = "block";
        blink = "no";
      };

      # Universal copy/paste — pairs with Hyprland's Super+C/V → Ctrl/Shift+Insert
      # remap so the standard omarchy keystrokes hit the system clipboard, plus
      # the conventional Ctrl+Shift+C/V terminal bindings (upstream fcde1057).
      key-bindings = {
        clipboard-copy = "Control+Insert Control+Shift+c XF86Copy";
        primary-paste = "none";
        clipboard-paste = "Shift+Insert Control+Shift+v XF86Paste";
      };

      # Send Shift+Return / Alt+Shift+Return as CSI-u so TUIs and tmux can
      # distinguish them from Return / Alt+Return.
      text-bindings = {
        "\\x1b[13;2u" = "Shift+Return";
        "\\x1b[13;4u" = "Mod1+Shift+Return";
      };
    };
  };
}
