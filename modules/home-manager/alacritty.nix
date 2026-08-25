{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  programs.alacritty = {
    enable = true;
    settings = {
      # Load theme from runtime config (allows dynamic theme switching)
      general.import = ["~/.local/state/omarchy/current/theme/alacritty.toml"];

      env.TERM = "xterm-256color";

      terminal.osc52 = "CopyPaste";

      font = {
        size = 9;
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
      };

      window = {
        padding = {
          x = 14;
          y = 14;
        };
        decorations = "None";
      };

      # Universal copy/paste (works with Hyprland's Super+C/V → Ctrl/Shift+Insert mapping)
      keyboard.bindings = [
        {
          key = "Insert";
          mods = "Shift";
          action = "Paste";
        }
        {
          key = "Insert";
          mods = "Control";
          action = "Copy";
        }
        # Send Shift+Return as CSI-u so TUIs can distinguish it from Return
        # without treating it as Alt+Return. Upstream writes \u001b as a TOML
        # escape; Nix has no \u escape, so build the ESC byte via fromJSON.
        {
          key = "Return";
          mods = "Shift";
          chars = (builtins.fromJSON ''"\u001b"'') + "[13;2u";
        }
        # Legacy encoding sends Alt+Shift+Return the same as Alt+Return; send
        # CSI-u so tmux can match M-S-Enter.
        {
          key = "Return";
          mods = "Alt|Shift";
          chars = (builtins.fromJSON ''"\u001b"'') + "[13;4u";
        }
      ];
    };
  };
}
