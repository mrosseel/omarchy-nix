lib: {
  omarchyOptions = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "Main user's username (system login name)";
      example = "alice";
    };
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
        "ethereal"
        "hackerman"
        "osaka-jade"
        "ristretto"
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
    gaming = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable gaming support (Steam, game optimizations)";
          };
        };
      };
      default = {};
      description = "Gaming configuration";
    };
    nvidia = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable NVIDIA GPU support with proprietary drivers";
          };
        };
      };
      default = {};
      description = "NVIDIA GPU configuration";
    };
    quick_app_bindings = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "A list of single keystroke key bindings to launch common apps.";
      default = [
        # Web apps - using plain SUPER for frequently used apps
        "SUPER, A, ChatGPT, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp chatgpt https://chatgpt.com"
        "SUPER SHIFT, A, Grok, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp grok https://grok.com"
        "SUPER, C, Calendar, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp 'hey.*calendar' https://app.hey.com/calendar/weeks/"
        "SUPER, E, HEY Email, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp hey https://app.hey.com"
        "SUPER, Y, YouTube, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp youtube https://youtube.com/"
        "SUPER SHIFT, G, WhatsApp, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp whatsapp https://web.whatsapp.com/"
        "SUPER, X, X (Twitter), exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp 'x.com' https://x.com/"
        "SUPER SHIFT, X, Compose post on X, exec, $webapp=https://x.com/compose/post"

        # Core apps - using SUPER SHIFT to avoid conflicts with tiling keys
        "SUPER, RETURN, Terminal, exec, $terminal"
        "SUPER SHIFT, F, File manager, exec, $fileManager"
        "SUPER SHIFT, B, Web browser, exec, $browser"
        "SUPER SHIFT, M, Music player, exec, $music"
        "SUPER SHIFT, N, Neovim, exec, $terminal -e nvim"
        "SUPER SHIFT, T, Top, exec, $terminal -e btop"
        "SUPER SHIFT, D, Lazy Docker, exec, $terminal -e lazydocker"
        "SUPER SHIFT, I, Messenger, exec, $messenger"
        "SUPER SHIFT, O, Obsidian, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus obsidian 'obsidian --disable-gpu'"
        "SUPER, SLASH, Password manager, exec, $passwordManager"
        "SUPER, R, Calculator, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus gnome-calculator gnome-calculator"
        # Uncomment if gaming.enable = true (changed from SUPER, S to avoid scratchpad conflict):
        # "SUPER SHIFT, S, Steam, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus steam steam"
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
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Username for auto-login. If not set, uses omarchy.username.";
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
