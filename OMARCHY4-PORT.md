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
| `omarchy-shell` (Quickshell) | Package `quickshell`; deploy `shell/` QML tree; Hyprland autostart for the shell; decide fate of `waybar.nix`/`walker.nix`/`mako.nix`/swayosd/`hyprlock.nix` (replace vs keep as fallback) | **Large** |
| `omarchy` / `omarchy-settings` packaging | Mostly N/A — Nix already deploys config declaratively. Port the *content* (which `/etc` drop-ins, `/usr/share` files, configs ship), not the PKGBUILD/skel mechanism | Medium |
| seed → finalize → resync | Maps to home-manager activation + `home.file`; `omarchy-finalize-user` logic → activation scripts | Medium |
| `$OMARCHY_PATH` decoupling | Minor — omarchy-nix already sets `OMARCHY_PATH` (`modules/nixos/system.nix`); keep but stop assuming it equals `~/.local/share/omarchy` | Small |
| `etc/` drop-ins | Translate to NixOS `environment.etc` / module options where they matter | Medium |
| Foot default terminal | Already ported (`modules/home-manager/foot.nix`); confirm it's the *default* | Small |
| udiskie auto-mount | `services.udiskie` (home-manager) or a NixOS equivalent | Small |
| migrations framework | N/A on Nix (declarative rebuilds) | None |

## Suggested order of work

1. **Spike the Quickshell shell** — package `quickshell`, deploy `shell/` read-only
   to its expected path, wire one Hyprland autostart, get `omarchy-shell` to
   start and render the bar plugin. Everything else hangs off this.
2. Port plugins incrementally, retiring the matching old module as each lands:
   bar → waybar, launcher → walker, notifications → mako, osd → swayosd,
   lock → hyprlock, polkit → hyprpolkitagent.
3. Reconcile config content moved into `omarchy-settings` (`/etc` drop-ins,
   `/usr/share`) with the existing Nix modules.
4. Fold in the smaller items (udiskie, `$OMARCHY_PATH` cleanup, default-terminal).

## Open decisions (ask before committing to one)

- **Replace vs. coexist**: do we cut waybar/walker/mako/swayosd entirely in
  favor of `omarchy-shell`, or keep them behind a config switch during the
  transition? (Affects every dependent module + keybindings.)
- **Quickshell packaging**: nixpkgs `quickshell` vs. pinning the exact upstream
  revision Omarchy 4 targets.
- **When to start**: omarchy-4 is unreleased and moving fast — consider waiting
  for a `v4.0` tag before deep porting, to avoid chasing a moving target.

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
