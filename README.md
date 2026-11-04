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

- 25 color themes with automatic light/dark mode switching
- Hyprland Wayland compositor with smart focus-or-launch behavior
- Foot, Ghostty, Alacritty, and Kitty terminal support (all fully themed)
- `omarchy-shell` — one Quickshell instance hosting the bar, menu, notifications,
  OSD, lock screen and polkit agent (Omarchy 4 replaced waybar/walker/mako/swayosd)
- Neovim and VSCode integration
- Docker, lazygit, and modern dev tooling
- Webapp desktop integration — turn websites into apps
- Optional NVIDIA, gaming, FIDO2, and voxtype voice dictation support
- Battery monitoring, restart utilities, and system helpers

---

## Quick Start

### Prerequisites
1. A [NixOS](https://nixos.org/) installation
2. [Home Manager](https://github.com/nix-community/home-manager) configured

### Installation

Add this flake to your NixOS configuration:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    omarchy-nix = {
      url = "github:mrosseel/omarchy-nix";
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
- `tokyo-night` (default)
- `kanagawa`
- `everforest`
- `catppuccin`
- `catppuccin-latte` (light)
- `rose-pine`
- `rose-pine-dawn` (light)
- `rose-pine-moon`
- `nord`
- `gruvbox`
- `gruvbox-light` (light)
- `flexoki-light` (light)
- `matte-black`
- `ethereal`
- `hackerman`
- `jade-horse`
- `ristretto`
- `miasma`
- `vantablack`
- `white` (light)
- `retro-82`
- `lumon`
- `lupine` (light)
- `solitude`
- `last-horizon`
- `starship`

**Light theme auto-detection:**
```nix
omarchy.light_theme_detection = {
  enable = true;  # default
  light_theme_mappings = {
    "tokyo-night" = "catppuccin-latte";
    "kanagawa" = "rose-pine-dawn";
    "everforest" = "gruvbox-light";
    "catppuccin" = "catppuccin-latte";
    "rose-pine" = "rose-pine-dawn";
    "rose-pine-moon" = "rose-pine-dawn";
    "nord" = "gruvbox-light";
    "gruvbox" = "gruvbox-light";
  };
};
```

Create `~/.config/omarchy/theme/light.mode` to switch to light mode.

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
  terminal = "ghostty";  # or "foot", "alacritty", "kitty"
};
```

`foot` is Omarchy 4's own default. It accepts xterm-style `-e`, so the terminal
keybindings work unchanged whichever you pick.

### Shell (Bar)

```nix
omarchy.shell.workspace_count = 10;  # default; 1-20
```

How many workspaces the bar's workspace widget shows. Omarchy binds
`SUPER + 1..0` to the first ten and ships no more, so 10 is the upstream
default. Raising it only teaches the bar to display them — bind the extra
workspaces yourself, for example through
`wayland.windowManager.hyprland.extraConfig`:

```nix
wayland.windowManager.hyprland.extraConfig = ''
  bindd = SUPER, F1, Switch to workspace 11, workspace, 11
  bindd = SUPER SHIFT, F1, Move window to workspace 11, movetoworkspace, 11
'';
```

### Optional Features

#### Gaming Support
```nix
omarchy.gaming.enable = true;
```

#### NVIDIA GPU Support
```nix
omarchy.nvidia.enable = true;
```

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

#### Firewall
```nix
omarchy.firewall = {
  enable = true;  # default
  docker_protection = true;
  allow_ssh = false;
  allow_dev_ports = true;
  allowed_tcp_ports = [];
  allowed_udp_ports = [];
};
```

#### Voice Dictation
```nix
omarchy.voxtype = {
  enable = true;
  config_file = ./my-voxtype.toml;  # optional; seeds ~/.config/voxtype/config.toml
};
```
`SUPER + CTRL + X` toggles dictation; `F9` is push-to-talk (hold to talk).

#### Office Suite
```nix
omarchy.office_suite.enable = true;
```

#### Hardware Workarounds

All off by default — enable only the ones your machine needs.

```nix
omarchy.hardware = {
  apple_brcmfmac_supplicant.enable = false;  # Macs: WPA handshake in wpa_supplicant, not firmware
  asus_b9406.enable = false;                 # ASUS ExpertBook B9406 (Panther Lake / Xe3)
  asus_z13.enable = false;                   # ASUS ROG Flow Z13 (GZ302) detachable touchpad
  asus_zenbook_ux5406aa.enable = false;      # ASUS Zenbook UX5406AA backlight
  intel_ptl_fred.enable = false;             # Intel Panther Lake FRED
  intel_ptl_video_accel.enable = false;      # Intel hardware video acceleration
  intel_ptl_sof_firmware.enable = false;     # Sound Open Firmware for the audio DSP
  lenovo_yoga_pro7_bass.enable = false;      # Lenovo Yoga Pro 7 14IAH10 bass speakers
};
```

---

## Default Keybindings

Press `SUPER + K` for the live list — it is generated from the bindings actually
loaded, including any you add yourself, so it never goes stale the way this
table can.

### Menus & Launchers
- `SUPER + SPACE` - Omarchy menu
- `SUPER ALT + SPACE` - Apps menu
- `SUPER + ESCAPE` - System menu
- `SUPER CTRL + E` - Emojis
- `SUPER CTRL + C` - Capture menu
- `SUPER CTRL + O` - Toggle menu
- `SUPER CTRL + H` - Hardware menu
- `SUPER + K` - Keybindings
- `SUPER ALT + K` - Tmux keybindings
- `SUPER CTRL + K` - Herdr keybindings
- `SUPER CTRL + Q` - Calculator

### Webapps (Focus-or-Launch)
- `SUPER SHIFT + A` - ChatGPT
- `SUPER SHIFT ALT + A` - Grok
- `SUPER SHIFT + C` - Calendar (Hey)
- `SUPER SHIFT + E` - Email (Hey)
- `SUPER SHIFT ALT + E` - New email
- `SUPER SHIFT + Y` - YouTube
- `SUPER SHIFT + X` - X
- `SUPER SHIFT ALT + X` - Compose post on X
- `SUPER SHIFT ALT + G` - WhatsApp
- `SUPER SHIFT + P` - Google Photos
- `SUPER SHIFT + S` - Google Maps

### Core Apps
- `SUPER + RETURN` - Terminal
- `SUPER ALT + RETURN` - Tmux
- `SUPER CTRL + RETURN` - Herdr
- `SUPER SHIFT + RETURN` - Browser
- `SUPER SHIFT + B` - Browser
- `SUPER SHIFT ALT + B` - Browser (private)
- `SUPER SHIFT + F` - File manager
- `SUPER SHIFT ALT + F` - File manager (cwd)
- `SUPER SHIFT + N` - Editor
- `SUPER SHIFT + M` - Music
- `SUPER SHIFT ALT + M` - Music TUI
- `SUPER SHIFT + D` - Docker
- `SUPER SHIFT + T` - btop
- `SUPER SHIFT + I` - Messenger
- `SUPER SHIFT + G` - Signal
- `SUPER SHIFT + O` - Obsidian
- `SUPER SHIFT + W` - Omawrite
- `SUPER SHIFT + /` - Passwords
- `SUPER SHIFT + R` - Calculator (also `SUPER CTRL + Q` and `XF86Calculator`)

### Window Management
- `SUPER + W` - Close window
- `CTRL ALT + DELETE` - Close all windows
- `SUPER + T` - Toggle floating/tiling
- `SUPER + J` - Toggle window split
- `SUPER + L` - Toggle workspace layout
- `SUPER + F` - Full screen
- `SUPER CTRL + F` - Tiled full screen
- `SUPER ALT + F` - Full width
- `SUPER + O` - Pop window out (float & pin)
- `SUPER + P` - Pseudo window
- `SUPER + HOME` - Restore window width
- `SUPER ALT + HOME` - Save window width
- `SUPER + Arrow Keys` - Move focus
- `SUPER SHIFT + Arrow Keys` - Swap windows
- `SUPER SHIFT ALT + Arrow Keys` - Move workspace to another monitor
- `SUPER + 1-0` - Switch workspace
- `SUPER SHIFT + 1-0` - Move to workspace
- `SUPER SHIFT ALT + 1-0` - Move to workspace silently
- `SUPER + TAB` - Next workspace
- `SUPER SHIFT + TAB` - Previous workspace
- `SUPER CTRL + TAB` - Former workspace
- `SUPER + S` / `SUPER + \`` - Toggle scratchpad (Quake console)
- `SUPER ALT + S` / `SUPER SHIFT + \`` - Move window to scratchpad
- `SUPER + G` - Toggle window grouping
- `SUPER ALT + G` - Move window out of group
- `SUPER + BACKSPACE` - Toggle window transparency
- `SUPER SHIFT + BACKSPACE` - Toggle window gaps
- `SUPER CTRL + BACKSPACE` - Toggle single-window square aspect
- `SUPER + /` - Monitor scaling up
- `SUPER ALT + /` - Monitor scaling down

### Copy / Paste / Cut
- `SUPER + C` - Universal copy
- `SUPER + V` - Universal paste
- `SUPER + X` - Universal cut
- `SUPER CTRL + V` - Clipboard manager

### Screenshots & Recording
- `PRINT` - Screenshot
- `ALT + PRINT` - Screen recording
- `SUPER + PRINT` - Color picker
- `SUPER CTRL + PRINT` - Extract text (OCR) from screenshot
- `SUPER CTRL + S` - Share
- `SUPER CTRL + .` - Transcode

### Notifications
- `SUPER + ,` - Dismiss last notification
- `SUPER SHIFT + ,` - Dismiss all notifications
- `SUPER CTRL + ,` - Toggle notification silencing
- `SUPER ALT + ,` - Invoke last notification
- `SUPER SHIFT ALT + ,` - Open notification history

### Aesthetics
- `SUPER SHIFT + SPACE` - Toggle top bar
- `SUPER CTRL + SPACE` - Background switcher
- `SUPER SHIFT CTRL + SPACE` - Theme menu

### System
- `SUPER CTRL + A` - Audio
- `SUPER CTRL + B` - Bluetooth
- `SUPER CTRL + W` - Network
- `SUPER CTRL + D` - Display
- `SUPER CTRL + ALT + D` - Calendar
- `SUPER CTRL + P` - Power
- `SUPER CTRL + T` - Activity
- `SUPER CTRL + I` - Toggle locking on idle
- `SUPER CTRL + N` - Toggle nightlight
- `SUPER CTRL + L` - Lock system
- `SUPER CTRL + Z` - Zoom in
- `SUPER CTRL + ALT + Z` - Reset zoom
- `SUPER CTRL + R` - Set reminder
- `SUPER CTRL + Delete` - Toggle laptop display

### Voice Dictation
- `SUPER CTRL + X` - Toggle dictation
- `F9` - Push-to-talk (hold)

---

## Credits

- Original [Omarchy](https://github.com/basecamp/omarchy) by [DHH](https://github.com/dhh)
- NixOS port by [henrysipp](https://github.com/henrysipp)

## License

MIT License — same as the original Omarchy project.
