{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
  colors = config.colorScheme.palette;

  # Walker configuration as TOML (matching original Omarchy)
  walkerConfigToml = ''
    force_keyboard_focus = true
    selection_wrap = true
    hide_action_hints = true

    [placeholders]
    "default" = { input = " Search...", list = "No Results" }

    [keybinds]
    quick_activate = []

    [columns]
    symbols = 1

    [providers]
    max_results = 256
    default = [
      "desktopapplications",
    ]

    [[providers.prefixes]]
    prefix = "/"
    provider = "providerlist"

    [[providers.prefixes]]
    prefix = ":"
    provider = "symbols"

    [[providers.prefixes]]
    prefix = "="
    provider = "calc"

    [[emergencies]]
    text = "Restart Walker"
    command = "omarchy-restart-walker"
  '';

  # Direct CSS override (walker auto-generates default.css, so we override it)
  walkerCss = ''
    #window {
      background: transparent;
    }

    #box {
      background: #${colors.base00};
      border: 2px solid #${colors.base0C};
      border-radius: 10px;
      padding: 20px;
    }

    #input {
      background: #${colors.base01};
      color: #${colors.base05};
      border: 1px solid #${colors.base03};
      border-radius: 5px;
      padding: 8px 12px;
    }

    child {
      all: unset;
    }

    child:selected #item {
      background: #${colors.base02};
    }

    child:selected #text {
      color: #${colors.base0D};
    }

    #text {
      color: #${colors.base05};
    }
  '';
in {
  # Install walker package
  home.packages = [ pkgs.walker ];

  # Configure walker using TOML format
  xdg.configFile."walker/config.toml".text = walkerConfigToml;

  # Override the theme CSS directly (walker will use this)
  xdg.configFile."walker/themes/default.css".text = walkerCss;
}