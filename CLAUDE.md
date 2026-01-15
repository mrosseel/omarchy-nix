# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Omarchy-nix is a NixOS flake that provides an opinionated Hyprland desktop setup for modern web development, based on DHH's Omarchy project. It's a reimplementation using Nix instead of Arch Linux.

## Project Context: Porting from Omarchy to Omarchy-Nix

### Active Porting Project

**CRITICAL**: This is an **active porting project**, not a standalone implementation. We are porting the original Omarchy (Arch Linux) to Omarchy-Nix (NixOS).

**Original Omarchy location**: `/home/mike/dev/omarchy`
**Omarchy-Nix location**: `/home/mike/dev/omarchy-nix`

**Both projects must remain in scope during development work.** Always keep the original Omarchy repository accessible for reference, comparison, and asset copying.

### Porting Principles (CRITICAL - READ CAREFULLY)

These principles are **mandatory** and override general best practices when there's a conflict:

1. **Stay as close as possible to Omarchy**
   - Mirror the original implementation unless absolutely necessary to deviate
   - Preserve the same user experience, behavior, and functionality
   - When in doubt, **err on the side of Omarchy**

2. **Script Fidelity**
   - **Same script names**: Use identical names as in Omarchy (`bin/` directory)
   - **Same script code**: Copy and adapt the original script code, preserving logic and behavior
   - **Only deviate when absolutely necessary** for Nix conformance (e.g., hardcoded paths → Nix store paths)
   - Scripts location: Omarchy `bin/` → Omarchy-Nix `bin/` → deployed to `~/.local/share/omarchy/bin/`

3. **Keybindings**
   - **Exact same keybindings** - nothing more, nothing less
   - Match Omarchy's Hyprland configuration exactly
   - Reference: Omarchy `config/hypr/` vs Omarchy-Nix `modules/home-manager/hyprland/bindings.nix`

4. **Themes**
   - **Exact same themes** as Omarchy
   - Copy theme definitions from Omarchy and interpret them for Nix/base16
   - Reference: Omarchy `config/theme/` vs Omarchy-Nix `modules/themes.nix` + `modules/custom-base16-schemes.nix`

5. **Backgrounds & Assets**
   - **Exact same backgrounds** as Omarchy
   - **Reuse assets** as much as possible (copy from Omarchy)
   - Copy backgrounds, icons, branding materials directly from Omarchy
   - Reference: Omarchy `default/` → Omarchy-Nix `default/`

6. **When Uncertain**
   - **ASK** which approach to take before implementing
   - Present options: "Omarchy does X, but Nix typically does Y. Which approach?"
   - Default bias: Follow Omarchy unless there's a compelling technical reason not to

7. **Nix vs Omarchy Standards**
   - Nix standards are important, but **Omarchy fidelity takes precedence**
   - Acceptable Nix adaptations:
     - Hardcoded paths → Nix store paths / home.file deployments
     - Package installation → Nix packages list
     - Systemd service definitions → NixOS module format
   - Avoid Nix-specific "improvements" that deviate from Omarchy's behavior

### Comparison Workflow

When implementing features:

1. **Check Omarchy first**: Look at the original implementation in `/home/mike/dev/omarchy`
2. **Understand the behavior**: What does it do? How does it work?
3. **Port faithfully**: Adapt for Nix while preserving behavior
4. **Test against Omarchy**: Does it behave the same way?
5. **Document differences**: If you must deviate, document why in code comments

### Omarchy Sync Status

**Last synced Omarchy commit**: `53b8fc42` (origin/dev branch)
**Omarchy repository**: `https://github.com/basecamp/omarchy.git`
**Last sync date**: January 13, 2026
**Sync notes**: Synced with Omarchy v3.3.3 (dev branch). Voxtype voice dictation ported:
- ✅ Voxtype voice dictation feature (hold Super+Ctrl+X to dictate)
- ✅ Custom voxtype package (v0.4.13) in packages/voxtype.nix
- ✅ Optional feature via omarchy.voxtype.enable
- ✅ Waybar integration with recording indicator
- ✅ Scripts: omarchy-voxtype-status, omarchy-voxtype-config, omarchy-voxtype-model
- ✅ Also added omarchy-cmd-present helper script
- ✅ NoIdle cleanup after update (commit 65 - e44e9372)
- ✅ Screensaver mouse tracking removed (commit 58 - d2ea6ad1)
- ✅ Audio/Bluetooth keybindings added (commits 60-62 - dae89574, ca8f25fb, c59089e9)
- ✅ Created omarchy-launch-tui script
- ✅ Fixed omarchy-launch-bluetooth to use omarchy-launch-tui
- ✅ Added SUPER+CTRL+A/B keybindings for audio/bluetooth
- ✅ Moved time/battery notifications to SUPER+CTRL+ALT+T/B

**Branch tracking**: We track the **`dev`** branch (not `master`), as it contains the latest development work

**To check current Omarchy status**:
```bash
cd /home/mike/dev/omarchy
git log --oneline -20
```

### Syncing with Omarchy Upstream

When the user asks to **"sync with Omarchy"**, **"update from Omarchy"**, or **"check for Omarchy changes"**, follow this workflow:

1. **Check commits since last sync**:
   ```bash
   cd /home/mike/dev/omarchy
   git pull origin main
   git log --oneline <LAST_SYNCED_COMMIT>..HEAD
   ```

2. **Analyze each commit**:
   - Read the commit message
   - Check changed files: `git show --stat <commit-hash>`
   - Determine if changes are relevant for Omarchy-Nix

3. **Categorize changes**:
   - **Scripts** (`bin/`): Almost always relevant - port to omarchy-nix/bin/
   - **Configs** (`config/`): Relevant - translate to Nix modules
   - **Assets** (`default/`): Relevant - copy to omarchy-nix/default/
   - **Themes** (`config/theme/`): Relevant - update themes.nix and custom-base16-schemes.nix
   - **Install scripts** (`install/`): May be relevant - check for new packages/dependencies
   - **Documentation** (`README.md`): Review, may need README.md updates
   - **Migrations** (`migrations/`): Analyze - may indicate feature changes that need porting

4. **Present findings to user**:
   - List commits since last sync
   - Highlight relevant changes
   - Ask which changes to port first
   - Suggest priority order

5. **After porting changes**:
   - Update the "Last synced Omarchy commit" above
   - Update the "Last sync date"
   - Add brief notes about what was ported

**Example sync session**:
```
User: "Sync with Omarchy"

Claude:
I found 15 commits in Omarchy since our last sync (commit abc1234).

Relevant changes to port:
1. [commit 1] New omarchy-foo-bar script - adds X functionality
2. [commit 3] Updated theme colors for tokyo-night theme
3. [commit 7] New keybinding for screenshot tool
4. [commit 12] Added new wallpapers for kanagawa theme

Not relevant (Arch-specific):
- [commit 2] Updated pacman package list
- [commit 5] Fixed AUR build issue

Which changes would you like me to port first?
```

### Common Porting Patterns

**Scripts**:
```bash
# Omarchy (bin/omarchy-theme-set)
yay -S --needed $packages

# Omarchy-Nix equivalent
# Packages defined in modules/packages.nix instead
# Script focuses on runtime behavior only
```

**Paths**:
```bash
# Omarchy
~/.local/share/omarchy/bin/omarchy-foo

# Omarchy-Nix (same deployed location, different source)
# Source: omarchy-nix/bin/omarchy-foo
# Deployed: ~/.local/share/omarchy/bin/omarchy-foo (via home.file)
```

**Config files**:
```bash
# Omarchy
~/.config/hypr/hyprland.conf (generated from templates)

# Omarchy-Nix
Generated by modules/home-manager/hyprland/*.nix
Same end result, different generation method
```

## Architecture

### Core Structure

The flake provides two main modules:
- **nixosModules.default**: System-level configuration for NixOS (imported in `flake.nix`)
- **homeManagerModules.default**: User-level configuration via Home Manager (imported in `flake.nix`)

Both modules import their options from `config.nix`, which defines all user-configurable options using the NixOS module system.

### Module System

**NixOS Modules** (`modules/nixos/`):
- `hyprland.nix`: Hyprland window manager system configuration
- `system.nix`: Core system packages and services
- `1password.nix`: 1Password integration
- `containers.nix`: Docker/container support
- `fido2.nix`: FIDO2 authentication support
- `firewall.nix`: Firewall configuration
- `gaming.nix`: Steam, Proton, GameMode, controller support
- `nvidia.nix`: NVIDIA GPU support with Wayland optimizations
- `theme-switcher-sudo.nix`: Sudo permissions for theme switching

**Home Manager Modules** (`modules/home-manager/`):
- Application configurations for: alacritty, battery-monitor, brave, btop, chromium, desktop-entries, direnv, fonts, ghostty, git, hyprland, hyprland-preview-share-picker, hypridle, hyprlock, hyprpaper, hyprsunset, kitty, light-theme-monitor, mako, starship, swaybg, theme-generator, theme-switcher, vscode, walker, waybar, xdph, zoxide, zsh
- `hyprland/` subdirectory contains split Hyprland config: `bindings.nix`, `configuration.nix`, `envs.nix`, `input.nix`, `looknfeel.nix`, `windows.nix`, `autostart.nix`
- `default.nix` orchestrates module imports, light theme detection, and colorScheme selection

### Theming Architecture

**Theme Selection Flow**:
1. User sets `omarchy.theme` in their config
2. `modules/home-manager/default.nix` checks for `~/.config/omarchy/theme/light.mode` file
3. If light mode is enabled and theme has a light mapping, it switches to the light variant
4. Selected theme is looked up in `modules/themes.nix`
5. Color scheme is fetched from either `nix-colors` or `modules/custom-base16-schemes.nix`
6. All application modules receive the colorScheme via `config.colorScheme`

**Custom Themes**:
- Custom base16 schemes (ethereal, hackerman, osaka-jade, ristretto) are defined in `modules/custom-base16-schemes.nix`
- Marked with `custom-scheme = true` in `modules/themes.nix`

**Theme Files**:
- `modules/themes.nix`: Maps theme names to base16 schemes and VSCode themes
- `modules/custom-base16-schemes.nix`: Custom base16 color schemes not in nix-colors
- `modules/home-manager/theme-generator.nix`: Generates theme files for non-Nix applications
- `modules/home-manager/light-theme-monitor.nix`: Systemd service that monitors for light mode changes

### Configuration System

**Main Configuration** (`config.nix`):
- Defines all user-configurable options using NixOS module system
- Required options: `username`, `full_name`, `email_address`, `theme`
- Theme options: tokyo-night, kanagawa, everforest, catppuccin, catppuccin-latte, rose-pine, rose-pine-dawn, rose-pine-moon, nord, gruvbox, gruvbox-light, flexoki-light, matte-black, ethereal, hackerman, osaka-jade, ristretto
- Optional features: `gaming.enable`, `nvidia.enable`, `office_suite.enable`, `seamless_boot.enable`, `fido2_auth.enable`, `firewall.enable`
- Light theme detection: `light_theme_detection.enable`, `light_theme_detection.light_theme_mappings`

**Package Management** (`modules/packages.nix`):
- Separates `systemPackages` (NixOS-level) from `homePackages` (user-level)
- System packages: Basic tools, terminal emulators, media apps
- Home packages: Development tools (VSCode, Neovim, lazygit, GitHub Desktop), creative apps (Krita, Obsidian), communication (Signal, Spotify)

## Common Development Tasks

### Syncing with Omarchy Upstream

**User commands for syncing**:
- "Sync with Omarchy" - Check for new commits and port relevant changes
- "Check Omarchy updates" - Just show what's changed, don't port yet
- "Update from Omarchy commit X" - Sync up to a specific commit
- "What's new in Omarchy since [date]?" - Show changes since a date

See the **"Syncing with Omarchy Upstream"** section above for the detailed workflow.

**After syncing**: Always update the "Omarchy Sync Status" section with the new commit hash and date.

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

**Porting a feature from Omarchy:**
1. **Check Omarchy first**: Locate the feature in `/home/mike/dev/omarchy`
   - Scripts: Check `omarchy/bin/`
   - Configs: Check `omarchy/config/`
   - Assets: Check `omarchy/default/` or `omarchy/config/`
2. **Understand the implementation**: Read the original code, understand its behavior
3. **Port to Omarchy-Nix**:
   - Scripts: Copy to `omarchy-nix/bin/`, adapt paths for Nix
   - Configs: Translate to Nix modules in `modules/home-manager/` or `modules/nixos/`
   - Assets: Copy to `omarchy-nix/default/` or `omarchy-nix/config/`
4. **Test**: `nix flake check` and `nixos-rebuild dry-build --flake .`
5. **Verify behavior matches Omarchy**: Does it work the same way?

**Adding a new feature (not in Omarchy):**
1. **Ask first**: Should this be added to Omarchy too, or is it Nix-specific?
2. Add configuration options to `config.nix` if needed (use `lib.mkOption`)
3. Create module implementation in appropriate `modules/` subdirectory
4. Import new module in the relevant `default.nix` (`modules/nixos/default.nix` or `modules/home-manager/default.nix`)
5. Test changes with `nix flake check`
6. Build and test: `nixos-rebuild dry-build --flake .` or `home-manager build --flake .`

**Testing individual modules:**
```bash
# Evaluate a specific module
nix eval .#nixosModules.default

# Check Home Manager module
nix eval .#homeManagerModules.default

# Build without applying
nixos-rebuild dry-build --flake .
home-manager build --flake .
```

**Working with themes:**
1. Add base16 color scheme to `modules/custom-base16-schemes.nix` (if custom)
2. Add theme mapping to `modules/themes.nix` with `base16-theme` and `vscode-theme` keys
3. Add theme name to enum in `config.nix` (line 17-36)
4. Optionally add light theme mapping in `config.nix` light_theme_detection defaults

### Hyprland Configuration

Hyprland config is split across multiple files in `modules/home-manager/hyprland/`:
- `bindings.nix`: Keybindings and quick app launcher shortcuts
- `configuration.nix`: Main Hyprland settings
- `windows.nix`: Window rules and behavior
- `looknfeel.nix`: Visual appearance and theming
- `input.nix`: Input device configuration

### Utility Scripts

The `bin/` directory contains 40+ utility scripts that get installed to `~/.local/share/omarchy/bin/` and added to PATH:

**Restart utilities**:
- omarchy-restart-wifi, omarchy-restart-bluetooth, omarchy-restart-pipewire, omarchy-restart-hypridle, omarchy-restart-hyprsunset, omarchy-restart-swayosd, omarchy-restart-xcompose, omarchy-restart-app (generic)

**Webapp management**:
- omarchy-webapp-install, omarchy-webapp-remove, omarchy-launch-or-focus-webapp

**Development**:
- omarchy-docker-dbs (quick database setup: postgres, mysql, mariadb, redis, mongodb, mssql)

**System utilities**:
- omarchy-audio-switch, omarchy-battery-monitor, omarchy-launch-or-focus, omarchy-launch-or-focus-tui, omarchy-launch-floating-terminal-with-presentation

**Launcher utilities**:
- omarchy-launch-walker, omarchy-launch-browser, omarchy-launch-audio, omarchy-launch-bluetooth, omarchy-launch-wifi, omarchy-launch-screensaver, omarchy-lock-screen, omarchy-launch-docs

**Screen recording & screensaver**:
- omarchy-screenrecord, omarchy-cmd-screenrecord, omarchy-cmd-screensaver

**Theme & display**:
- omarchy-bg-next, omarchy-theme-picker, omarchy-theme-next, omarchy-theme-set, omarchy-theme-set-browser, omarchy-toggle-light-mode, omarchy-toggle-nightlight, omarchy-theme-menu, omarchy-menu

**Setup & config**:
- omarchy-tz-select (timezone), omarchy-install-tailscale, omarchy-setup-fingerprint

**Reference & updates**:
- omarchy-show-keybindings, omarchy-learn-menu, omarchy-update, omarchy-update-available, omarchy-update-without-idle

**Idle & screensaver**:
- omarchy-toggle-idle, omarchy-toggle-screensaver

All scripts are deployed via `home.file` in `modules/home-manager/default.nix` and automatically added to PATH via `home.sessionPath`.

### Key Files for Common Modifications

**ALWAYS check Omarchy first** at `/home/mike/dev/omarchy` before making changes.

- **Adding/porting scripts**:
  - Omarchy: `/home/mike/dev/omarchy/bin/omarchy-*`
  - Omarchy-Nix: `bin/omarchy-*` (deployed to `~/.local/share/omarchy/bin/`)

- **Adding new packages**:
  - Omarchy: `install/packages.txt` or script that installs packages
  - Omarchy-Nix: `modules/packages.nix` (add to `systemPackages` or `homePackages`)

- **Adding/porting themes**:
  - Omarchy: `/home/mike/dev/omarchy/config/theme/*/theme.conf`
  - Omarchy-Nix:
    1. Add base16 scheme to `modules/custom-base16-schemes.nix` (if not in nix-colors)
    2. Map theme name in `modules/themes.nix`
    3. Add to enum in `config.nix` (line 17-36)

- **Modifying keybindings**:
  - Omarchy: `/home/mike/dev/omarchy/config/hypr/hyprland.conf` (check `bind=` lines)
  - Omarchy-Nix: `modules/home-manager/hyprland/bindings.nix`

- **Adding quick app shortcuts**:
  - Omarchy: Check existing keybindings in `config/hypr/hyprland.conf`
  - Omarchy-Nix: Modify `quick_app_bindings` default in `config.nix` or override in user configuration

- **Adding backgrounds/assets**:
  - Omarchy: `/home/mike/dev/omarchy/default/` (backgrounds, icons, etc.)
  - Omarchy-Nix: `default/` (copy from Omarchy) or `config/` subdirectories

- **Adding new applications**:
  - Omarchy: Check `config/` subdirectories and `autostart/`
  - Omarchy-Nix: Create new module in `modules/home-manager/`, import in `modules/home-manager/default.nix`

- **System services**:
  - Omarchy: Check systemd service files or boot scripts
  - Omarchy-Nix: Add to `modules/nixos/`, import in `modules/nixos/default.nix`

- **Custom packages**:
  - Omarchy-Nix specific: Create in `packages/`, import in `modules/packages.nix` using `pkgs.callPackage`

### Important Implementation Details

**Config Propagation**:
- User sets `omarchy.*` options at NixOS level
- `modules/home-manager/default.nix` syncs NixOS config to Home Manager: `config = lib.mkIf (osConfig ? omarchy) { omarchy = osConfig.omarchy; }`
- This allows Home Manager modules to access the same config

**File Deployment**:
- Utility scripts: `bin/` → `~/.local/share/omarchy/bin/` via `home.file`
- Config resources: `config/branding`, `config/screensaver`, `config/webapp-icons` → `~/.config/omarchy/` via `home.file`

**Wallpaper Management**:
- `lib/selected-wallpaper.nix` handles wallpaper selection logic
- Wallpapers stored in `default/` directory with theme-specific subdirectories
- `swaybg` module uses this for dynamic background switching

**Custom Packages**:
- `packages/plymouth-theme-omarchy.nix`: Custom Plymouth boot theme
- `packages/hyprland-preview-share-picker.nix`: Screen sharing picker for Hyprland

### Default Keybinding Features

**Screenshots & Recording**:
- `PRINT`: Region screenshot with satty editor
- `SHIFT + PRINT`: Window screenshot with satty editor
- `CTRL + PRINT`: Full screen screenshot with satty editor
- `SUPER + PRINT`: Record screen region
- `SUPER + SHIFT + PRINT`: Record full screen
- `SUPER + CTRL + PRINT`: Stop recording
- `ALT + PRINT`: Color picker

**App Launcher**:
- `SUPER + SPACE`: Walker launcher (supports apps, calculator with `=` prefix, emojis with `:` prefix)

**Background Switching**:
- `SUPER + CTRL + SPACE`: Cycle through backgrounds for current theme

**Audio Management**:
- `SUPER + SHIFT + M`: Open wiremix audio TUI

## Dependencies

Core inputs defined in `flake.nix`:
- `nixpkgs`: Main package repository (nixos-unstable)
- `hyprland`: Hyprland compositor from upstream (pinned to v0.52.2)
- `nix-colors`: Base16 color scheme integration
- `home-manager`: User configuration management

The flake expects to be used alongside a user's existing NixOS configuration with Home Manager integration.

## Common Pitfalls & Important Notes

**Porting from Omarchy**:
- **ALWAYS check Omarchy first** before implementing or modifying features
- **Compare behavior**: Does the Nix version behave the same as Omarchy?
- **Preserve script logic**: Don't refactor or "improve" scripts unless necessary
- **Match keybindings exactly**: Use Omarchy's `config/hypr/hyprland.conf` as the source of truth
- **Copy assets directly**: Backgrounds, icons, themes should be identical to Omarchy
- **When in doubt, ask**: Don't assume - present the question to the user
- **Document deviations**: If you must deviate from Omarchy, add a comment explaining why
- **Update sync status**: After porting Omarchy changes, update the "Omarchy Sync Status" section with the latest synced commit hash and date

**Module Configuration**:
- Always access user config via `config.omarchy.*`, not `osConfig.omarchy.*` in Home Manager modules (config is synced automatically)
- When adding new config options, add them to `config.nix` only - do NOT duplicate in module files
- Use `lib.mkIf cfg.<option>.enable` to conditionally enable features

**Theme System**:
- Light mode detection happens at build time by checking for `~/.config/omarchy/theme/light.mode`
- Changes to light mode require running `home-manager switch` to take effect
- Custom themes MUST set `custom-scheme = true` in `modules/themes.nix`
- base16 color variables are accessed via `config.colorScheme.palette.base00` through `base0F`

**Hyprland Configuration**:
- Hyprland is pinned to v0.52.2 to match Omarchy (Arch) version - update carefully
- Environment variables are set in `modules/home-manager/hyprland/envs.nix`
- Keybindings support metadata (description) as 3rd parameter: `"SUPER, B, Browser, exec, $browser"`

**Package Management**:
- System packages (`systemPackages`) require `sudo nixos-rebuild switch`
- Home packages (`homePackages`) can be updated with just `home-manager switch`
- Custom packages must be called with `pkgs.callPackage` in `modules/packages.nix`

**Utility Scripts**:
- Scripts in `bin/` are deployed read-only to `~/.local/share/omarchy/bin/`
- To test script changes locally, edit in `bin/` then rebuild with `home-manager switch`
- Scripts have access to environment variables like `$browser`, `$terminal`, set by Hyprland envs

**File Paths**:
- User config: `~/.config/omarchy/`
- Utility scripts: `~/.local/share/omarchy/bin/`
- Wallpapers: Deployed from `default/` directory
- Theme detection: `~/.config/omarchy/theme/light.mode`