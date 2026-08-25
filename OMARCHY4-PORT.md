# Omarchy 4 port tracking

Working doc for porting the next-major Omarchy to omarchy-nix. **The v4 work is
on `main`** — the old `omarchy-4` working branch has been deleted. The pre-v4
v3.8.x state is preserved on `archive/main-pre-v4`.

## Upstream status

> **Upstream renamed its v4 branch `omarchy-4` → `quattro`.** Upstream's
> `omarchy-4` is frozen at `17f024d4` (June 7); active daily development is on
> **`quattro`**. Sync against `quattro`, NOT `omarchy-4`.

- **Branch**: `quattro` @ `23dab9ec` — post-`v4.0.1` (the `v4.0.1` tag, Aug 25 2026, is a backport release branch off quattro). `dev`/`master` are still the 3.8.x line; keep syncing against `quattro`.
- **Port baseline**: `quattro` @ **`23dab9ec`**, synced August 25 2026 (41 commits from `ed7bae4a`). Highlights:
  - **Security batch** (the v4.0.1 content): notification click actions now travel as an argv D-Bus hint (`omarchy-exec-argv`) instead of a shell string — `omarchy-notification-send`, the notifications shell plugin, and every `--exec` caller (capture-screenshot/-screenrecording, tailscale-receive, crash-watch, migrate-notify) re-vendored verbatim. Installed themes can no longer run code (theme staging drops `hyprland.lua`/`gum_env.lua`/etc.); `omarchy-git-url-check` is new and gates `omarchy-theme-install`/`omarchy-plugin-add` transports; FIDO2 setup stops staging its authfile at a predictable /tmp path; USB device names are stored as data (`default/hypr/disabled-input-device.lua` + `require_all` `options.exclude`), not generated Lua. `omarchy-dns` pins a trusted PATH (merged onto our `PACKAGED_PATH` deviation).
  - **Sudoless Docker opt-in**: upstream no longer puts the user in the root-equivalent `docker` group. Nix port: new `omarchy.containers.sudoless_docker` option (default **false**, matching upstream) gates `extraGroups = ["docker"]` in `modules/nixos/containers.nix`; `omarchy-sudo-docker` vendored verbatim (socket probe works on NixOS); `omarchy-launch-docker-tui` vendored with a pkexec deviation (`/run/current-system/sw/bin/lazydocker`, since pkexec's reset PATH is empty on Nix); `omarchy-setup/remove-security-sudoless-docker` are Nix-flavored explainer stubs pointing at the option. The `SUPER+SHIFT+D` quick_app_bindings default and upstream applications.lua both route through `omarchy-launch-docker-tui` now. **Existing installs lose passwordless docker on rebuild unless they set the option** — same posture change upstream shipped as a migration.
  - **quickshell back to a release**: input pinned to `v0.3.1` (kills synchronously), mirroring upstream's `quickshell-git` → `quickshell` package switch.
  - **`omarchy-ascii`** (self-contained awk FIGlet renderer, font embedded) + **`omarchy-branding-about-animation`** (About glint) + refreshed `config/omarchy.ttf`; `omarchy-launch-about` re-vendored.
  - **`omarchy-theme-extras`** new; theme install/remove/update re-vendored (staging model). `omarchy-sudo-reset` deleted upstream and here.
  - **`Super + Q`** second close-window chord (tiling.lua); bigger clipboard history (Clipboard.qml); Ori as a lazy agent choice (omarchy-agent/default-agent re-vendored; the mise-side install stays Arch-only); clock tooltip date formats; clamshell auto-scale fix merged onto our dpms-wake deviation.
  - **monitors.lua skel** reworked upstream (auto monitor scale, GDK section moved+documented) — `monitorsLua` in `modules/home-manager/hyprland.nix` follows, still baking `omarchy.scale` in as the GDK factor.
  - **Not ported**: Ori/mise install machinery (Arch), docker-group migration + all 7 `migrations/` (declarative here), `applications/Docker.desktop` (we don't ship it; our binding covers it), signed-packages commit pair (reverted upstream), `install/*`, `plans/`, `docs/`, `manual/`, `test/`.
  - **Runtime note**: the theme-code security fix only lands in an already-staged theme after a re-stage — run `omarchy-theme-refresh` (or switch themes once) after updating.
  - **Theme backgrounds are webp** (upstream `a4219f8f`, `ec779715`): all 159 background/preview files re-vendored from upstream, so `config/themes/<t>/backgrounds/` is byte-identical again. Only `tokyo-night/5-oma-cityscape.jpg` and `ristretto/2-coffee-beans.jpg` stayed jpg, matching upstream.
    **Qt reads webp only through the qtimageformats plugin.** Arch gets it from the new `qt6-imageformats` entry in `omarchy-base.packages`; the quickshell flake build does not carry it, so `modules/home-manager/omarchy-shell.nix` now wraps quickshell with `QT_PLUGIN_PATH` prefixed by `${pkgs.qt6.qtimageformats}/lib/qt-6/plugins`. Without this every background, theme preview and lock wallpaper renders blank — the shell owns the background on v4 (hyprpaper/swaybg are no longer imported). Prefixed onto quickshell alone rather than exported session-wide, so no other Qt app is handed a plugin dir from a different Qt build. `imagemagick` and `vips` (the picker thumbnails) already carry libwebp.
  - **Quake console** (upstream `0b511170`, `83987718`): new `default/hypr/qconsole.lua` — the scratchpad becomes a dimmed half-screen drop-down seeded with `omarchy-agent`, sized from the monitor's usable area on every layout change. `SUPER + grave` / `SUPER + SHIFT + grave` join `SUPER + S` / `SUPER + ALT + S`. No Nix work: the whole thing is vendored lua under `default/hypr/`, which deploys recursively, and nothing in `modules/` sets scratchpad or `specialWorkspace` state.
  - **Clipboard capture now decodes mixed UTF-16 with perl** (upstream `238021cd`): `shell/plugins/clipboard/capture.sh` swapped `jq -cRs` for a perl one-liner (`Encode` + `JSON::PP`, both core). Arch always has perl; added `pkgs.perl` to `modules/packages.nix`, or every clipboard entry is dropped.
  - **`omarchy-dns` re-execs from a packaged path** (upstream `3765e801`, `1e70cca1`): upstream hardcodes `/usr/bin/omarchy-dns` so its new `etc/sudoers.d/omarchy-dns` grant matches. **Nix deviation**: that path does not exist, so `PACKAGED_PATH` is `$OMARCHY_PATH/bin/omarchy-dns`, and the sudoers grant is deliberately **not** ported — `~/.local/share/omarchy/bin` is user-writable, so a NOPASSWD rule on it would hand out root. `sudo_grants_passwordless()` then returns false and the network panel's DNS toggle falls through to polkit, which is exactly the fallback upstream wrote for machines whose omarchy-settings predates the grant.
  - **Agent lineup**: `gemini` → `agy` / Antigravity (upstream `ed7bae4a`), `claude --permission-mode auto` and `codex --approve-for-me` instead of full bypass (`dd9dee41`), `hey` added as a lazy mise tool. Only the vendored scripts + `default/bash/aliases` changed; the AI installers stay Arch-only.
  - **Menu `disabled:` rows** (upstream `4b93f8d8`, `b724f761`, `023021ad`): the Install submenus dim already-installed software instead of hiding it, and `Remove > AI` is new. Menu.qml/MenuModel.js re-vendored; our inline-calculator row gained the `disabled: false` field the new `required property bool disabled` delegate needs.
  - **Icon font refreshed** (`config/omarchy.ttf`) with the LM Studio / Ollama / T3 Code glyphs.
  - **New `bin/omarchy-windows-key`**: prints the OEM Windows product key from the ACPI MSDM table. Generic, so vendored verbatim.
  - **Not ported**: `etc/sudoers.d/omarchy-dns` (above), `install/*` (`mise-bin`, `qt6-imageformats`, the `hey` mise entry — all covered declaratively), `omarchy-{install-browser,mise-install,remove-dev-env,remove-ai-*}` (Arch installers, unchanged policy), `omarchy-setup-security-sshd`'s new `--gh-keys` flag (sshd is declarative on Nix), `omarchy-chromium-ytdlp-host` (the yt-dlp extension gap predates this sync), `config/omarchy/extensions/omarchy-menu.jsonc` (a commented /etc/skel sample; Nix has no skel and the file is optional — seeding it would be a new behavior, ask first), and `plans/`, `docs/`, `manual/`, `test/` (docs-only).
  - **Known gap, pre-existing**: `omarchy-dns` writes `/etc/systemd/resolved.conf`, which NixOS owns as a store symlink, so the write fails on a rebuilt system. DNS belongs in `services.resolved` / `networking.nameservers` in the user's nixos-config. Not introduced by this sync.
  - **Known gap, new**: `omarchy-default-{browser,terminal,editor}` now offer to install a missing app (upstream `b724f761`) by calling `omarchy-install-*` / `omarchy-pkg-add`, which do not exist here. Picking an uninstalled default therefore fails in a floating terminal instead of silently setting a broken preference. Consistent with the Arch-installer policy; add the package in nixos-config instead.
- **Previous baseline**: `quattro` @ **`f0020448` (v4.0.0)**, synced August 15 2026 (326 commits from `4d93ad58`). Highlights:
  - **Themes re-rendered** from the same recipe (below). Only `helix.toml` changed (new `lighter_background` palette entry) and `claude.json` is new; `last-horizon/neovim.lua` is now generated too. Everything else came out byte-identical, which is the check that the offline render is still faithful.
  - **tokyo-night backgrounds renumbered**: `0-winding-road.jpg` and `1-quattro.jpg` added, `2-pawel-czerwinski.jpg` / `3-milad-fakurian.jpg` dropped, the rest shifted up, `4-omakub.jpg` added.
  - **`tte` → `ttfx`** (upstream `4e31b61a`): new `packages/ttfx.nix` (Rust, `omacom-io/ttfx` v0.3.1) replaces `packages/terminaltexteffects.nix`. The binary is unwrapped, so `pgrep -x ttfx` works and `omarchy-screensaver` no longer needs the Nix PID-guard deviation — it is now upstream verbatim.
  - **`gnome-calculator` → `omacalc`** (new `packages/omacalc.nix`, Qt 6 / qmake, `omacom-io/omacalc` v0.2.2 + a desktop entry, which upstream's qmake build does not install). `SUPER + CTRL + Q` and `XF86Calculator` bind to `omacalc` in the vendored lua.
  - **Kvantum dropped** (upstream `e39a275f`): `QT_STYLE_OVERRIDE` removed from the Hyprland env set and both `qtstyleplugin-kvantum` packages removed. Qt falls back to Fusion and now follows the theme via `QT_QPA_PLATFORMTHEME=gtk3`.
  - **herdr** ships alongside tmux: `pkgs.herdr` + the vendored `config/herdr/config.toml`, `default/bash/fns/herdr`, and the `omarchy-{launch-terminal-herdr,menu-herdr-keybindings,refresh-herdr,restart-herdr}` scripts. `omarchy-tmux-alert` is gone upstream; tmux alerts now go through `omarchy-shell -q omarchy.indicators refresh`.
  - **New user units**, all previously missing on Nix: `omarchy-sleep-lock` (locks before suspend — this one predates the sync and simply was never ported), `omarchy-fcitx5` (quattro moved fcitx5 out of the Hyprland autostart), `omarchy-crash-watch` (crash announcements + AI diagnosis, gated on the `crash-capture-off` toggle).
  - **systemd-oomd** (`modules/nixos/tuning.nix`): `settings.OOM` carries upstream's 50% / 20s thresholds, and `systemd.user.slices."app"` gets the `ManagedOOMMemoryPressure=kill` / `ManagedOOMSwap=kill` drop-in. Root/system/user slices stay off deliberately — only `app.slice` is a kill candidate, which keeps the compositor (`session.slice`) structurally ineligible. `environment.etc."systemd/user/app.slice.d/…"` does NOT work: NixOS owns `/etc/systemd/user` as a single entry, so the etc builder fails with a permission error.
  - **Agent skills** (`default/agents/skills/`) vendored and deployed, plus a `linkOmarchyAgentSkills` activation script that reproduces `omarchy-provision-user`'s symlinks into `~/.agents`, `~/.claude`, `~/.codex`, `~/.pi/agent`. `omarchy-agent-crash` reads `diagnose-crash/SKILL.md` from there.
  - **New packages**: `ddcutil` (external-monitor brightness), `vips` (parallel image-picker thumbnails), `qrencode` + `zbar` (Wi-Fi share card, QR capture), and a `python3.withPackages [pygobject3]` — the python scripts in `bin/` run `#!/usr/bin/env python3` (their `#!/usr/bin/python3` shebangs were rewritten; that path does not exist on NixOS) and `omarchy-file-select` needs `gi`. It had never worked before.
  - **New hardware toggle** `omarchy.hardware.apple_brcmfmac_supplicant.enable`: the Broadcom Wi-Fi WPA-handshake quirk, which upstream widened from T2 Macs to every Mac whose Wi-Fi brcmfmac drives.
  - **sudo**: `passwd_tries=10` and a passwordless `timedatectl set-timezone *` for the timezone picker. quattro dropped the `tzupdate` NOPASSWD (it took a URL and ran as root); we never had it.
  - **SSH keepalives** (`programs.ssh.extraConfig`, 15s/3/10s) so a dropped connection is noticed in under a minute.
  - **iwd drift closed.** We had set `networking.wireless.iwd.enable` + `networkmanager.wifi.backend = "iwd"` in January 2026 so the `impala` TUI worked, back when Omarchy still used iwd. Upstream left iwd in `b19dc7ea` (May 21 2026) and `omarchy-upgrade-to-quattro` retires the `iwd` + `impala` pair together; we missed it at the last two syncs. NetworkManager now runs on its default wpa_supplicant backend, `impala` is gone, and the orphaned `bin/omarchy-launch-wifi` (its only caller, unreferenced by any menu or binding since the shell's network panel replaced it) is deleted. This mattered beyond parity: `omarchy-network-{password,qr,band}` read the passphrase with `nmcli --show-secrets`, and under the iwd backend iwd owns the credentials, so the new Wi-Fi share card had nothing to render. **Saved Wi-Fi credentials do not migrate** — iwd keeps them in `/var/lib/iwd`, and networks must be re-entered once in NetworkManager.
  - **Two vendored files were silently truncated** at an earlier sync and are now whole again: `default/bash/completions` had lost the entire `omarchy:args` completion block and `-o default`; `default/bash/fns/tmux` had lost `tds`. Also deleted `default/bash/fns/{aliases,transcoding}` — upstream dropped them, and our stale `fns/aliases` was sourced *after* `default/bash/aliases` and quietly overrode it.
  - **bin/**: 64 scripts bulk-updated, 3 renamed (`-setup-system`→`-apply-system`, `-first-run`→`-provision-first-run`, `-finalize-user`→`-provision-user`), 3 deleted upstream (`-bar-plugin`, `-plugin`, `-tmux-alert`), 48 new ones vendored (agent/usage collectors, plugin enable/disable/list, network band/password/QR, provisioning, factory reset, update helpers, crash capture, disk speed test, herdr, …). A further 16 were referenced by the menu or by other scripts but had never been vendored at all (`-hw-nvidia`, which `default/hypr/nvidia.lua` now calls, `-launch-terminal`, `-menu-emoji`, `-restart-{audio,helix,opencode}`, `-hw-display`, `-capture-screenrecording-with-webcam`, `-drive-password`, `-toggle-hybrid-gpu`, `-windows-vm`, `-update-time`, `-webapp-remove-all`, `-hibernation-{available,setup}`, `-launch-battlenet`).
  - **Personal config pushed out to the user's nixos-config.** The vendored trees now differ from upstream in exactly two files, both genuine Nix deviations: `default/bash/{rc,envs}` (there is no `/usr/share/omarchy` to bootstrap from). Everything else that had drifted was one person's preference sitting in a project other people consume:
    - `default/voxtype/config.toml` carried a personal model choice, `initial_prompt` and `[text].replacements`. Restored to upstream; new `omarchy.voxtype.config_file` option seeds the file from a path of your own instead.
    - The workspaces 11-20 pair (`default/hypr/bindings/tiling.lua` + `shell/plugins/bar/widgets/Workspaces.qml`) is now `omarchy.shell.workspace_count` (default 10 = upstream), which `omarchy-shell.nix` substitutes into the shell tree at build time. The bindings themselves belong in `wayland.windowManager.hyprland.extraConfig`. Patching at build time rather than forking the QML keeps re-vendoring a plain overwrite.
    - `bin/omarchy-fix-usb-audio` hard-coded one Elgato Wave 3 serial number. Deleted — nothing referenced it, and the user's nixos-config already had a better `fix-wave3`.
  - **Fixed the HM→Lua bind bridge dropping descriptions.** `mkBindFrom` only routed `exec` binds through `o.bind`; every other dispatcher went straight to `hl.bind`, which takes no description. Any `bindd` a user wrote for `workspace`, `movetoworkspace`, and so on was silently missing from the keybindings menu (`SUPER + CTRL + K`). Described binds now go through `o.bind` whatever the dispatcher.
  - **Nix deviations kept**: `omarchy-plymouth-{set,reset}`, `omarchy-setup-security-fingerprint` / `-remove-security-fingerprint` (enrolment-only; PAM is declarative), `omarchy-restart-terminal`, the `internal_output_disabled` guard in `omarchy-hyprland-monitor-clamshell`, `default/bash/{rc,envs}`.
  - **Not ported (unchanged policy)**: Arch lifecycle (`omarchy-pkg-*`, `-refresh-*`, `-update-*` helpers, `-install-*` / `-remove-*` installers), migrations, `default/{pacman,limine,libalpm,snapper}`, the T2-Mac `linux-t2` quirks, `install/config/ssh-command-path.sh` (pam_env `PATH` for mise shims — no Nix analogue), and the `yt-dlp` Chromium extension (a gap that predates this sync). WhatsApp Slim **was** added.
- **Previous baseline**: `quattro` @ **`4d93ad58`**, synced July 27 2026 (384 commits from `af828481`). Highlights:
  - **Themes re-rendered from upstream `colors.toml`.** quattro finished the move to generating every per-theme app config from `colors.toml` + `default/themed/*.tpl` (it deleted the checked-in `neovim.lua`/`vscode.json`/`btop.theme`/`waybar.css` copies). Our themes had **no `colors.toml` at all**, so v4 consumers of it (`omarchy-theme-color`, `shell.toml`, `gum_env.lua`, per-theme `hyprland.lua`, `keyboard.rgb`) were dead. Fixed by running upstream's own `omarchy-theme-set-templates` **offline**, once per theme, and checking in the result — the Nix architecture (pre-rendered `config/themes/<theme>/`) is unchanged, but the content is now upstream's. `theme-generator.nix` no longer synthesises `foot.ini`; upstream renders it. **Repeat this at each sync** (recipe below).
  - **New Lupine theme** (light): rendered like the rest, plus a `lupine` base16 scheme in `custom-base16-schemes.nix`, a `themes.nix` entry, a `config.nix` enum entry, and a hand-written `zellij.kdl` (upstream ships no zellij template).
  - **Hyprland 0.55.3 → 0.56.0.** quattro retuned every opacity value for 0.56's corrected alpha premultiplication (hyprwm/Hyprland#14403), so the vendored `default/hypr` looks wrong on 0.55.
  - **shell/ re-vendored wholesale** (was a pristine copy of baseline). Launcher merged into the menu (`SUPER+SPACE` is now `omarchy-menu toggle`; `SUPER+ALT+SPACE` is gone), clock got a calendar popup panel (`SUPER+CTRL+ALT+D`), notification-centre and tmux-alert bar widgets extracted, nightlight moved to a first-party service, `quickshell kill` replaces process-killing.
  - **`omarchy-restart-shell` no longer needs the Nix `pkill -f` deviation** — upstream now uses `quickshell kill --any-display`, which our rolling quickshell pin supports (verified). Deviation dropped.
  - **bin/**: 85 scripts bulk-updated (they matched baseline exactly), 4 renamed (`-shell-bar-text-color`→`-bar-text-color`, `-capture-text-extraction`→`-capture-text`, `-dev-benchmark`→`-dev-benchmark-cli`, `-config-direct-boot`→`-setup-direct-boot`), 4 deleted upstream, 30 new runtime scripts vendored (audio tuning, bar plugin, webcam resize, display text size, hw probes, tmux alert, Taildrop send/receive, weather location, …). `omarchy-plymouth-{set,reset}` keep their Nix guards.
  - **Fingerprint setup/remove re-Nix-flavoured.** The vendored copies had drifted back to upstream and were sed-editing `/etc/pam.d/{sudo,polkit-1}` — on NixOS that is overwritten on rebuild and can lock out sudo. They are enrolment-only again; the PAM side (including quattro's new **lid-state gate**, and polkit fingerprint) is declarative in `modules/nixos/fido2.nix`.
  - **Fixed a latent `fido2.nix` bug**: `sudo_auth` set `security.pam.services.sudo.text`, which *replaces* the generated stack — it dropped the account/session/password lines (leaving sudo unusable) and silently discarded any fprintd rules. Now uses `u2fAuth`. Verified stack order: u2f → clamshell gate → fprintd → pam_unix.
  - **New `modules/nixos/tuning.nix`**: zram (zstd, ram-sized, pri 100), `zswap.enabled=0`, the vm.* reclaim sysctls, `InhibitDelayMaxSec=15` logind drop-in, NetworkManager `wifi.powersave=2`.
  - **Copy URL rewritten** to a native-messaging host (`omarchy-chromium-copy-url-host`) that owns the clipboard write and toast; the extension manifest's `key` is now vendored (the host's `allowed_origins` pins that extension ID). Registered via a home activation script running upstream's `omarchy-install-chromium-copy-url`.
  - **New `modules/home-manager/audio-tuning.nix`**: per-laptop speaker tunings (`default/audio/**`) plus the filter-chain unit with a Nix `ExecStart`, and the Taildrop receiver as a home-manager user service gated on `tailscale` being present.
  - Arabic font selection (Naskh over Nastaliq, incl. the Chromium/Electron last-resort rule) as `xdg.configFile` fontconfig; print-queue applet autostart suppressed; `EDITOR` export and the `mup`/`opencode --auto` alias changes in `default/bash`.
  - Bindings/input needed **no Nix work** — they come from the re-vendored `default/hypr/*.lua` (incl. the non-Latin `us,`-prefix `kb_layout` logic and `shift:both_capslock`).

  **Re-rendering the themes at sync time:**
  ```bash
  git -C ../omarchy worktree add /tmp/omarchy-quattro origin/quattro
  export OMARCHY_PATH=/tmp/omarchy-quattro PATH="/tmp/omarchy-quattro/bin:$PATH"
  # for each theme: copy themes/<t> to a scratch dir, point
  # ~/.local/state/omarchy/current/next-theme at it, run omarchy-theme-set-templates,
  # then copy the result over config/themes/<t> (keep our zellij.kdl + light.mode).
  ```
- **Previous baseline**: `quattro` @ **`af828481`**, synced July 5 2026 (23 commits from `6ef0c019`): shared region picker `omarchy-capture-region` (screenshot + recording, Return = fullscreen, rotated monitors), plugin manager rewritten to plain git (`omarchy-plugin{,-catalog,-clone,-validate}` added; `-add/-remove/-source/-update` and `omarchy-config-shell-bar` deleted; new `omarchy-bar` owns bar config), `omarchy-shell` IPC via `qs ipc call`, clipboard watchers under `setpriv --pdeathsig`, notification history replay, shared `omarchy-theme-color` resolver, tmux window titles (`config/tmux/tmux.conf` re-vendored in full — it had lagged), simplified `omarchy-restart-shell` (kept the Nix `pkill -f .quickshell-wrapped` deviation). `test/` + `docs/` and the Arch-only `*-service-{dropbox,tailscale}` installers not vendored, as before.
- **Previous baseline**: re-synced from `omarchy-4` (June 7) onto **`quattro`** on June 30 — 246 commits: re-vendored `shell/` + `default/{hypr,omarchy,themed}` + `bin` (11 new / 82 updated / 4 removed), adopted `bootstrap.lua` (inlined with a HOME fallback — `OMARCHY_PATH` is NOT in Hyprland's parse env), and migrated `current/theme` to `~/.local/state/omarchy/current/theme`.
- **omarchy-nix sync baseline**: `main` is at Omarchy `dev` `9cf1852` (v3.8.2 + 2 commits).

Re-measure before each work session:
```bash
cd ../omarchy && git fetch origin quattro:refs/remotes/origin/quattro
git log -1 --format='%h %ci' origin/quattro
git rev-list --count ed7bae4a..origin/quattro   # delta since last port baseline
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

## HM→Lua bind bridge: dispatcher names (August 23, 2026)
The bridge in `modules/home-manager/hyprland.nix` used to emit
`hl.dsp.<dispatcher>(args)` for whatever word a `bind*` line names. The v4 lua
API namespaced or renamed most classic hyprlang dispatchers, so that form
produced lua that throws at config load and left the bind silently dead —
`hl.dsp.workspace` is a *table* (`toggle_special`, `move`, `rename`,
`change_id`, `swap_monitors`), and `movetoworkspace{,silent}` do not exist under
any name. Identical in the 0.55 and 0.56 stubs, so it was never a version skew.
A `luaDispatchers` table now translates the dispatchers whose lua form upstream
demonstrates in `default/hypr/bindings/*.lua`; everything else keeps the generic
form, which is correct for the dispatchers the API left callable at the top
level (`focus`, `layout`, `exec_cmd`, `dpms`, `submap`, `global`, `pass`, …).

Found because a plain `bindd = SUPER, F1, …, workspace, 11` second workspace
bank rendered as `hl.dsp.workspace("11")` and put Hyprland's error overlay on
screen at `hm.lua:19`.

## Known follow-ups (quattro)
- ~~`solitude` and `last-horizon` unported~~ — done (commit `00ec53de`), rendered the same way as Lupine.
- **Arch lifecycle scripts remain vendored verbatim** and are Arch-only in practice: `omarchy-update*`, `omarchy-channel-*`, `omarchy-migrate*`, `omarchy-dev-*`, `omarchy-setup-system`, `omarchy-upgrade-to-quattro`, `omarchy-remove-launcher-entry` (uses `pacman -Qqo`). Kept for name parity; `nixos-rebuild` is the real path.
- **`omarchy-setup-lock` not vendored** — it writes `/etc/pam.d/omarchy-lock-password`, which `modules/nixos/system.nix` already provides declaratively.
- **Window-border theming is build-time only.** Runtime theme switches recolor foot/terminals + shell, but not Hyprland borders (our generated `hypr.looknfeel` sets borders from the build-time base16; quattro loads `require_optional("omarchy.current.theme.hyprland")`). To make borders follow runtime switches, generate a per-theme `hyprland.lua` (border colors) into each theme dir and stop hard-setting borders in `hypr.looknfeel`.
- v4 `omarchy-theme-set` shells out to helpers we don't ship (`omarchy-restart-helix/-opencode`, `-theme-set-pi`) — harmless "command not found" noise. (`-theme-set-templates` and `-theme-set-tmux` are now vendored.)
- ~~`tensaku` is not packaged~~ — done: `packages/tensaku.nix` builds v0.28.0 from source (mirrors packaging/aur-git/PKGBUILD) and replaces `satty` in systemPackages, as upstream did in quattro.

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
Validated end-to-end: a real `nixos-rebuild build` of a downstream config
generates an `hm.lua` carrying its `kb_variant` plus all five of its custom
binds (incl. a `binddr` voxtype-stop as `{ release = true }`) with correct
shell-in-lua escaping.

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
(`hyprland/bindings.nix`, `omarchy-shell.nix`) and dry-build clean against a
real downstream config.

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
