# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Omarchy-nix is a NixOS flake that provides an opinionated Hyprland desktop setup for modern web development, based on DHH's Omarchy project. It's a reimplementation using Nix instead of Arch Linux.

## Architecture

### Core Structure

The flake provides two main modules:
- **nixosModules.default**: System-level configuration for NixOS
- **homeManagerModules.default**: User-level configuration via Home Manager

### Module System

**NixOS Modules** (`modules/nixos/`):
- `hyprland.nix`: Hyprland window manager configuration
- `system.nix`: Core system packages and services
- `1password.nix`: 1Password integration
- `containers.nix`: Docker/container support

**Home Manager Modules** (`modules/home-manager/`):
- Application configurations for: btop, ghostty, git, hyprland, hyprlock, hyprpaper, hypridle, mako, vscode, waybar, wofi, zoxide, zsh
- Each module handles specific application configuration and theming

### Configuration System

**Main Configuration** (`config.nix`):
- Defines all user-configurable options using NixOS module system
- Key options: `full_name`, `email_address`, `theme`, `monitors`, `scale`, `quick_app_bindings`
- Theme options: tokyo-night, kanagawa, everforest, catppuccin, catppuccin-latte, nord, gruvbox, gruvbox-light
- **NEW: Seamless Boot**: `seamless_boot.enable`, `seamless_boot.username`, `seamless_boot.plymouth_theme`, `seamless_boot.silent_boot`

**Theming** (`modules/themes.nix`):
- Maps theme names to base16 color schemes and VSCode themes
- Integrates with nix-colors for consistent theming across applications

**Package Management** (`modules/packages.nix`):
- Separates system packages from home packages
- Includes development tools, shell utilities, GUI applications
- **NEW v1.6.0**: walker (app launcher), satty (screenshot editor), wf-recorder (screen recording), wiremix (audio TUI), swaybg (dynamic backgrounds)

## Common Development Tasks

### Building and Testing

Since this is a NixOS flake, use standard Nix commands:

```bash
# Check flake syntax and build
nix flake check

# Build the flake
nix build

# Test configuration (dry-run)
nixos-rebuild dry-build --flake .

# Apply configuration (for local testing)
nixos-rebuild switch --flake .
```

### Seamless Boot Configuration

**Enable seamless boot experience** (similar to original Omarchy):
```nix
omarchy.seamless_boot = {
  enable = true;              # Enable Plymouth + auto-login
  username = "your-username"; # Required for auto-login
  plymouth_theme = "omarchy"; # Custom boot splash theme
  silent_boot = true;         # Hide kernel messages
};
```

**Features provided:**
- Plymouth boot splash with Omarchy theme
- Silent boot (no kernel messages)
- Auto-login via greetd + UWSM
- Seamless boot-to-desktop transition
- No visible terminal or login prompts

**Technical implementation:**
- Uses NixOS built-in Plymouth module
- Leverages programs.hyprland.withUWSM for session management
- Configures greetd for auto-login
- Applies silent boot kernel parameters

### Code Formatting

```bash
# Format Nix files using alejandra (included in packages)
alejandra .
```

### Development Workflow

1. Modify configuration options in `config.nix` for new features
2. Add module implementations in appropriate `modules/` subdirectory
3. Import new modules in the relevant `default.nix` file
4. Test changes with `nix flake check`
5. Update theme mappings in `modules/themes.nix` if adding themes

### Hyprland Configuration

Hyprland config is split across multiple files in `modules/home-manager/hyprland/`:
- `bindings.nix`: Keybindings and quick app launcher shortcuts
- `configuration.nix`: Main Hyprland settings
- `windows.nix`: Window rules and behavior
- `looknfeel.nix`: Visual appearance and theming
- `input.nix`: Input device configuration

### Utility Scripts

The `bin/` directory contains utility scripts that get installed to user's PATH:
- `omarchy-show-keybindings`: Interactive keybinding reference using walker

### Key Files for Common Modifications

- **Adding new packages**: `modules/packages.nix`
- **Adding new themes**: `modules/themes.nix` and `config.nix`
- **Modifying keybindings**: `modules/home-manager/hyprland/bindings.nix`
- **Adding quick app shortcuts**: Modify `quick_app_bindings` in user configuration
- **Adding new applications**: Create new module in `modules/home-manager/`
- **System services**: Add to `modules/nixos/`

### New Features (v1.6.0 Compatibility)

**Enhanced Screenshots & Recording**:
- `PRINT`: Region screenshot with satty editor
- `SHIFT + PRINT`: Window screenshot with satty editor  
- `CTRL + PRINT`: Full screen screenshot with satty editor
- `SUPER + PRINT`: Record screen region
- `SUPER + SHIFT + PRINT`: Record full screen
- `SUPER + CTRL + PRINT`: Stop recording
- `ALT + PRINT`: Color picker

**App Launcher**:
- `SPACE`: Walker launcher with apps, calculator (=), and emojis (:)

**Background Switching**:
- `SUPER + CTRL + SPACE`: Cycle through backgrounds for current theme

**Audio Management**:
- `SUPER + SHIFT + M`: Open wiremix audio TUI

## Dependencies

Core inputs defined in `flake.nix`:
- `nixpkgs`: Main package repository (nixos-unstable)
- `hyprland`: Hyprland compositor from upstream
- `nix-colors`: Base16 color scheme integration
- `home-manager`: User configuration management

The flake expects to be used alongside a user's existing NixOS configuration with Home Manager integration.