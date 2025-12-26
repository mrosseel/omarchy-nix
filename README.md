# Omarchy Nix

Omarchy-nix is an opinionated NixOS flake for a beautiful, modern Hyprland desktop setup. It's a reimplementation of [DHH's Omarchy](https://github.com/basecamp/omarchy) using NixOS instead of Arch Linux, designed for modern web development and productivity.

## Features

- 🎨 **13 beautiful themes** with automatic light/dark mode switching
- 🚀 **Smart app launching** with focus-or-launch behavior
- 🖥️ **3 terminal emulators** (ghostty, alacritty, kitty) - all fully themed
- 🎮 **Gaming support** with Steam, Proton, GameMode, and controller support (optional)
- 🖥️ **NVIDIA GPU support** with Wayland optimizations (optional)
- 📱 **Webapp desktop integration** - turn websites into apps
- 🔧 **20+ utility scripts** for common tasks
- 🔋 **Battery monitoring** with low battery alerts
- 🎯 **Launch-or-focus** for all major apps
- 📦 **Docker database helpers** for quick dev setup
- 🛠️ **Restart utilities** for WiFi, Bluetooth, Audio, etc.

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
          # Required configuration
          omarchy = {
            full_name = "Your Name";
            email_address = "your.email@example.com";
            theme = "tokyo-night";
          };

          # Home Manager integration
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
  full_name = "Your Name";        # Used for git configuration
  email_address = "you@email.com"; # Used for git configuration
  theme = "tokyo-night";           # See available themes below
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
  enable = true;  # Default: true
  light_theme_mappings = {
    "tokyo-night" = "catppuccin-latte";
    "kanagawa" = "rose-pine-dawn";
    # ... customize mappings
  };
};
```

Create `~/.config/omarchy/theme/light.mode` to enable light mode temporarily.

### Display Configuration

```nix
omarchy = {
  monitors = [
    "eDP-1,preferred,auto,2"  # Laptop screen, 2x scaling
    "HDMI-A-1,1920x1080,auto,1"  # External monitor, 1x scaling
  ];
  scale = 2;  # Default scale factor (1 or 2)
  primary_font = "Liberation Sans 11";  # System font
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

#### Office Suite
```nix
omarchy.office_suite.enable = true;  # Installs LibreOffice
```

#### Gaming Support
```nix
omarchy.gaming.enable = true;  # Enables Steam, Proton, GameMode
```

Includes:
- Steam with Proton for Windows games
- Proton-GE for better compatibility
- GameMode for performance optimizations
- MangoHud for FPS overlay
- 32-bit library support
- Xbox, PlayStation, and Nintendo controller support

#### NVIDIA GPU Support
```nix
omarchy.nvidia.enable = true;  # Enables NVIDIA proprietary drivers
```

Includes:
- NVIDIA proprietary drivers (stable branch)
- Wayland + Hyprland optimizations
- Hardware cursor fixes for Wayland
- VA-API video acceleration support
- GPU monitoring with nvtop

**Note**: Only enable if you have an NVIDIA GPU. Disabled by default.

#### Seamless Boot
```nix
omarchy.seamless_boot = {
  enable = true;
  username = "your-username";  # Required for auto-login
  plymouth_theme = "omarchy";   # Boot splash theme
  silent_boot = true;           # Hide kernel messages
};
```

Provides smooth boot-to-desktop with Plymouth splash screen and auto-login.

#### FIDO2 Authentication
```nix
omarchy.fido2_auth = {
  enable = true;
  sudo_auth = true;           # Use FIDO2 for sudo
  fingerprint_support = false; # Enable fingerprint reader
};
```

#### Firewall Configuration
```nix
omarchy.firewall = {
  enable = true;               # Default: true
  use_ufw = true;              # Use UFW for easier management
  docker_protection = true;    # Protect Docker containers
  allow_ssh = false;           # Allow SSH connections
  allow_dev_ports = true;      # Allow ports 3000, 4000, 5000, 8000, 8080, 9000
  allowed_tcp_ports = [];      # Additional TCP ports
  allowed_udp_ports = [];      # Additional UDP ports
};
```

### Keybindings Customization

```nix
omarchy.quick_app_bindings = [
  "SUPER, A, exec, ~/.local/share/omarchy/bin/omarchy-launch-or-focus-webapp chatgpt https://chatgpt.com"
  "SUPER, B, exec, $browser"
  "SUPER, return, exec, $terminal"
  # Add your custom bindings...
];
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
- `SUPER + SHIFT + PRINT` - Start/stop screen recording
- `SUPER + CTRL + PRINT` - Start/stop screen recording

### System
- `SUPER + ESCAPE` - Lock screen
- `SUPER + SHIFT + ESCAPE` - Exit Hyprland
- `SUPER + CTRL + ESCAPE` - Reboot
- `SUPER + SHIFT + CTRL + ESCAPE` - Shutdown
- `SUPER + K` - Show keybindings
- `SUPER + SHIFT + K` - Open documentation
- `SUPER + CTRL + SPACE` - Next background
- `SUPER + SHIFT + SPACE` - Toggle waybar

---

## Utility Scripts

All scripts are available in `~/.local/share/omarchy/bin/`:

### Restart Utilities
Quick fixes without rebooting:
```bash
omarchy-restart-wifi       # Restart WiFi connection
omarchy-restart-bluetooth  # Restart Bluetooth
omarchy-restart-pipewire   # Restart audio system
omarchy-restart-waybar     # Restart status bar
omarchy-restart-walker     # Restart app launcher
```

### Webapp Management
```bash
# Install a webapp as desktop app
omarchy-webapp-install Gmail https://mail.google.com <icon-url>

# Remove installed webapps
omarchy-webapp-remove Gmail Notion

# Launch webapps with focus-or-launch
omarchy-launch-or-focus-webapp gmail https://mail.google.com
```

### Development Tools
```bash
# Quick database setup with Docker
omarchy-docker-dbs postgres redis    # Install PostgreSQL & Redis
omarchy-docker-dbs mysql             # Install MySQL
omarchy-docker-dbs mongodb           # Install MongoDB

# Databases available:
# mysql, postgres, mariadb, redis, mongodb, mssql
```

### System Utilities
```bash
# Audio device switching
omarchy-audio-switch  # Cycle through audio outputs

# Screen recording (GPU accelerated)
omarchy-screenrecord  # Toggle recording on/off

# Battery monitoring (runs automatically)
omarchy-battery-monitor  # Low battery notifications

# Launch or focus apps
omarchy-launch-or-focus obsidian "obsidian --disable-gpu"
omarchy-launch-or-focus firefox firefox
```

### Theme & Display
```bash
# Background switcher (for current theme)
omarchy-bg-next

# Theme picker
omarchy-theme-picker

# Light/dark mode toggle
omarchy-toggle-light-mode

# Apply current theme to browser
omarchy-theme-set-browser

# Show keybindings
omarchy-show-keybindings
```

### Setup & Configuration
```bash
# Interactive timezone selector
omarchy-tz-select

# Tailscale VPN setup helper
omarchy-install-tailscale

# FIDO2 fingerprint setup
omarchy-setup-fingerprint

# Open documentation in browser
omarchy-launch-docs
```

---

## Tips & Tricks

### Install Custom Webapps

Turn any website into a desktop app:

```bash
omarchy-webapp-install Notion https://notion.so \
  https://upload.wikimedia.org/wikipedia/commons/4/45/Notion_app_logo.png

omarchy-webapp-install Figma https://figma.com \
  https://static.figma.com/app/icon/1/favicon.png
```

Then launch with `SUPER + SPACE` → type app name.

### Quick Database Setup for Development

```bash
# Start PostgreSQL and Redis for your Rails app
omarchy-docker-dbs postgres redis

# Check running databases
docker ps

# Connect to PostgreSQL
psql -h localhost -U postgres
```

### Fix Common Issues

```bash
# WiFi not connecting?
omarchy-restart-wifi

# No audio?
omarchy-restart-pipewire

# Waybar frozen?
omarchy-restart-waybar

# Bluetooth device not pairing?
omarchy-restart-bluetooth
```

### Gaming Setup

Enable gaming support in your config:
```nix
omarchy.gaming.enable = true;
```

Then:
1. Rebuild: `sudo nixos-rebuild switch --flake .`
2. Launch Steam
3. Enable Proton: Settings → Compatibility → Enable Steam Play for all titles
4. Install and play games!

**Pro tip**: Add MangoHud overlay to see FPS:
```
mangohud %command%
# (in Steam game launch options)
```

### Battery Optimization

The battery monitor runs automatically and notifies you:
- At 20% battery (low warning)
- At 10% battery (critical alert)

Customize thresholds by editing `~/.local/share/omarchy/bin/omarchy-battery-monitor`.

### Light Mode Switching

Toggle between light and dark themes:
```bash
omarchy-toggle-light-mode
```

Or create the file manually:
```bash
# Enable light mode
mkdir -p ~/.config/omarchy/theme
touch ~/.config/omarchy/theme/light.mode

# Disable light mode
rm ~/.config/omarchy/theme/light.mode
```

---

## Included Applications

### Essential Tools
- **Terminals**: ghostty, alacritty, kitty
- **Browser**: chromium or brave (configurable)
- **File Manager**: Nautilus
- **Calculator**: gnome-calculator
- **PDF Viewer**: evince
- **Image Viewer**: loupe

### Creative & Productivity
- **Image Editor**: krita
- **PDF Annotation**: xournalpp
- **Notes**: Obsidian
- **Office Suite**: LibreOffice (optional)

### Development
- **Editors**: VSCode, Neovim
- **Version Control**: git, lazygit, GitHub Desktop
- **Containers**: Docker, docker-compose, lazydocker
- **Shell**: zsh with starship prompt, fzf, zoxide

### Media & Production
- **Music**: Spotify
- **Video**: VLC, mpv
- **Screen Recording**: OBS Studio, gpu-screen-recorder
- **Video Editing**: Kdenlive
- **Screenshot Editing**: satty

### Communication
- **Password Manager**: 1Password
- **Messaging**: Signal Desktop
- **File Sharing**: LocalSend (local network file transfer)
- **Webapps**: Custom installation support

### System Monitoring & Utilities
- **Process Monitor**: btop
- **Audio Mixer**: wiremix, pavucontrol
- **Bluetooth**: bluetui
- **System Info**: inxi
- **Clipboard**: clipse
- **Status Bar**: waybar
- **App Launcher**: walker
- **Shell Prompts**: gum (interactive TUI components)

---

## Comparison with Original Omarchy

### What's Included ✅
- All essential desktop applications
- Complete theming system
- Launch-or-focus behavior
- Webapp integration
- Battery monitoring
- Restart utilities
- Gaming support
- Development tools

### NixOS Advantages ✅
- Declarative configuration
- Atomic upgrades
- Rollback capability
- Reproducible builds
- No package conflicts

### Different Approach
- **Original**: Runtime scripts modify configs
- **Nix Port**: Declarative configuration rebuilds
- **Original**: ~100+ utility scripts
- **Nix Port**: 16 essential utilities (Nix handles the rest)

---

## Troubleshooting

### Build Errors

```bash
# Check flake syntax
nix flake check

# Evaluate modules
nix eval .#nixosModules.default
nix eval .#homeManagerModules.default
```

### Service Issues

```bash
# Check systemd services
systemctl --user status omarchy-battery-monitor

# Restart services
systemctl --user restart omarchy-battery-monitor
```

### Theme Not Applying

```bash
# Rebuild home-manager
home-manager switch --flake .

# Check color scheme
echo $colorScheme
```

---

## Contributing

This project welcomes contributions! Feel free to:
- Report issues
- Submit pull requests
- Suggest new features
- Share your configuration

---

## Credits

- Original concept by [DHH's Omarchy](https://github.com/basecamp/omarchy)
- NixOS port by [henrysipp](https://github.com/henrysipp)
- Additional features and enhancements contributed by the community

---

## License

MIT License - Same as the original Omarchy project.
