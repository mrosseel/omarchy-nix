lib: {
  omarchyOptions = {
    full_name = lib.mkOption {
      type = lib.types.str;
      description = "Main user's full name";
    };
    email_address = lib.mkOption {
      type = lib.types.str;
      description = "Main user's email address";
    };
    theme = lib.mkOption {
      type = lib.types.enum [
        "tokyo-night"
        "kanagawa"
        "everforest"
        "catppuccin"
        "catppuccin-latte"
        "rose-pine"
        "rose-pine-dawn"
        "rose-pine-moon"
        "nord"
        "gruvbox"
        "gruvbox-light"
        "flexoki-light"
        "matte-black"
      ];
      default = "tokyo-night";
      description = "Theme to use for Omarchy configuration";
    };
    primary_font = lib.mkOption {
      type = lib.types.str;
      default = "Liberation Sans 11";
    };
    vscode_settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    scale = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Display scale factor (1 for 1x displays, 2 for 2x displays)";
    };
    browser = lib.mkOption {
      type = lib.types.enum ["chromium" "brave"];
      default = "chromium";
      description = "Browser to use for web browsing";
    };
    terminal = lib.mkOption {
      type = lib.types.enum ["ghostty" "alacritty" "kitty"];
      default = "ghostty";
      description = "Terminal emulator to use";
    };
    office_suite = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable LibreOffice office suite";
          };
        };
      };
      default = {};
      description = "Office suite configuration";
    };
    quick_app_bindings = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "A list of single keystroke key bindings to launch common apps.";
      default = [
        "SUPER, A, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp chatgpt https://chatgpt.com"
        "SUPER SHIFT, A, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp grok https://grok.com"
        "SUPER, C, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp 'hey.*calendar' https://app.hey.com/calendar/weeks/"
        "SUPER, E, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp hey https://app.hey.com"
        "SUPER, Y, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp youtube https://youtube.com/"
        "SUPER SHIFT, G, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp whatsapp https://web.whatsapp.com/"
        "SUPER, X, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp 'x.com' https://x.com/"
        "SUPER SHIFT, X, exec, $webapp=https://x.com/compose/post"

        "SUPER, return, exec, $terminal"
        "SUPER, F, exec, $fileManager"
        "SUPER, B, exec, $browser"
        "SUPER, M, exec, $music"
        "SUPER, N, exec, $terminal -e nvim"
        "SUPER, T, exec, $terminal -e btop"
        "SUPER, D, exec, $terminal -e lazydocker"
        "SUPER, G, exec, $messenger"
        "SUPER, O, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus obsidian 'obsidian --disable-gpu'"
        "SUPER, slash, exec, $passwordManager"
        "SUPER, R, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus gnome-calculator gnome-calculator"
      ];
    };
    seamless_boot = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable seamless boot experience with Plymouth and auto-login";
          };
          username = lib.mkOption {
            type = lib.types.str;
            description = "Username for auto-login. Set this when seamless_boot.enable = true.";
            example = "dhh";
          };
          plymouth_theme = lib.mkOption {
            type = lib.types.str;
            default = "omarchy";
            description = "Plymouth theme to use for boot splash";
          };
          silent_boot = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable silent boot (suppress kernel messages)";
          };
        };
      };
      default = {};
      description = "Seamless boot configuration options";
    };
    light_theme_detection = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable automatic light/dark theme switching based on theme/light.mode file";
          };
          light_theme_mappings = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = {
              "tokyo-night" = "catppuccin-latte";
              "kanagawa" = "rose-pine-dawn";
              "everforest" = "gruvbox-light";
              "catppuccin" = "catppuccin-latte";
              "rose-pine" = "rose-pine-dawn";
              "rose-pine-moon" = "rose-pine-dawn";
              "nord" = "gruvbox-light";
              "gruvbox" = "gruvbox-light";
            };
            description = "Mapping of dark themes to their light counterparts";
          };
        };
      };
      default = {};
      description = "Light theme detection configuration";
    };
    fido2_auth = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable FIDO2/WebAuthn authentication support";
          };
          sudo_auth = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable FIDO2 authentication for sudo commands";
          };
          fingerprint_support = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable fingerprint authentication support";
          };
        };
      };
      default = {};
      description = "FIDO2 and biometric authentication configuration";
    };
    firewall = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable firewall protection";
          };
          use_ufw = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Use UFW for easier firewall management";
          };
          docker_protection = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable Docker container firewall protection";
          };
          allow_ssh = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Allow SSH connections";
          };
          allow_dev_ports = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Allow common development ports (3000, 4000, 5000, 8000, 8080, 9000)";
          };
          allowed_tcp_ports = lib.mkOption {
            type = lib.types.listOf lib.types.port;
            default = [];
            description = "Additional TCP ports to allow";
          };
          allowed_udp_ports = lib.mkOption {
            type = lib.types.listOf lib.types.port;
            default = [];
            description = "Additional UDP ports to allow";
          };
        };
      };
      default = {};
      description = "Firewall and security configuration";
    };
  };
}
