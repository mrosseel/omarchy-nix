# Omarchy 4 port tracking

Working doc for porting the next-major Omarchy (the `omarchy-4` branch) to
omarchy-nix. This branch (`omarchy-4`) is where that work happens; `main`
stays on the v3.8.x / `dev` line until v4 lands.

## Upstream status (as of June 30, 2026)

- **Branch**: `omarchy-4` @ `17f024d4` (2026-06-07) — **unreleased**, no `v4` tag yet, still churning.
- **Diverged** from `dev` at `b911a6f8` (2026-05-21).
- **Scope**: ~741 commits ahead of `dev`, ~1,197 files changed (+58.5k / −11.4k).
- **omarchy-nix sync baseline**: `main` is at Omarchy `dev` `9cf1852` (v3.8.2 + 2 commits).

Re-measure before each work session:
```bash
cd ../omarchy && git fetch origin
git log -1 --format='%h %ci' origin/omarchy-4
git rev-list --count origin/dev..origin/omarchy-4
```

> **Decided (June 30, 2026):** `omarchy-shell` **replaces** the existing stack
> (waybar/walker/mako/swayosd/hyprlock/hyprpolkitagent) — no coexist/switch
> path — to stay as close to Omarchy as possible.

## Progress

Foundation for the Quickshell shell has landed on this branch (gated off by
`omarchy.shell.enable`, default false, so the branch stays buildable while the
old stack is still present):

- ✅ Vendored the upstream `shell/` Quickshell tree (164 files) + the default
  `config/omarchy/shell.json`, pinned to omarchy-4 `17f024d4`.
- ✅ `modules/home-manager/omarchy-shell.nix` (new, gated): adds `pkgs.quickshell`
  (nixpkgs 0.3.0), deploys `shell/` → `~/.local/share/omarchy/shell` and the
  defaults → `~/.local/share/omarchy/config/omarchy/shell.json`, autostarts
  `quickshell -n -p $OMARCHY_PATH/shell`, and adds the layer/window rules
  translated from upstream `default/hypr/apps/omarchy-shell.lua`.
- ✅ `omarchy.shell.enable` option in `config.nix`.
- ✅ Vendored the shell bin scripts: `omarchy-shell` (IPC forwarder),
  `omarchy-restart-shell`, `omarchy-refresh-shell`, `omarchy-refresh-config`,
  `omarchy-config-shell-bar`, `omarchy-shell-bar-text-color`.
  - Nix deviations: `omarchy-restart-shell` uses `pkill -f` (nixpkgs wraps
    `quickshell`, so its comm is `.quickshell-wrapped` and `pkill -x quickshell`
    never matches); `omarchy-refresh-config` falls back to `$OMARCHY_PATH/config/`
    when `/etc/skel/.config/` is absent (Nix has no populated skel).
- ✅ `nix flake check` passes (shell off). Formatted with alejandra.
- ✅ **Brought up live** on a running Hyprland 0.55.3 session (ran
  `quickshell -n -p $OMARCHY_PATH/shell` against the vendored tree):
  - **quickshell 0.3.0 loads the shell cleanly** — `Configuration Loaded`,
    **0 fatal QML errors**, no version/import mismatches. The bar + plugins
    instantiate and render. This retires the biggest unknown (QML API match).
  - Non-fatal warnings were all conflicts with the *running v3 stack* (mako
    already owns notifications, hyprpolkitagent already owns polkit) — these
    disappear once the shell replaces them — plus a couple of upstream QML
    binding-loop warnings and cosmetic portal/UPower warnings.
- ✅ Vendored the 24 runtime-backend bin scripts the bar/panels shell out to
  (audio/battery/bluetooth/clipboard/dns/network-status/monitor-state/
  system-stats/theme-switcher/…). Arch-ism audit: only
  `omarchy-remove-launcher-entry` uses `pacman` (package removal — needs a Nix
  adaptation/stub; edge feature). The other 23 are clean (jq/hyprctl/nmcli).
- ✅ Vendored the 9 remaining bin scripts the v4 **keybindings/autostart** call
  that we didn't already have (`omarchy-audio-output-volume`,
  `-audio-source-switch`, `-hyprland-window-{transparency,tiled-fullscreen,width}-toggle`/`-width`,
  `-menu-tmux-keybindings`, `-notification-{battery,time,weather}`); zero Arch-isms.
  → The v4 desktop's **script layer is now essentially complete** (33 v4 scripts
  vendored). Note: some scripts that exist in *both* trees changed in v4
  (e.g. `omarchy-brightness-display` arg style); those still need a
  same-name reconciliation pass before the bindings behave exactly like v4.

### Eval/build validation note
The home-manager module is driven by the NixOS module via `osConfig`; it is not
designed for standalone `homeManagerConfiguration` eval (that path errors on
`omarchy.light_theme_detection` being null **regardless of `shell.enable`** —
confirmed by an A/B with the shell off, so it's a harness limit, not a shell
defect). True end-to-end build validation = enable `omarchy.shell.enable` in a
real NixOS+HM config and `home-manager build`. That's the gate before any switch.

**Still to confirm on a real `home-manager switch`:** the two startup pollers
(`omarchy-network-status`, `omarchy-monitor-state`) logged a QProcess
"could not start" under the isolated test harness, yet both run fine standalone
(`network-status` → `ethernet enp191s0`, `monitor-state` → `HDMI-A-1`) with a
clean `#!/bin/bash` shebang. Almost certainly a test-invocation artifact (env/
PATH/working-dir vs. a real uwsm session), not a defect — verify when the shell
is enabled for real. Also still pending: an end-to-end `home-manager` build of
the enabled path (flake exposes only modules, no test config).

### Launch / deploy facts (reference)
- Launch: `quickshell -n -p $OMARCHY_PATH/shell` (upstream `default/hypr/autostart.lua`).
- Shell reads: `$OMARCHY_PATH/shell/shell.qml`, plugins from `shell/plugins/`,
  defaults `$OMARCHY_PATH/config/omarchy/shell.json`, user override `~/.config/omarchy/shell.json`.
- IPC: `omarchy-shell <target> <method> [args]` over the quickshell instance
  socket under `$XDG_RUNTIME_DIR/quickshell/`. Keybindings call e.g.
  `omarchy-shell shell toggle omarchy.launcher`.

### Big separate workstream discovered: Hyprland config is now Lua
omarchy-4 converted Hyprland config from hyprlang `.conf` to **Lua**
(`default/hypr/*.lua`, `bindings/*.lua`, `apps/*.lua`). omarchy-nix currently
generates hyprlang via `modules/home-manager/hyprland/*.nix` (and the June-1 fix
pins `configType = "hyprlang"`). The v4 keybindings are all `omarchy-shell ...`
IPC calls. This is its own large port, tracked separately from the shell.

## What Omarchy 4 is

Omarchy 4 is an architectural rewrite, not a feature bump. Three big shifts:

### 1. `omarchy-shell` — one Quickshell instance hosting everything
A single long-running [Quickshell](https://quickshell.org/) (QML) process,
launched once per Hyprland session, hosts the whole desktop as plugins under
`shell/`:

- `bar/` → replaces **waybar**
- `launcher/` → replaces **walker**
- `menu/` → replaces the `omarchy-menu` / walker menus
- `notifications/` → replaces **mako**
- `osd/` → replaces **swayosd**
- `lock/` → replaces **hyprlock**
- `polkit/` → replaces **hyprpolkitagent**
- `background/`, `clipboard/`, `emojis/`, `image-picker/`, `panels/`,
  `reminders/`, `model-usage/`, `dev-gallery/`

Structure: `shell/shell.qml` (ShellRoot entry), `shell/services/{PluginRegistry,BarWidgetRegistry}.qml`,
`shell/Commons/` (Style/Color/Util singletons), `shell/Ui/` (widget library),
`shell/plugins/<name>/`. Enabled state + config live in `shell.json`. Plugins
are discovered from disk, so third-party plugins drop in without source edits.
New dependency: `quickshell`. Reference: upstream `docs/omarchy-shell.md`,
`shell/README.md`, `shell/plugins/README.md`.

### 2. Packaged distribution (Arch packages, not a runtime installer)
`boot.sh` / `install.sh` are gone. Two Arch packages are now built from the
repo (PKGBUILDs in `omarchy-pkgs/`):
- **`omarchy`** — runtime `bin/`, `install/` finalize scripts, migrations,
  themes, and the Quickshell `shell/`.
- **`omarchy-settings`** — everything that must exist before user creation:
  all `/etc/skel/**`, `/etc/` drop-ins, package-owned `/usr/share` + `/usr/lib`
  files, fonts, plymouth/sddm themes, branding, limine/snapper configs.

Plus standalone `omarchy-keyring` and `omarchy-nvim`.

`$HOME` is populated in three layers (`docs/file-layout.md`):
1. **Seed** — `/etc/skel/` copied by `useradd -m` at user creation.
2. **Finalize** — `omarchy-finalize-user` (one-shot; needs `$HOME` / live
   `$OMARCHY_PATH` / runtime detection).
3. **Resync** — `omarchy-reinstall-configs` (explicit, destructive re-seed).

### 3. Path + install plumbing
- `$OMARCHY_PATH` replaces hardcoded `~/.local/share/omarchy` runtime paths,
  defaulted via `/etc/profile.d/omarchy.sh`.
- New `etc/` source tree for package-shipped `/etc` files.
- Install split into system vs user targets; new migrations framework
  (`docs/migrations.md`, `docs/update-process.md`).
- Foot is the default terminal; udiskie auto-mounts removable drives.

## Porting impact for omarchy-nix

| Upstream area | Nix mapping | Effort |
|---|---|---|
| `omarchy-shell` (Quickshell) | Package `quickshell`; deploy `shell/` QML tree; Hyprland autostart for the shell; **replace** `waybar.nix`/`walker.nix`/`mako.nix`/swayosd/`hyprlock.nix` (decided). Foundation landed (gated off). | **Large** |
| `omarchy` / `omarchy-settings` packaging | Mostly N/A — Nix already deploys config declaratively. Port the *content* (which `/etc` drop-ins, `/usr/share` files, configs ship), not the PKGBUILD/skel mechanism | Medium |
| seed → finalize → resync | Maps to home-manager activation + `home.file`; `omarchy-finalize-user` logic → activation scripts | Medium |
| `$OMARCHY_PATH` decoupling | Minor — omarchy-nix already sets `OMARCHY_PATH` (`modules/nixos/system.nix`); keep but stop assuming it equals `~/.local/share/omarchy` | Small |
| `etc/` drop-ins | Translate to NixOS `environment.etc` / module options where they matter | Medium |
| Foot default terminal | Already ported (`modules/home-manager/foot.nix`); confirm it's the *default* | Small |
| udiskie auto-mount | `services.udiskie` (home-manager) or a NixOS equivalent | Small |
| migrations framework | N/A on Nix (declarative rebuilds) | None |

## Suggested order of work

1. ✅ **Spike the Quickshell shell** — package `quickshell`, deploy `shell/` to
   `$OMARCHY_PATH/shell`, wire the Hyprland autostart + layer rules, port the
   shell bin scripts. (Foundation landed, gated off — see Progress.)
2. ✅ **Complete the script layer** — vendor every bin script the shell + v4
   keybindings/autostart call (33 vendored). Remaining: reconcile the handful of
   *same-name-but-changed* scripts to their v4 versions.
3. **Validate the enabled path on a real switch** ← *the gate. Needs you.* Enable
   `omarchy.shell.enable` in a real config, `home-manager build` then `switch`,
   confirm the bar renders and the two startup pollers resolve. Everything below
   is best done *after* this, because it can only be validated live and the
   upstream branch is still moving (no `v4.0` tag yet).
4. **Retire the old stack** (gated on `shell.enable`): stand down
   `waybar`/`walker`/`mako`/`swayosd`/`hyprlock`/`hyprpolkitagent` + their
   autostart entries; the shell owns those surfaces. (Structural, ~6 modules.)
5. **Rewire keybindings to the v4 IPC model** — port `default/hypr/bindings/*.lua`:
   `omarchy-shell shell toggle omarchy.{launcher,emojis,clipboard}`,
   `omarchy-shell {audio,bluetooth,monitor,network,power} toggle`,
   `omarchy-shell notifications {dismissOne,dismissAll,...}`,
   `omarchy-menu toggle <view>`, `omarchy-shell media {next,playPause,...}`.
   Large + churn-prone until v4 tags — hold until step 3 passes.
6. Reconcile config content moved into `omarchy-settings` (`/etc` drop-ins,
   `/usr/share`) with the existing Nix modules.
7. Fold in the smaller items (udiskie, `$OMARCHY_PATH` cleanup, default-terminal,
   optional Hyprland hyprlang→Lua conversion — orthogonal; the shell works under
   either, so not required).

### Test-switch recipe (for step 3, on a real NixOS+HM host)
```nix
# in your host's omarchy config:
omarchy.shell.enable = true;   # adds quickshell, deploys shell/, autostarts it
```
```bash
home-manager build --flake <yourflake>   # eval/build the enabled path first
home-manager switch --flake <yourflake>  # then switch; bar should render
omarchy-restart-shell                     # bounce the shell after edits
```

## Decisions

- ✅ **Replace, don't coexist** (June 30, 2026): `omarchy-shell` fully replaces
  waybar/walker/mako/swayosd/hyprlock/hyprpolkitagent — stay close to Omarchy.
  During the transition the new module is gated behind `omarchy.shell.enable`
  (default off) purely to keep the branch buildable; the end state removes the
  old modules.

## Open decisions

- **Quickshell packaging**: nixpkgs `quickshell` (0.3.0) vs. pinning the exact
  upstream revision Omarchy 4 targets — revisit once the shell is brought up and
  we know whether 0.3.0's QML API matches.
- **When to go deep**: omarchy-4 is unreleased and moving fast — the foundation
  is cheap to carry, but hold large plugin/keybinding ports until a `v4.0` tag
  to avoid chasing a moving target.

## Reference (upstream docs on the `omarchy-4` branch)

```bash
cd ../omarchy
git show origin/omarchy-4:docs/omarchy-shell.md
git show origin/omarchy-4:docs/file-layout.md
git show origin/omarchy-4:docs/update-process.md
git show origin/omarchy-4:docs/migrations.md
git show origin/omarchy-4:docs/theming.md
git show origin/omarchy-4:shell/README.md
```
