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
        "miasma"
        "vantablack"
        "white"
        "retro-82"
        "lumon"
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
      type = lib.types.submodule ({config, ...}: {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable gaming support umbrella (Steam, controllers, GPU 32-bit libs default-on; opt-in for Heroic/Lutris/Moonlight/Retroarch/Xbox Cloud/GeForce Now).";
          };
          steam.enable = lib.mkOption {
            type = lib.types.bool;
            default = config.enable;
            description = "Install Steam with Proton-GE, Remote Play, and dedicated server firewall openings.";
          };
          heroic.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Install Heroic Games Launcher (Epic / GOG / Amazon Prime).";
          };
          lutris.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Install Lutris with Wine/Winetricks (Battle.net is added through Lutris install scripts at runtime).";
          };
          moonlight.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Install Moonlight game streaming client.";
          };
          retroarch.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Install RetroArch with assets and a default selection of libretro cores.";
          };
          xboxCloud.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Install Xbox Cloud Gaming web app launcher.";
          };
          geforceNow.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Install GeForce NOW web app launcher.";
          };
          xboxControllers.enable = lib.mkOption {
            type = lib.types.bool;
            default = config.enable;
            description = "Enable Xbox controller support (xone, xpadneo, udev rules).";
          };
          gpuLib32.enable = lib.mkOption {
            type = lib.types.bool;
            default = config.enable;
            description = "Enable 32-bit graphics libraries (required by many games).";
          };
        };
      });
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
        # Web apps - SUPER SHIFT (matches upstream Omarchy; plain SUPER is reserved
        # for clipboard / window-management bindings, so promoting webapps to plain
        # SUPER produces double-fires with SUPER+C/V/X universal copy/paste/cut).
        "SUPER SHIFT, A, ChatGPT, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp chatgpt https://chatgpt.com"
        "SUPER SHIFT ALT, A, Grok, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp grok https://grok.com"
        "SUPER SHIFT, C, Calendar, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp 'hey.*calendar' https://app.hey.com/calendar/weeks/"
        "SUPER SHIFT, E, Email, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp hey https://app.hey.com"
        "SUPER SHIFT, Y, YouTube, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp youtube https://youtube.com/"
        "SUPER SHIFT ALT, G, WhatsApp, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp whatsapp https://web.whatsapp.com/"
        "SUPER SHIFT, X, X, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp 'x.com' https://x.com/"
        "SUPER SHIFT ALT, X, X Post, exec, ~/.local/share/omarchy/bin/omarchy-launch-webapp https://x.com/compose/post"

        # Core apps - SUPER SHIFT to avoid conflicts with tiling/clipboard keys
        "SUPER, RETURN, Terminal, exec, $terminal"
        "SUPER ALT, RETURN, Tmux, exec, $terminal tmux new"
        "SUPER SHIFT, RETURN, Browser, exec, $browser"
        "SUPER SHIFT, F, File manager, exec, $fileManager"
        "SUPER SHIFT, B, Web browser, exec, $browser"
        "SUPER SHIFT, M, Music player, exec, $music"
        "SUPER SHIFT, N, Neovim, exec, $terminal -e nvim"
        "SUPER SHIFT, T, Top, exec, $terminal -e btop"
        "SUPER SHIFT, D, Lazy Docker, exec, $terminal -e lazydocker"
        "SUPER SHIFT, I, Messenger, exec, $messenger"
        "SUPER SHIFT, O, Obsidian, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus obsidian 'obsidian --disable-gpu'"
        "SUPER SHIFT, SLASH, Password manager, exec, $passwordManager"
        "SUPER SHIFT, R, Calculator, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus gnome-calculator gnome-calculator"
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
    voxtype = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Voxtype voice dictation support";
          };
        };
      };
      default = {};
      description = "Voxtype voice dictation configuration";
    };
    hardware = lib.mkOption {
      type = lib.types.submodule {
        options = {
          asus_b9406.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Apply ASUS ExpertBook B9406 (Panther Lake / Xe3) workarounds: panel-replay/dpcd-backlight kernel params and Pixart 093A:4F05 touchpad libinput quirk.";
          };
          asus_z13.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "ASUS ROG Flow Z13 (GZ302) detachable keyboard touchpad fix (mark touchpad as internal so libinput dwt pairs it with the keyboard).";
          };
          intel_ptl_fred.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Intel Panther Lake Flexible Return and Event Delivery (fred=on kernel parameter).";
          };
        };
      };
      default = {};
      description = "Hardware-specific workarounds (off by default; enable per machine).";
    };
  };
}
