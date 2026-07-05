# Omarchy 4 port tracking

Working doc for porting the next-major Omarchy to omarchy-nix. The work lives on
the **`omarchy-4` branch of omarchy-nix**; `main` stays on the v3.8.x / `dev`
line until v4 lands.

## Upstream status (as of June 30, 2026)

> **Upstream renamed the v4 branch `omarchy-4` → `quattro`.** The old `omarchy-4`
> branch is frozen at `17f024d4` (June 7); active daily development moved to
> **`quattro`**. Track `quattro`, NOT `omarchy-4`. (Our omarchy-nix *branch* is
> still named `omarchy-4` — that's just our branch name, unrelated to upstream's.)

- **Branch**: `quattro` @ `af828481` ("Give it a little more time", ~2026-07-04) — **unreleased**, no `v4` tag, active daily.
- **Scope**: ~1000 commits ahead of `dev`. There is a **4.0 milestone** (1 issue open). Only ~5 open PRs, all additive.
- **What gates the release** (from recent commits): shell UX polish, display/monitor edge-case hardening, and the package-backed channel model (dev → edge → rc → stable) + v3→v4 migration path.
- **Port baseline**: `quattro` @ **`af828481`**, synced July 5 2026 (23 commits from `6ef0c019`): shared region picker `omarchy-capture-region` (screenshot + recording, Return = fullscreen, rotated monitors), plugin manager rewritten to plain git (`omarchy-plugin{,-catalog,-clone,-validate}` added; `-add/-remove/-source/-update` and `omarchy-config-shell-bar` deleted; new `omarchy-bar` owns bar config), `omarchy-shell` IPC via `qs ipc call`, clipboard watchers under `setpriv --pdeathsig`, notification history replay, shared `omarchy-theme-color` resolver, tmux window titles (`config/tmux/tmux.conf` re-vendored in full — it had lagged), simplified `omarchy-restart-shell` (kept the Nix `pkill -f .quickshell-wrapped` deviation). `test/` + `docs/` and the Arch-only `*-service-{dropbox,tailscale}` installers not vendored, as before.
- **Previous baseline**: re-synced from `omarchy-4` (June 7) onto **`quattro`** on June 30 — 246 commits: re-vendored `shell/` + `default/{hypr,omarchy,themed}` + `bin` (11 new / 82 updated / 4 removed), adopted `bootstrap.lua` (inlined with a HOME fallback — `OMARCHY_PATH` is NOT in Hyprland's parse env), and migrated `current/theme` to `~/.local/state/omarchy/current/theme`.
- **omarchy-nix sync baseline**: `main` is at Omarchy `dev` `9cf1852` (v3.8.2 + 2 commits).

Re-measure before each work session:
```bash
cd ../omarchy && git fetch origin quattro:refs/remotes/origin/quattro
git log -1 --format='%h %ci' origin/quattro
git rev-list --count af828481..origin/quattro   # delta since last port baseline
```

## Setup menu on Nix (July 5, 2026)
The menu's Setup entries route through `omarchy-launch-config-editor` (now
ported). Per-user config files it opens are **seeded once** as user-owned
writable files (never overwritten on rebuild), matching upstream's
installer-writes-once model: `~/.config/hypr/monitors.lua` (omarchy.scale baked
in at seed time), `~/.config/hypr/hyprsunset.conf`, `~/.XCompose` (emoji
include from `$OMARCHY_PATH/default/xcompose` + name/email from omarchy
options). The remaining entries (Keybindings, Input, Config > Hyprland) open
Nix-generated read-only files — view-only by design; edits belong in
nixos-config / HM settings (the `hm.lua` bridge loads last and overrides).

## Known follow-ups (quattro)
- **Window-border theming is build-time only.** Runtime theme switches recolor foot/terminals + shell, but not Hyprland borders (our generated `hypr.looknfeel` sets borders from the build-time base16; quattro loads `require_optional("omarchy.current.theme.hyprland")`). To make borders follow runtime switches, generate a per-theme `hyprland.lua` (border colors) into each theme dir and stop hard-setting borders in `hypr.looknfeel`.
- v4 `omarchy-theme-set` shells out to helpers we don't ship (`omarchy-restart-helix/-opencode`, `-theme-set-pi`) — harmless "command not found" noise. (`-theme-set-templates` and `-theme-set-tmux` are now vendored.)

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
4. ✅ **Retire the old stack** (gated on `shell.enable`): `waybar`/`mako`/
   `swayosd`/`hyprlock`/`hyprpolkitagent`/`swaybg` configs + their autostart
   exec-once entries now stand down when `shell.enable`. `walker` needs no gate
   (empty stub; nothing invokes it once the bindings are rewired). Verified by
   eval: shell-on autostart drops waybar/swaybg/polkit, `services.mako` is unset.
5. ✅ **Rewire keybindings to the v4 IPC model** — `bindings.nix` now switches
   the affected binds on `shell.enable`: `omarchy-shell shell toggle
   omarchy.{launcher,emojis,clipboard}`, `omarchy-shell {audio,bluetooth,monitor,
   network,power} toggle` (+ new Display/Power binds),
   `omarchy-shell notifications {dismissOne,dismissAll,invokeLast,showHistory}`,
   `omarchy-shell media {next,playPause,previous}`, volume via
   `omarchy-audio-output-volume`, top-bar via `omarchy-toggle-bar`. Classic
   (walker/mako/swayosd) bindings are kept verbatim when the shell is off.
   Verified by evaluating the module's `extraConfig` for both flag states.
6. Reconcile config content moved into `omarchy-settings` (`/etc` drop-ins,
   `/usr/share`) with the existing Nix modules.
7. Fold in the smaller items (udiskie, `$OMARCHY_PATH` cleanup, default-terminal).
8. **Hyprland hyprlang → Lua** (NOT done). Hyprland 0.55 loads `~/.config/hypr/hyprland.lua`
   natively (`hl.*` API); v4 ships a whole Lua framework (`default/hypr/helpers.lua`
   defines the `o` DSL, `omarchy.lua` `require`s `bindings/*`, `windows`, `input`,
   `looknfeel`, `envs`, `apps/*`, `toggles/*`), with theme colours coming from
   `omarchy.current.theme.hyprland`. omarchy-nix still generates **hyprlang** via the
   `modules/home-manager/hyprland/*.nix` `extraConfig` strings (`configType="hyprlang"`).
   The shell is agnostic to this, so it isn't required for v4 to work — but full
   fidelity wants it. Real decision before starting: **(a)** vendor upstream's Lua
   framework verbatim and deploy a `hyprland.lua` that `require`s it (true v4, but the
   nix theme system must emit `current/theme/hyprland.lua` and we lose the nix-level
   `quick_app_bindings`/voxtype-conditional config), vs **(b)** flip HM
   `configType="lua"` and convert our existing nix-generated config to Lua (keeps the
   nix config model, less faithful to upstream's file layout).

## Hyprland Lua conversion: SOLVED via an HM→Lua translator

First attempt shipped a bare `hyprland.lua`, which a live switch proved fatal
(see "the trap" below). **The fix:** omarchy-nix reads the merged
`config.wayland.windowManager.hyprland.{settings,extraConfig}` and **translates
them into Lua** (`modules/home-manager/hyprland.nix`, `hmLua`): structured
`settings` → `hl.config({...})`, and `extraConfig` / `settings.bind*` parsed into
`o.bind()`/`hl.bind()` (flags d/e/l/r/m → description/repeating/locked/release/
mouse). The result is `~/.config/hypr/hm.lua`, required **after** the Omarchy
defaults so the user's overrides win. HM still writes `hyprland.conf` — harmless,
since Hyprland loads the `.lua` and ignores it. **No nixos-config changes.**
Validated end-to-end: a real `nixos-rebuild build` of nixtop generates an
`hm.lua` carrying Mike's Dvorak + all 5 personal binds (incl. the `binddr`
voxtype-stop as `{ release = true }`) with correct shell-in-lua escaping.

Round-trips faithfully because `builtins.toJSON` escaping of a command produces a
Lua double-quoted string Lua parses back to the identical bash (e.g.
`awk "{print \$2}"` → `awk \"{print \\$2}\"` → `awk "{print \$2}"`).

### The trap (why a bare hyprland.lua failed)

- Hyprland 0.55 `ConfigManager`: if `~/.config/hypr/hyprland.lua` exists it loads
  **only** the lua and ignores `hyprland.conf` entirely (verified in the
  Hyprland source — `getMainConfigPath` returns the `.lua` when present).
- Home-Manager writes the user's personal Hyprland config (set via
  `wayland.windowManager.hyprland.settings`/`extraConfig` in *their* nixos-config
  — e.g. Dvorak `kb_variant`, custom binds, screenshot keys) to `hyprland.conf`.
- Hyprland's lua `hl` API has **no `source`/`keyword`/`parse`** — there is no way
  to pull a hyprlang `.conf` into the lua config.

⇒ Shipping `hyprland.lua` silently discards every omarchy-nix user's personal
HM-based Hyprland config. No clean bridge exists, so **omarchy-nix stays on
hyprlang** (where omarchy's config and the user's HM settings merge in one
`hyprland.conf`). The "nix-generates-lua-overrides" link was elegant but only
covered omarchy's *own* options, not arbitrary user HM settings. Don't re-attempt
the lua port unless Hyprland adds a lua→hyprlang source or HM gains a lua emitter.

The v4 IPC bindings, shell autostart, and window rules all live in hyprlang
(`hyprland/bindings.nix`, `omarchy-shell.nix`) and dry-build clean against the
real nixtop config.

## Major-alignment status (June 30, 2026)
The legacy stack is fully removed and omarchy-shell is the only desktop (commits
`d16403a`, `0929a46`): waybar/walker/mako/swayosd/hyprlock/hypridle/swaybg +
elephant deleted (modules, assets, flake inputs, system.nix plumbing); shell is
unconditional; bindings/autostart/PAM/theme-switcher all v4; the keybinding-bound
scripts reconciled to their v4 shell-IPC versions. **Done bar two things:** the
Lua conversion above, and the long tail of ~25 menu/feature scripts that only poke
the removed daemons for a secondary indicator/OSD (reconcile case-by-case,
preserving each script's Nix adaptations — not a bulk vendor).

> **Next:** flip `omarchy.shell.enable = true` on a real host and `home-manager
> switch` — the whole replace (shell bar/launcher/menu/notifications/osd/lock/
> polkit + rewired keybindings) is now wired and gated; this is the live
> validation pass. Some same-name-but-changed scripts (e.g. transparency toggle,
> `omarchy-brightness-display` arg style) may still need a reconciliation pass.

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
