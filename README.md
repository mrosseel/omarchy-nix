<p align="center">
  <img src="omanix.png" alt="Omanix" width="600">
</p>

<h3 align="center">A faithful NixOS port of <a href="https://github.com/basecamp/omarchy">Omarchy</a></h3>

---

## Philosophy

[Omarchy](https://omarchy.org) is DHH's beautiful, modern, and opinionated Hyprland desktop environment built for Arch Linux. Omanix brings that same experience to NixOS with one guiding principle: **stay as close to Omarchy as possible**.

This is a port, not a reimagining. When Omarchy evolves, Omanix follows.

- **Same look and feel** — identical themes, wallpapers, keybindings, and UI behavior
- **Same scripts** — utility scripts ported with the same names and logic, adapted only where Nix demands it
- **Same workflow** — if it works a certain way in Omarchy, it works the same way here
- **Nix where it matters** — declarative configuration, reproducible builds, and atomic rollbacks without changing the user experience

Deviations from Omarchy are made only when technically unavoidable and are always documented.

---

## Features

- 13 color themes with automatic light/dark mode switching
- Hyprland Wayland compositor with smart focus-or-launch behavior
- Ghostty, Alacritty, and Kitty terminal support (all fully themed)
- Walker app launcher, waybar status bar, mako notifications
- Neovim and VSCode integration
- Docker, lazygit, and modern dev tooling
- Webapp desktop integration — turn websites into apps
- Optional NVIDIA, gaming, and FIDO2 support
- Battery monitoring, restart utilities, and system helpers

---

## Quick Start

### Prerequisites
1. Fresh [NixOS](https://nixos.org/) installation
2. [Home Manager](https://github.com/nix-community/home-manager) configured

### Installation

Add this flake to your NixOS configuration:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    omarchy-nix = {
      url = "github:henrysipp/omarchy-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, omarchy-nix, home-manager, ... }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      modules = [
        omarchy-nix.nixosModules.default
        home-manager.nixosModules.home-manager

        {
          omarchy = {
            username = "your-username";
            full_name = "Your Name";
            email_address = "your.email@example.com";
            theme = "tokyo-night";
          };

          home-manager.users.your-username = {
            imports = [ omarchy-nix.homeManagerModules.default ];
          };
        }
      ];
    };
  };
}
```

Then rebuild your system:
```bash
sudo nixos-rebuild switch --flake .
```

---

## Configuration Options

### Required Options

```nix
omarchy = {
  username = "your-username";
  full_name = "Your Name";
  email_address = "you@email.com";
  theme = "tokyo-night";
};
```

### Theme Options

**Available themes:**
- `tokyo-night` (default) - Popular dark theme
- `kanagawa` - Calm dark theme inspired by Japanese art
- `everforest` - Comfortable green dark theme
- `catppuccin` - Soothing pastel dark theme
- `catppuccin-latte` - Light variant of Catppuccin
- `rose-pine` - Soho vibes dark theme
- `rose-pine-dawn` - Light variant
- `rose-pine-moon` - Darker variant
- `nord` - Arctic blue theme
- `gruvbox` - Retro groove dark theme
- `gruvbox-light` - Light variant
- `flexoki-light` - Warm, analog-inspired light theme
- `matte-black` - Ultra-dark minimalist theme

**Light theme auto-detection:**
```nix
omarchy.light_theme_detection = {
  enable = true;
  light_theme_mappings = {
    "tokyo-night" = "catppuccin-latte";
    "kanagawa" = "rose-pine-dawn";
  };
};
```

Create `~/.config/omarchy/theme/light.mode` to enable light mode temporarily.

### Display Configuration

```nix
omarchy = {
  monitors = [
    "eDP-1,preferred,auto,2"
    "HDMI-A-1,1920x1080,auto,1"
  ];
  scale = 2;
  primary_font = "Liberation Sans 11";
};
```

### Application Choices

```nix
omarchy = {
  browser = "chromium";  # or "brave"
  terminal = "ghostty";  # or "alacritty", "kitty"
};
```

### Optional Features

#### Gaming Support
```nix
omarchy.gaming.enable = true;
```
Includes Steam, Proton-GE, GameMode, MangoHud, and controller support.

#### NVIDIA GPU Support
```nix
omarchy.nvidia.enable = true;
```
Includes proprietary drivers, Wayland optimizations, and VA-API acceleration.

#### Seamless Boot
```nix
omarchy.seamless_boot = {
  enable = true;
  username = "your-username";
  plymouth_theme = "omarchy";
  silent_boot = true;
};
```

#### FIDO2 Authentication
```nix
omarchy.fido2_auth = {
  enable = true;
  sudo_auth = true;
  fingerprint_support = false;
};
```

#### Firewall Configuration
```nix
omarchy.firewall = {
  enable = true;
  use_ufw = true;
  docker_protection = true;
  allow_ssh = false;
  allow_dev_ports = true;
};
```

#### Office Suite
```nix
omarchy.office_suite.enable = true;
```

---

## Default Keybindings

### Applications
- `SUPER + SPACE` - App launcher (walker)
- `SUPER + RETURN` - Terminal
- `SUPER + B` - Browser
- `SUPER + F` - File manager (Nautilus)
- `SUPER + M` - Music (Spotify)
- `SUPER + O` - Obsidian
- `SUPER + /` - Password manager (1Password)
- `SUPER + R` - Calculator
- `SUPER + ;` - Audio device switcher

### Webapps (Focus-or-Launch)
- `SUPER + A` - ChatGPT
- `SUPER + SHIFT + A` - Grok
- `SUPER + C` - Calendar (Hey)
- `SUPER + E` - Email (Hey)
- `SUPER + Y` - YouTube
- `SUPER + X` - X/Twitter
- `SUPER + SHIFT + G` - WhatsApp Web

### Window Management
- `SUPER + W` - Close window
- `SUPER + V` - Toggle floating
- `SUPER + J` - Toggle split
- `SUPER + Arrow Keys` - Move focus
- `SUPER + SHIFT + Arrow Keys` - Swap windows
- `SUPER + 1-9` - Switch workspace
- `SUPER + SHIFT + 1-9` - Move to workspace

### Screenshots & Recording
- `PRINT` - Region screenshot (with satty editor)
- `SHIFT + PRINT` - Window screenshot
- `CTRL + PRINT` - Full screen screenshot
- `ALT + PRINT` - Color picker
- `SUPER + PRINT` - Start/stop screen recording

### System
- `SUPER + ESCAPE` - Lock screen
- `SUPER + SHIFT + ESCAPE` - Exit Hyprland
- `SUPER + CTRL + ESCAPE` - Reboot
- `SUPER + SHIFT + CTRL + ESCAPE` - Shutdown
- `SUPER + K` - Show keybindings
- `SUPER + L` - Learn menu
- `SUPER + CTRL + SPACE` - Next background
- `SUPER + SHIFT + SPACE` - Toggle waybar

---

## Utility Scripts

All scripts are available in `~/.local/share/omarchy/bin/`:

```bash
# Restart utilities
omarchy-restart-wifi
omarchy-restart-bluetooth
omarchy-restart-pipewire
omarchy-restart-waybar
omarchy-restart-walker

# Webapp management
omarchy-webapp-install Gmail https://mail.google.com <icon-url>
omarchy-webapp-remove Gmail
omarchy-launch-or-focus-webapp gmail https://mail.google.com

# Docker databases
omarchy-docker-dbs postgres redis mysql mongodb

# Theme & display
omarchy-bg-next
omarchy-theme-picker
omarchy-toggle-light-mode
omarchy-show-keybindings
```

---

## Troubleshooting

```bash
# Check flake syntax
nix flake check

# Rebuild system
sudo nixos-rebuild switch --flake .

# Rebuild home-manager
home-manager switch --flake .

# Check systemd services
systemctl --user status omarchy-battery-monitor

# Common fixes
omarchy-restart-wifi        # WiFi not connecting
omarchy-restart-pipewire    # No audio
omarchy-restart-waybar      # Waybar frozen
omarchy-restart-bluetooth   # Bluetooth issues
```

---

## Credits

- Original [Omarchy](https://github.com/basecamp/omarchy) by [DHH](https://github.com/dhh)
- NixOS port by [henrysipp](https://github.com/henrysipp)

## License

MIT License — same as the original Omarchy project.
