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
        "lupine"
        "solitude"
        "last-horizon"
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
    shell = lib.mkOption {
      type = lib.types.submodule {
        options = {
          workspace_count = lib.mkOption {
            type = lib.types.ints.between 1 20;
            default = 10;
            description = ''
              How many workspaces the bar's workspace widget shows. Omarchy binds
              SUPER + 1..0 to the first ten and ships no more, so 10 is the
              upstream default. Raise it only if you also bind the extra
              workspaces yourself (for example SUPER + F1..F10 through
              `wayland.windowManager.hyprland.extraConfig`) — this option only
              teaches the bar to display them.
            '';
          };
        };
      };
      default = {};
      description = "Omarchy shell (Quickshell) tweaks";
    };
    browser = lib.mkOption {
      type = lib.types.enum ["chromium" "brave"];
      default = "chromium";
      description = "Browser to use for web browsing";
    };
    terminal = lib.mkOption {
      type = lib.types.enum ["ghostty" "alacritty" "kitty" "foot"];
      default = "ghostty";
      description = "Terminal emulator to use. foot is Omarchy 4 (quattro)'s default; it accepts xterm-style `-e` so the terminal keybinds work unchanged.";
    };
    containers = lib.mkOption {
      type = lib.types.submodule {
        options = {
          sudoless_docker = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Add the user to the docker group so docker works without a prompt.
              The docker group is root-equivalent, so upstream Omarchy leaves it
              off by default and gates Docker access behind a polkit prompt.
            '';
          };
        };
      };
      default = {};
      description = "Container (Docker) configuration";
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
      description = ''
        Extra single keystroke key bindings to launch apps, in hyprlang
        "MODS, KEY, Description, exec, command" form.

        These become extra o.bind() calls on top of the Omarchy defaults in
        default/hypr/bindings/applications.lua. Hyprland's Lua binder appends,
        it does not replace. A combo that Omarchy already binds therefore fires
        twice. Keep upstream combos out of this list. To change the app behind
        a default binding, set omarchy.terminal or omarchy.browser, or run
        `omarchy default editor`.
      '';
      default = [
        # Omarchy binds no btop, calculator, or second messenger key, so these
        # three are additions and not overrides.
        "SUPER SHIFT, T, Top, exec, $terminal -e btop"
        "SUPER SHIFT, I, Messenger, exec, $messenger"
        # quattro replaced gnome-calculator with omacalc, so that is what
        # modules/packages.nix ships. Override this list to bind something else.
        "SUPER SHIFT, R, Calculator, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus omacalc omacalc"
        # Uncomment if gaming.enable = true (Omarchy binds SUPER SHIFT, S to Google Maps):
        # "SUPER SHIFT ALT, S, Steam, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus steam steam"
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
          config_file = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = ''
              Seed `~/.config/voxtype/config.toml` from this file instead of the
              Omarchy default. Copied once, never overwritten, so runtime edits
              survive a rebuild. Use it for a personal model choice, an
              `initial_prompt` naming your own jargon, or `[text].replacements`
              for terms the model keeps mishearing — none of which belong in a
              shared default.
            '';
          };
        };
      };
      default = {};
      description = "Voxtype voice dictation configuration";
    };
    hardware = lib.mkOption {
      type = lib.types.submodule {
        options = {
          apple_brcmfmac_supplicant.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Apple Macs with Broadcom Wi-Fi: run the WPA handshake in wpa_supplicant instead of the firmware, which fails against WPA2/WPA3 transition-mode access points and reports the password as wrong (brcmfmac feature_disable=0x82000).";
          };
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
          asus_zenbook_ux5406aa.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "ASUS Zenbook UX5406AA Panther Lake / Xe3 display backlight fix (xe.enable_dpcd_backlight=1).";
          };
          intel_ptl_fred.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Intel Panther Lake Flexible Return and Event Delivery (fred=on kernel parameter).";
          };
          intel_ptl_video_accel.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Intel Panther Lake (and modern HD/UHD/Iris/Xe/Arc) hardware video acceleration via intel-media-driver + libvpl + vpl-gpu-rt.";
          };
          intel_ptl_sof_firmware.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Install Sound Open Firmware for the audio DSP on non-XPS Intel Panther Lake systems (mainline kernel only optdeps it).";
          };
          lenovo_yoga_pro7_bass.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Lenovo Yoga Pro 7 14IAH10: route audio to the AMP bass speakers via the alc287-yoga9-bass-spk-pin model quirk on snd-sof-intel-hda-generic.";
          };
        };
      };
      default = {};
      description = "Hardware-specific workarounds (off by default; enable per machine).";
    };
  };
}
