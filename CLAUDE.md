# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Omarchy-nix is a NixOS flake that provides an opinionated Hyprland desktop setup for modern web development, based on DHH's Omarchy project. It's a reimplementation using Nix instead of Arch Linux.

## Project Context: Porting from Omarchy to Omarchy-Nix

### Active Porting Project

**CRITICAL**: This is an **active porting project**, not a standalone implementation. We are porting the original Omarchy (Arch Linux) to Omarchy-Nix (NixOS).

**Original Omarchy location**: `../omarchy`
**Omarchy-Nix location**: `omarchy-nix`

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

1. **Check Omarchy first**: Look at the original implementation in `../omarchy`
2. **Understand the behavior**: What does it do? How does it work?
3. **Port faithfully**: Adapt for Nix while preserving behavior
4. **Test against Omarchy**: Does it behave the same way?
5. **Document differences**: If you must deviate, document why in code comments

### Omarchy Sync Status

**Last synced Omarchy commit**: `8e031516` (origin/master, v3.8.2)
**Omarchy repository**: `https://github.com/basecamp/omarchy.git`
**Last sync date**: May 28, 2026
**Sync notes**: Synced 170 commits from a3aedb0c..8e031516 (v3.7.1 → v3.8.2). Also bumped Hyprland v0.54.3 → v0.55.2 to fix a screenshare/sessionLock crash and the removed `dwindle.pseudotile` / `-1` gradient config options. Ported:
- ✅ Hyprland 0.55.2 bump + config adjustments (commits 9c8f6cf2, 8e031516): pseudotile removed from `dwindle`, `col.border_locked_*` reuses `${activeBorder}` / `${inactiveBorder}` instead of `-1`. Existing `layoutmsg, togglesplit` binding already in place from prior sync.
- ✅ SDDM Wayland greeter (commits 2cc4a263, 4eb3a919, 5cf83d20, 6f03b728, 25e6fe2e): replaces greetd entirely. New `packages/sddm-theme-omarchy.nix` packages the upstream Main.qml + assets; `services.displayManager.sddm` + `Wayland.CompositorCommand` runs a minimal Hyprland as the greeter compositor; autologin gated by `cfg.seamless_boot.enable`; `defaultSession = "hyprland-uwsm"` so the QML session-pick heuristic works. UWSM + the hyprland-uwsm.desktop override are now unconditional.
- ✅ Hook framework (commits c8f65ccd, fe0ea4de, f0969c67, c9aece1c): `bin/omarchy-hook` runs `<name>` + `<name>.d/*` from `~/.config/omarchy/hooks/`, skipping `*.sample` and not halting on individual failures. `bin/omarchy-hook-install` scaffolds new hooks. Five sample hooks ship under `config/omarchy/hooks/<type>.d/` (battery-low, font-set, post-boot/weather, post-update, theme-set). New `home.activation.seedOmarchyHookSamples` copies samples into the user dir on first activation (never overwrites).
- ✅ System idle/lock refactor (commits dd46e965, ca74b4d1, 4d11f8cc, 90ac2b8c, 6111ee13, 4e4a688f, 080feaf2): `omarchy-system-lock` owns turning off display + keyboard brightness 3s after lock; new `omarchy-system-wake` restores; `omarchy-brightness-display` accepts on/off, `omarchy-brightness-keyboard` accepts off/restore. `hypridle.nix` drops the dedicated dpms listener.
- ✅ Weather widget (commits 6b6d71a9, b10f8116): `bin/omarchy-weather-{icon,status}`, `default/waybar/weather.sh`, waybar `custom/weather` between clock and update; deploy `default/waybar/` to `$OMARCHY_PATH`.
- ✅ Reminders (commit 129c3944): `bin/omarchy-reminder` (set/show/clear) via systemd `--user` transient timers, plus the supporting `bin/omarchy-notification-send` (used by reminders, hooks samples, etc.).
- ✅ Transcoding (commits b8fc1bb6, 7702e837, ec4a3d02, acb2c37b): `bin/omarchy-transcode`, `bin/omarchy-transcode-ascii`, `default/nautilus-python/extensions/transcode.py`, bash fns now thin wrappers around `omarchy-transcode`. Deploy nautilus-python extensions to `~/.local/share/nautilus-python/extensions/` (also picks up the previously-deployed-nowhere `localsend.py`).
- ✅ Voxtype F9 push-to-talk (commit 95ba1c42): adds `bindd ", F9, Start dictation"` + `binddr ", F9, Stop dictation"` to the existing toggle binding. Voxtype install stays declarative on Nix (per package/module).
- ✅ Foot terminal (commit 7debca9f): `modules/home-manager/foot.nix` enables `programs.foot` with the upstream config (theme include from current/theme/foot.ini, JetBrains Mono 9pt, 14x14 pad, Ctrl/Shift+Insert universal clipboard). `bin/omarchy-theme-set-foot` ports the live-recolor OSC injector. `default/foot/{foot.desktop,screensaver.ini}` deployed. `pkgs.foot` added to systemPackages.
- ✅ Default-app abstraction (commit 95d8125e): `bin/omarchy-default-{browser,terminal,editor}` for runtime defaults. Nix deviations: terminal/editor scripts unlink the read-only home-manager symlink before writing; editor seeds `~/.config/uwsm/default` if absent. Install/remove counterparts intentionally skipped (declarative on Nix).
- ✅ Notifications: mako `group-by=app-name,summary,body` (commit 5c3ca608); `omarchy-notification-send` (extracted in 129c3944, used here and by reminders).
- ✅ omarchy-menu refactor (commits 7702e837, acb2c37b, fbc177ba, 37d6e4f9, 99b158cb, 81aaade8): added Reminder + Transcode entries to Trigger, About/Screensaver submenus to Style, Defaults + Security submenus to Setup (Browser/Terminal/Editor with current-state pre-select via omarchy-default-*). New `bin/omarchy-menu-{file,input,select}` walker prompt helpers. `browser_desktop_exists` checks NixOS profile paths (`/etc/profiles/per-user`, `/run/current-system/sw`, `~/.nix-profile`). Install/Remove Arch-installer submenus, drive-password rename, foot-install entry intentionally skipped.
- ✅ Security setup/remove split (commit 45db959d): rename `omarchy-setup-fingerprint`/`-fido2` to `omarchy-setup-security-fingerprint`/`-fido2`; add `omarchy-remove-security-fingerprint`/`-fido2`. All four are Nix-flavored: enrolment-only (no /etc/pam.d edits, no pacman calls); hyprlock.conf symlink materialised to a writable copy before editing. The `omarchy-setup-fido2 -> omarchy-setup-fingerprint` symlink workaround is removed.
- ✅ Branding + state (commits 7702e837, 48859c82, 065b9439, fbc177ba): `bin/omarchy-branding-about`, `bin/omarchy-branding-screensaver`, `bin/omarchy-state`. Deploy `config/branding/icon.txt` next to logo.txt; activation seeds both screensaver.txt and about.txt on first use.
- ✅ Hardware quirks (commits cd30fd09, b3a62245, d1056a27, bc62c233, 402da79f): new omarchy.hardware toggles `asus_zenbook_ux5406aa.enable` (dpcd_backlight), `intel_ptl_video_accel.enable` (intel-media-driver + vpl-gpu-rt), `intel_ptl_sof_firmware.enable` (sof-firmware), `lenovo_yoga_pro7_bass.enable` (snd-sof-intel-hda-generic hda_model quirk). Dell XPS haptic touchpad skipped (no Nix package for dell-xps-touchpad-haptics yet).
- ✅ Theme polish (commits 2a5db9ed, 4dd25423): retro-82 color0/black/selection text moved from `#00172e` to `#303442` (distinct from `#05182e` bg); matte-black selection bg `#333333` → `#515151` (distinct from color0); catppuccin neovim colorscheme renamed `catppuccin` → `catppuccin-nvim` for current LazyVim plugin compat. Helix template tweak skipped (template runtime unported).
- ✅ Bulk re-port of 28 modified bin scripts that had no local divergence at last sync: `omarchy`, `-battery-monitor`, `-brightness-display-apple`, `-capture-{screenshot,screenrecording,text-extraction}`, `-debug`, `-dev-bin-metadata`, `-drive-select`, `-first-run`, `-font-set` (with foot integration), `-hyprland-monitor-{focused-apple,scaling-cycle}`, `-plymouth-{preview,set}`, `-restart-{pipewire,swayosd,trackpad,waybar}`, `-swayosd-{brightness,kbd-brightness}`, `-theme-{bg-set,colors-from-alacritty,refresh}`, `-theme-set-{browser,gnome,obsidian,vscode}`. Targeted merge for `-launch-screensaver` (foot case).
- ✅ Misc small changes: Bluetooth A2DP auto-connect WirePlumber drop-in (commit 9c3520ca); swayosd-server as a systemd user unit instead of an exec-once (commit fa1ed01c) + theme-switcher uses `systemctl restart` instead of pkill+setsid; tmux `extended-keys on`/`csi-u`/`escape-time=10` (commit f2e38aa1); `decoration { rounding=0 }` block in window-no-gaps toggle (commit 22b25991); new `bin/omarchy-cmd-terminal-cwd`. config/chromium-flags.conf VAAPI removal and install/first-run/gtk-primary-paste.sh skipped (not applicable on Nix).

**Remaining gaps from this sync (intentional)**:
- `omarchy-install-{browser,terminal,zed,helix,gaming-retroarch}`, `-remove-{browser,gaming-retroarch}`: Arch-only installers; declarative path on Nix.
- `omarchy-pkg-add` / `omarchy-update-keyring` / `omarchy-reinstall-git` / `omarchy-refresh-applications`: keep prior Nix-deviating stubs; no upstream merge.
- `omarchy-voxtype-install`: relies on `omarchy-pkg-add` + `voxtype setup systemd`; both already covered declaratively.
- `default/themed/helix.toml.tpl`, `omarchy-theme-set-templates`: template runtime still unported (rendered configs live in `config/themes/<theme>/`).
- Migrations (1777929468 et al.): all Arch-side; Nix rebuilds declaratively.
- Dell XPS haptic touchpad (`omarchy-haptic-touchpad`, `dell-xps-touchpad-haptics`): no Nix package yet; not toggleable via `omarchy.hardware`.

**Previous sync** (a3aedb0c, v3.7.1): see git history below for details.

---

**Pre-3.7.1 sync notes** (`a3aedb0c`, May 7, 2026; 318 commits from 236a34b2):
- ✅ Script renames (cmd-screenshot→capture-screenshot, cmd-screenrecord→capture-screenrecording, cmd-screensaver→screensaver, cmd-share→menu-share, cmd-first-run→first-run, cmd-audio-switch→audio-output-switch, lock-screen→system-lock, cmd-mic-mute→audio-input-mute) and references in bin/omarchy-menu, bin/omarchy-launch-screensaver, modules/home-manager/hypridle.nix, modules/home-manager/hyprland/bindings.nix
- ✅ Toggle framework: omarchy-toggle{,-enabled}, omarchy-hyprland-toggle{,-enabled,-disabled}; companion configs default/hypr/toggles/{flags,single-window-aspect-ratio,window-no-gaps}.conf; home.activation seeds ~/.local/state/omarchy/toggles/hypr/
- ✅ Hardware helpers: omarchy-hw-{external-monitors,hybrid-gpu,touchpad,touchscreen,recover-internal-monitor,asus-expertbook-b9406,nvidia-gsp,nvidia-without-gsp,intel-ptl,match}
- ✅ Hyprland monitor scripts: monitor-internal, monitor-internal-mirror, monitor-focused-apple, monitor-watch (autostart entry added)
- ✅ Toggle scripts: omarchy-toggle-touchpad, omarchy-toggle-touchscreen
- ✅ Plymouth scripts (set, set-by-theme, preview, reset) — runtime helpers, full plymouth still managed by packages/plymouth-theme-omarchy.nix
- ✅ New: omarchy CLI wrapper, omarchy-swayosd-client, omarchy-theme-colors-from-alacritty, omarchy-brightness-keyboard-mute, omarchy-capture-text-extraction (OCR), omarchy-dev-{benchmark,bin-metadata}, omarchy-drive-set-password, omarchy-brightness-display-apple, omarchy-hyprland-monitor-focused-apple
- ✅ Bulk re-port of 87 modified shared scripts (battery, brightness, hw-*, drive, font, hibernation, hyprland-window-*, restart-*, theme-*, toggle-*, etc.) — preserved Nix-specific deviations for omarchy-update, omarchy-update-available, omarchy-update-without-idle, omarchy-setup-fingerprint (FIDO2/U2F differs from upstream fprintd flow), omarchy-menu (substantial Nix-specific menu items), omarchy-launch-screensaver (Nix paths), omarchy-webapp-install (Nix icon paths), omarchy-theme-set (Nix theme model), omarchy-install-tailscale (Nix declarative)
- ✅ Hyprland config: clickfinger_behavior=true (two-finger right-click default), removed SDL_VIDEODRIVER (steam compat), added laptop-display mirror toggle binding, lid switch bindings, hardware menu binding, touchpad toggle multimedia bindings. Also rewrote input.nix to mkDefault per-key (was wrapping the whole `input = {...}` attrset in mkDefault, which made user path-based overrides like `input.kb_variant = "dvorak"` silently replace the entire attrset instead of merging).
- ✅ Theme assets: backgrounds/omarchy.png + unlock.png + preview-unlock.png for 18 themes (flexoki-light skipped — no upstream omarchy.png), new tokyo-night/ristretto/vantablack backgrounds
- ✅ Theme palette updates in modules/custom-base16-schemes.nix: vantablack (true black background, color8 grey), lumon (new sky-blue accent at base0D)
- ✅ Themed templates: default/themed/{gum.env.conf.tpl, helix.toml.tpl} deployed to ~/.local/share/omarchy/default/themed/ (templating runtime is backlog — see omarchy-theme-set-templates)
- ✅ NixOS install equivalents: increase-fd-limit (systemd DefaultLimitNOFILESoft=65536), user-dirs (xdg.userDirs), OMARCHY_PATH env var set globally
- ✅ Gaming module rewrite: modules/nixos/gaming.nix now exposes per-component switches under omarchy.gaming.{steam,heroic,lutris,moonlight,retroarch,xboxCloud,geforceNow,xboxControllers,gpuLib32}.enable. Core stack (steam, xboxControllers, gpuLib32) defaults to gaming.enable; opt-in extras default to false. Replaces every upstream omarchy-install-gaming-* bash script.
- ✅ Backlog: omarchy-cmd-missing, omarchy-debug, omarchy-version, omarchy-version-{branch,channel}, omarchy-snapshot, omarchy-theme-{current,list}, default/bash/completions deployed
- ⚠️ Not ported (intentional): all gaming bash installers (replaced by gaming.nix options), omarchy-pkg-*, omarchy-refresh-*, omarchy-update-* lifecycle scripts (replaced by nixos-rebuild), all install/* shell scripts (replaced by NixOS modules), migrations/* (NixOS rebuilds declaratively), default/snapper/root, hardware-specific install scripts for ASUS B9406 / Z13 / Intel FRED (deferred)
- ✅ Gap closures (post-sync audit):
    - `recover-internal-monitor.service` wired declaratively in `modules/home-manager/default.nix` (`systemd.user.services.omarchy-recover-internal-monitor`).
    - Hardware modules: new `modules/nixos/hardware.nix` exposes `omarchy.hardware.{asus_b9406,asus_z13,intel_ptl_fred}.enable` (kernel params + udev rules + libinput quirks; off by default).
    - `omarchy-setup-fido2` (referenced from omarchy-menu but never defined) symlinked to the existing `omarchy-setup-fingerprint`, which actually handles FIDO2/U2F key registration on omarchy-nix. Menu Fido2 entry now functional.
    - `omarchy-plymouth-reset` guards the missing `omarchy-refresh-sddm` call so it no-ops on Nix instead of erroring.
    - Theme management ported: `omarchy-theme-install` (git clone into `~/.config/omarchy/themes/`), `omarchy-theme-remove`, `omarchy-theme-refresh`, `omarchy-theme-update` (git-pull only, skips Nix-managed symlinked themes).
    - Bash defaults now fully deployed (`default/bash/{aliases,envs,fns,functions,init,inputrc,rc,shell,completions}` → `~/.local/share/omarchy/default/bash/`).
- ⚠️ Remaining gaps (intentionally not closed):
    - `omarchy-first-run` calls `install/first-run/*.sh` which are Arch-only; on Nix the script is a safe no-op (flag file `~/.local/state/omarchy/first-run.mode` is never created and the autostart entry is intentionally absent). Equivalent functionality is already declarative: firewall/DNS/fingerprint/elephant/gnome-theme/wifi via NixOS modules; battery-monitor and welcome are nice-to-haves.
    - Theme templating runtime (`omarchy-theme-set-templates`) NOT ported. omarchy-nix uses pre-rendered theme configs in `config/themes/<theme>/` instead of `colors.toml + *.tpl`. The new `default/themed/{gum.env.conf.tpl,helix.toml.tpl}` are deployed but unused. Closing this would require either Nix-time template rendering or porting the dynamic theme machinery wholesale.
    - Plymouth runtime scripts (`omarchy-plymouth-set`, `-set-by-theme`, `-preview`) write to `/usr/share/plymouth/` and call `mkinitcpio`/`limine-mkinitcpio`; fundamentally Arch. Kept for name parity but unusable on Nix — Plymouth theme is rebuilt declaratively via `packages/plymouth-theme-omarchy.nix` + `nixos-rebuild`.
    - All `omarchy-pkg-*` / `omarchy-refresh-*` / `omarchy-update-*` lifecycle scripts: replaced by `nixos-rebuild switch` and `home-manager switch`. No port planned.
    - `omarchy-snapshot`: depends on snapper (Btrfs-specific). Kept for parity; will fail on non-snapper systems.

**Previous sync**: ~60 commits from 64ef8044..236a34b2 (v3.4.2 → v3.5.1):
- ✅ Hyprland input: repeat_delay 600 → 250 (faster key repeat)
- ✅ Hyprland looknfeel: disable_scale_notification = true
- ✅ Hyprland bindings: OSD uses omarchy-hyprland-monitor-focused, mic mute uses omarchy-cmd-mic-mute
- ✅ Hyprland bindings: Copilot key (SUPER SHIFT code:201) → Omarchy menu
- ✅ Hyprland bindings: SUPER CTRL Delete → toggle laptop display
- ✅ Hyprland autostart: omarchy-powerprofiles-init on boot
- ✅ New scripts: omarchy-hyprland-monitor-focused, omarchy-hyprland-monitor-internal-toggle
- ✅ New scripts: omarchy-cmd-mic-mute, omarchy-ac-present, omarchy-battery-present
- ✅ New scripts: omarchy-powerprofiles-init, omarchy-powerprofiles-set
- ✅ New scripts: omarchy-restart-trackpad, omarchy-sudo-reset
- ✅ Updated omarchy-battery-remaining-time: handle minutes unit with regex, show Xm for short durations
- ✅ Updated omarchy-launch-walker: restored GSK_RENDERER=cairo (fixes sluggish GTK4), pgrep -x
- ✅ Updated omarchy-theme-set-browser: suppress stderr noise (&>/dev/null)
- ✅ Updated omarchy-cmd-screenshot: auto-create screenshot directory
- ✅ Updated omarchy-menu: laptop display toggle, trackpad restart, waybar config.jsonc path
- ✅ Removed jetbrains.conf (JetBrains fixed Hyprland issues upstream)
- ✅ Added moonlight.conf app window rule
- ✅ Added resume-boost systemd sleep hook (power profile boost on resume)
- ✅ Added LocalSend Nautilus extension (right-click Send via LocalSend)
- ✅ Updated btop settings for v1.4.6 (terminal_sync, cpu_watts, battery_watts, gpu_mirror, etc.)
- ✅ Simplified waybar network tooltips (removed bandwidth stats)

**Branch tracking**: We track the **`master`** branch (v3.8.2 release)

**To check current Omarchy status**:
```bash
cd ../omarchy
git log --oneline -20
```

### Syncing with Omarchy Upstream

When the user asks to **"sync with Omarchy"**, **"update from Omarchy"**, or **"check for Omarchy changes"**, follow this workflow:

1. **Check commits since last sync**:
   ```bash
   cd ../omarchy
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
- Custom base16 schemes (ethereal, hackerman, osaka-jade, ristretto, miasma, vantablack, white, retro-82, lumon) are defined in `modules/custom-base16-schemes.nix`
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
- Theme options: tokyo-night, kanagawa, everforest, catppuccin, catppuccin-latte, rose-pine, rose-pine-dawn, rose-pine-moon, nord, gruvbox, gruvbox-light, flexoki-light, matte-black, ethereal, hackerman, osaka-jade, ristretto, miasma, vantablack, white, retro-82, lumon
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
1. **Check Omarchy first**: Locate the feature in `../omarchy`
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

**ALWAYS check Omarchy first** at `../omarchy` before making changes.

- **Adding/porting scripts**:
  - Omarchy: `../omarchy/bin/omarchy-*`
  - Omarchy-Nix: `bin/omarchy-*` (deployed to `~/.local/share/omarchy/bin/`)

- **Adding new packages**:
  - Omarchy: `install/packages.txt` or script that installs packages
  - Omarchy-Nix: `modules/packages.nix` (add to `systemPackages` or `homePackages`)

- **Adding/porting themes**:
  - Omarchy: `../omarchy/config/theme/*/theme.conf`
  - Omarchy-Nix:
    1. Add base16 scheme to `modules/custom-base16-schemes.nix` (if not in nix-colors)
    2. Map theme name in `modules/themes.nix`
    3. Add to enum in `config.nix` (line 17-36)

- **Modifying keybindings**:
  - Omarchy: `../omarchy/config/hypr/hyprland.conf` (check `bind=` lines)
  - Omarchy-Nix: `modules/home-manager/hyprland/bindings.nix`

- **Adding quick app shortcuts**:
  - Omarchy: Check existing keybindings in `config/hypr/hyprland.conf`
  - Omarchy-Nix: Modify `quick_app_bindings` default in `config.nix` or override in user configuration

- **Adding backgrounds/assets**:
  - Omarchy: `../omarchy/default/` (backgrounds, icons, etc.)
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
- `hyprland`: Hyprland compositor from upstream (pinned to v0.55.2)
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
- Hyprland is pinned to v0.55.2 via the omarchy-nix flake input - update carefully
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

## Design Decisions

- **No blueman GUI**: Using bluetui TUI only. Re-add `services.blueman.enable = true` if needed.
- **No waybar drawer**: Tray shows directly. Use `"group/tray-expander"` instead of `"tray"` to restore.
