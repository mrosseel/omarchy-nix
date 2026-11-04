inputs: {
  config,
  pkgs,
  lib,
  osConfig ? {},
  ...
}: let
  packages = import ../packages.nix {inherit pkgs config lib;};

  # The fcitx5 with the input method addons, from modules/packages.nix. A
  # NixOS i18n.inputMethod setup takes precedence when the user has one.
  fcitx5Package =
    if (osConfig.i18n.inputMethod.package or null) != null
    then osConfig.i18n.inputMethod.package
    else packages.fcitx5;

  themes = import ../themes.nix;
  customSchemes = import ../custom-base16-schemes.nix;

  # Light theme detection logic
  lightModeFilePath = "${config.home.homeDirectory}/.config/omarchy/theme/light.mode";
  isLightModeEnabled = config.omarchy.light_theme_detection.enable && builtins.pathExists lightModeFilePath;

  # Determine effective theme
  effectiveTheme =
    if isLightModeEnabled && builtins.hasAttr config.omarchy.theme config.omarchy.light_theme_detection.light_theme_mappings
    then config.omarchy.light_theme_detection.light_theme_mappings.${config.omarchy.theme}
    else config.omarchy.theme;

  selectedTheme = themes.${effectiveTheme};

  # Get color scheme - use custom scheme if marked, otherwise use nix-colors
  selectedColorScheme =
    if selectedTheme ? custom-scheme && selectedTheme.custom-scheme
    then customSchemes.${selectedTheme.base16-theme}
    else inputs.nix-colors.colorSchemes.${selectedTheme.base16-theme};

  # Install and Remove rows kept in the menu. The other rows call the pacman
  # helpers omarchy-pkg-add and omarchy-pkg-present, which do not exist on
  # NixOS. These rows only write files in $HOME, so they work here.
  keptMenuRows = [
    "install.style"
    "install.style.theme"
    "install.style.background"
    "install.webapp"
    "install.tui"
    "remove.theme"
    "remove.webapp"
    "remove.tui"
  ];

  # The vendored menu file stays a copy of upstream. The filter runs at build
  # time, so an upstream sync does not add the pacman rows again. The build
  # fails when a kept row is no longer in the upstream file.
  omarchyMenuDir = pkgs.runCommand "omarchy-default-menu" {} ''
    mkdir -p $out
    cp --no-preserve=mode ${../../default/omarchy}/* $out/
    ${pkgs.gawk}/bin/awk -v keep="${lib.concatStringsSep " " keptMenuRows}" '
      BEGIN { n = split(keep, k, " "); for (i = 1; i <= n; i++) kept[k[i]] = 1 }
      match($0, /^  "(install|remove)\.[^"]*"/) {
        id = substr($0, RSTART + 3, RLENGTH - 4)
        if (!(id in kept)) next
        seen[id] = 1
      }
      { print }
      END {
        for (id in kept) if (!(id in seen)) { print "omarchy-menu.jsonc: kept row " id " is missing" > "/dev/stderr"; failed = 1 }
        exit failed
      }
    ' ${../../default/omarchy/omarchy-menu.jsonc} > $out/omarchy-menu.jsonc
  '';
in {
  imports = [
    (import ./hyprland.nix inputs)
    (import ./ghostty.nix)
    (import ./alacritty.nix)
    (import ./kitty.nix)
    (import ./foot.nix)
    (import ./btop.nix)
    (import ./direnv.nix)
    (import ./git.nix)
    (import ./starship.nix)
    (import ./vscode.nix)
    (import ./zoxide.nix)
    (import ./zsh.nix)
    ./chromium.nix
    ./brave.nix
    ./xdph.nix
    ./hyprland-preview-share-picker.nix
    ./hyprsunset.nix
    ./desktop-entries.nix
    (import ./omarchy-shell.nix inputs)
    ./light-theme-monitor.nix
    ./battery-monitor.nix
    ./voxtype.nix
    ./fonts.nix
    ./imv.nix
    ./evince.nix
    ./zellij.nix
    ./tmux.nix
    ./audio-tuning.nix
    ./owe.nix
    (import ./theme-generator.nix inputs)
  ];

  home.file = {
    ".local/share/omarchy/bin" = {
      source = ../../bin;
      recursive = true;
    };
    # The steps omarchy-provision-first-run runs at first login. Without them
    # every step fails, first-run never marks itself done, and it runs again
    # at every login. See install/user/first-run for the Nix changes.
    ".local/share/omarchy/install/user/first-run" = {
      source = ../../install/user/first-run;
      recursive = true;
    };
    ".config/omarchy/branding" = {
      source = ../../config/branding;
      recursive = true;
    };
    # Deploy logo.txt + icon.txt to ~/.local/share/omarchy/ (read-only source).
    # omarchy-branding-{screensaver,about} reset reads from $OMARCHY_PATH/.
    ".local/share/omarchy/logo.txt".source = ../../config/branding/logo.txt;
    ".local/share/omarchy/icon.txt".source = ../../config/branding/icon.txt;
    ".config/omarchy/webapp-icons" = {
      source = ../../config/webapp-icons;
      recursive = true;
    };
    # Terminal preference for xdg-terminal-exec, generated from omarchy.terminal so
    # the screensaver and any xdg-terminal-exec launch use the configured terminal
    # (previously hardcoded to ghostty, which is why the screensaver ran ghostty).
    ".config/xdg-terminals.list".text = ''
      # Terminal emulator preference order for xdg-terminal-exec
      # Generated from omarchy.terminal
      ${
        {
          ghostty = "com.mitchellh.ghostty.desktop";
          alacritty = "Alacritty.desktop";
          kitty = "kitty.desktop";
          foot = "foot.desktop";
        }
        .${
          config.omarchy.terminal
        }
      }
    '';
    # Disable bluetooth GUI tray apps - we use bluetui TUI instead
    ".config/autostart/blueberry-tray.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
    ".config/autostart/blueman.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
    # Shipped user configs (upstream copies these from config/ into ~/.config
    # at install time). The pristine copy lives under $OMARCHY_PATH/config so
    # omarchy-refresh-config can restore it; the activation block below seeds
    # a writable copy into ~/.config once, never overwriting user edits.
    ".local/share/omarchy/config/herdr/config.toml".source = ../../config/herdr/config.toml;
    ".local/share/omarchy/config/opencode/opencode.json".source = ../../config/opencode/opencode.json;
    ".local/share/omarchy/config/opencode/cli.json".source = ../../config/opencode/cli.json;
    # Omarchy-Nix deviation: the shipped dictation default is voxtype, not
    # superwhisper. Superwhisper is proprietary and dictates in the cloud, so
    # it is opt-in through omarchy.superwhisper.enable.
    ".local/share/omarchy/config/omarchy/defaults/dictation".source = ../../config/omarchy/defaults/dictation;
    # Fcitx5 defaults: the hotkeys, the clipboard paste keys, and no override of
    # the keyboard layout (#760). omarchy-input-method reads these copies under
    # $OMARCHY_PATH/config/fcitx5 and merges them into the user's files.
    ".local/share/omarchy/config/fcitx5" = {
      source = ../../config/fcitx5;
      recursive = true;
    };
    # Links in every app go through omarchy-browser.desktop, which hands them
    # to the running default browser and focuses it. XDG reads this
    # Hyprland-specific list before mimeapps.list, where the browser itself
    # stays.
    ".config/hyprland-mimeapps.list".source = ../../config/hyprland-mimeapps.list;
    ".local/share/applications/omarchy-browser.desktop".source = ../../applications/omarchy-browser.desktop;
    # Upstream config/autostart/org.fcitx.Fcitx5.desktop: the fcitx5 package
    # ships an XDG autostart entry, and that instance grabs the D-Bus name
    # first, leaving omarchy-fcitx5.service in an endless restart loop.
    ".config/autostart/org.fcitx.Fcitx5.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
    # Hide duplicate Brave entry (nixpkgs bug: NoDisplay=true is outside [Desktop Entry] section)
    ".local/share/applications/com.brave.Browser.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';
    ".local/share/omarchy/default/bash" = {
      source = ../../default/bash;
      recursive = true;
    };
    ".local/share/omarchy/version".source = ../../default/omarchy-version;
    # Agent skills. omarchy-agent-crash reads diagnose-crash/SKILL.md from here,
    # and the omarchy skill is linked into every agent's skills dir below.
    ".local/share/omarchy/default/agents" = {
      source = ../../default/agents;
      recursive = true;
    };
    # Emoji compose sequences included from the seeded ~/.XCompose.
    ".local/share/omarchy/default/xcompose".source = ../../default/xcompose;
    # default/hypr is deployed by hyprland.nix, which patches the titlebars
    # plugin path into it.
    ".local/share/omarchy/default/themed" = {
      source = ../../default/themed;
      recursive = true;
    };
    # omarchy-shell menu definition + launcher hides (the shell menu plugin reads
    # $OMARCHY_PATH/default/omarchy/omarchy-menu.jsonc; missing = "Nothing here yet").
    # The menu has the pacman Install and Remove rows removed (see keptMenuRows).
    ".local/share/omarchy/default/omarchy" = {
      source = omarchyMenuDir;
      recursive = true;
    };
    ".local/share/omarchy/default/alacritty" = {
      source = ../../default/alacritty;
      recursive = true;
    };
    # Translation catalogs. omarchy-i18n, omarchy-language and the shell
    # (Commons/I18n.qml) read $OMARCHY_PATH/default/i18n.
    ".local/share/omarchy/default/i18n" = {
      source = ../../default/i18n;
      recursive = true;
    };
    # Input method helpers (omarchy-input-method, omarchy-language, the shell's
    # input indicator) and the Fcitx5 D-Bus activation template.
    ".local/share/omarchy/default/input-methods" = {
      source = ../../default/input-methods;
      recursive = true;
    };
    # omarchy-theme-set-glass imports this into GTK apps for Glassy windows.
    ".local/share/omarchy/default/gtk" = {
      source = ../../default/gtk;
      recursive = true;
    };
    # omarchy-launch-slack runs default/slack/launcher.py.
    ".local/share/omarchy/default/slack" = {
      source = ../../default/slack;
      recursive = true;
    };
    # Session defaults (TERMINAL, EDITOR, HYPRLAND_NO_RT). The uwsm env file
    # below sources this copy.
    ".local/share/omarchy/default/uwsm" = {
      source = ../../default/uwsm;
      recursive = true;
    };
    # Upstream ships default/uwsm/env.d/10-omarchy to /usr/share/uwsm/env.d.
    # The uwsm in nixpkgs (0.23) does not read env.d directories, so this
    # file does the same job from ~/.config/uwsm/env. The env bootstrap is not
    # sourced here: on Nix, OMARCHY_PATH comes from environment.sessionVariables
    # and the omarchy bin dir from environment.extraInit.
    ".config/uwsm/env".text = ''
      # Omarchy session defaults. Override them in ~/.config/uwsm/default.
      . "$HOME/.local/share/omarchy/default/uwsm/default"
      [ -f "$HOME/.config/uwsm/default" ] && . "$HOME/.config/uwsm/default"
    '';
    # Hook sample tree (read-only source under $OMARCHY_PATH); the activation
    # below seeds copies into ~/.config/omarchy/hooks/ so users can rename
    # *.sample to enable a hook.
    ".local/share/omarchy/default/hooks" = {
      source = ../../config/omarchy/hooks;
      recursive = true;
    };
    # Nautilus-python extensions (Send via LocalSend, Transcode) — upstream
    # install/config/nautilus-python.sh copies these to the same location.
    ".local/share/nautilus-python/extensions" = {
      source = ../../default/nautilus-python/extensions;
      recursive = true;
    };
    # WirePlumber drop-ins (Bluetooth A2DP auto-connect) — upstream
    # install/config/hardware/bluetooth.sh deploys this directory.
    ".config/wireplumber/wireplumber.conf.d" = {
      source = ../../default/wireplumber/wireplumber.conf.d;
      recursive = true;
    };
  };
  home.packages = packages.homePackages;

  # Add omarchy bin directory to PATH
  home.sessionPath = [
    "$HOME/.local/share/omarchy/bin"
  ];

  # Seed writable copies of the shipped user configs into ~/.config. These
  # files are rewritten at runtime (by the app itself, by omarchy-input-method,
  # or by omarchy-dictation-use), so a read-only home.file symlink would break
  # them; upstream installs plain copies from /etc/skel. Existing files are
  # never touched — omarchy-refresh-config restores the shipped version on
  # request. This runs after linkGeneration, so the source links exist on the
  # first switch, and the old fcitx5 conf symlinks are gone before the copies
  # take their place.
  home.activation.seedShippedUserConfigs = lib.hm.dag.entryAfter ["linkGeneration"] ''
    for rel in \
      herdr/config.toml \
      opencode/opencode.json \
      opencode/cli.json \
      omarchy/defaults/dictation \
      fcitx5/config \
      fcitx5/conf/clipboard.conf \
      fcitx5/conf/xcb.conf \
      fcitx5/conf/quickphrase.conf \
      fcitx5/conf/wayland.conf \
      fcitx5/conf/pinyin.conf; do
      src="$HOME/.local/share/omarchy/config/$rel"
      dst="$HOME/.config/$rel"
      if [ -e "$src" ] && [ ! -e "$dst" ]; then
        $DRY_RUN_CMD mkdir -p "$(dirname "$dst")"
        $DRY_RUN_CMD cp "$src" "$dst"
        # OpenCode keeps cli.json private (migration 1793565796).
        if [ "$rel" = opencode/cli.json ]; then
          $DRY_RUN_CMD chmod 600 "$dst"
        else
          $DRY_RUN_CMD chmod 644 "$dst"
        fi
      fi
    done
  '';

  # Copy logo.txt/icon.txt to screensaver.txt/about.txt on first use
  # (user-customizable via omarchy-branding-{screensaver,about}).
  home.activation.copyScreensaverTxt = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$HOME/.config/omarchy/branding"
    if [ ! -f "$HOME/.config/omarchy/branding/screensaver.txt" ]; then
      cp "$HOME/.local/share/omarchy/logo.txt" "$HOME/.config/omarchy/branding/screensaver.txt"
    fi
    if [ ! -f "$HOME/.config/omarchy/branding/about.txt" ]; then
      cp "$HOME/.local/share/omarchy/icon.txt" "$HOME/.config/omarchy/branding/about.txt"
    fi
  '';

  # Seed the Hyprland toggle state dir (Omarchy 4: default.hypr.toggles
  # require_all's the *.lua under ~/.local/state/omarchy/toggles/hypr).
  # Seed ONLY the flags.lua keep-file (the dir needs >=1 file). The effect
  # toggles (window-no-gaps, single-window-aspect-ratio, …) are turned on by
  # RUNNING omarchy-toggle, never pre-seeded — seeding them all forced every
  # toggle ON (0 gaps, square single windows).
  home.activation.seedHyprToggles = lib.hm.dag.entryAfter ["linkGeneration"] ''
    src="$HOME/.local/share/omarchy/default/hypr/toggles"
    dst="$HOME/.local/state/omarchy/toggles/hypr"
    mkdir -p "$dst"
    [ -e "$dst/flags.lua" ] || cp "$src/flags.lua" "$dst/flags.lua" 2>/dev/null || true
    # One-time cleanup of stale v3 .conf toggles from earlier builds.
    rm -f "$dst"/*.conf 2>/dev/null || true
    # The Voxtype toggle is obsolete (migration 1784767406). Its F9 binds now
    # come from default/hypr/bindings/dictation.lua for every backend.
    rm -f "$dst/voxtype.lua"
    # A VM usually renders on the CPU, so it starts without animations and
    # with opaque windows (install/user/hardware/vm-no-animations.sh). Upstream
    # does this once at user setup. The done marker keeps it to one time, so
    # omarchy-toggle-animations can turn them back on.
    if [ ! -e "$HOME/.local/state/omarchy/done/vm-no-animations" ]; then
      if ${pkgs.systemd}/bin/systemd-detect-virt --vm --quiet; then
        cp "$src/no-animations.lua" "$src/window-opaque.lua" "$dst/" 2>/dev/null || true
      fi
      mkdir -p "$HOME/.local/state/omarchy/done"
      touch "$HOME/.local/state/omarchy/done/vm-no-animations"
    fi
  '';

  # Seed ~/.config/omarchy/hooks/ with .sample files from the read-only source
  # tree. The user renames *.sample (drops the extension) to enable a hook.
  # Existing files are never overwritten - this is one-shot bootstrap per name.
  home.activation.seedOmarchyHookSamples = lib.hm.dag.entryAfter ["writeBoundary"] ''
    src="$HOME/.local/share/omarchy/default/hooks"
    dst="$HOME/.config/omarchy/hooks"
    if [ -d "$src" ]; then
      while IFS= read -r -d ''' rel; do
        target="$dst/$rel"
        if [ ! -e "$target" ]; then
          mkdir -p "$(dirname "$target")"
          cp "$src/$rel" "$target"
          chmod 755 "$target"
        fi
      done < <(cd "$src" && find . -type f -name '*.sample' -printf '%P\0')
    fi
  '';

  # Seed ~/.XCompose like upstream install/user/xcompose.sh: emoji include +
  # identification sequences. User-owned (Setup > Config > XCompose edits it),
  # never overwritten. %H expands to $HOME in XCompose include paths.
  home.activation.seedXCompose = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -e "$HOME/.XCompose" ]; then
      cp ${pkgs.writeText "XCompose" ''
      # Run omarchy-restart-xcompose to apply changes

      # Include fast emoji access
      include "%H/.local/share/omarchy/default/xcompose"

      # Identification
      <Multi_key> <space> <n> : "${config.omarchy.full_name}"
      <Multi_key> <space> <e> : "${config.omarchy.email_address}"
    ''} "$HOME/.XCompose"
      chmod 644 "$HOME/.XCompose"
    fi
  '';

  # Restart the Omarchy shell after every switch so it picks up the new
  # binaries instead of holding onto a stale /nix/store path. omarchy-restart-shell
  # uses pkill -f (Nix wraps quickshell to comm `.quickshell-wrapped`).
  #
  # Also drop the Qt QML bytecode cache first. Qt keys ~/.cache/quickshell/qmlcache
  # by the QML source path + Qt version, NOT the quickshell version — so a
  # quickshell bump on the same Qt leaves stale bytecode that breaks the shell's
  # JS modules (weather/network Model.js: "X is not a function"). Clearing it on
  # every switch forces a clean recompile against the deployed quickshell.
  home.activation.restartOmarchyShell = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD rm -rf "''${XDG_CACHE_HOME:-$HOME/.cache}/quickshell/qmlcache" 2>/dev/null || true
    if command -v omarchy-restart-shell >/dev/null 2>&1; then
      $DRY_RUN_CMD omarchy-restart-shell 2>/dev/null || true
    fi
  '';

  # Recover internal display when no external monitor is attached at session start.
  # Mirrors upstream config/systemd/user/omarchy-recover-internal-monitor.service.
  systemd.user.services.omarchy-recover-internal-monitor = {
    Unit = {
      Description = "Recover the internal monitor toggle when no external display is connected";
      Before = ["graphical-session-pre.target"];
      ConditionPathExists = "%h/.local/state/omarchy/toggles/hypr/internal-monitor-disable.conf";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "%h/.local/share/omarchy/bin/omarchy-hw-recover-internal-monitor";
    };
    Install.WantedBy = ["graphical-session-pre.target"];
  };

  # Agent skill symlinks. Upstream does this in omarchy-provision-user, which is
  # part of the Arch installer's one-shot user setup. On Nix it is marked done
  # below and does not run.
  # Symlinks (not home.file) because every agent expects a real directory it can
  # walk, and the loop picks up new skills without an edit here.
  home.activation.linkOmarchyAgentSkills = lib.hm.dag.entryAfter ["writeBoundary"] ''
    dirs=("$HOME/.agents/skills" "$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.pi/agent/skills" "$HOME/.gemini/config/skills" "$HOME/.hermes/skills")
    $DRY_RUN_CMD mkdir -p "''${dirs[@]}"
    for skill in "$HOME"/.local/share/omarchy/default/agents/skills/*/; do
      [ -d "$skill" ] || continue
      skill=''${skill%/}
      name=''${skill##*/}
      for dir in "''${dirs[@]}"; do
        $DRY_RUN_CMD ln -sfn "$skill" "$dir/$name"
      done
      for profile in "$HOME"/.hermes/profiles/*/; do
        [ -d "$profile" ] || continue
        $DRY_RUN_CMD mkdir -p "$profile/skills"
        $DRY_RUN_CMD ln -sfn "$skill" "$profile/skills/$name"
      done
    done
  '';

  # Home Manager does the work of omarchy-provision-user: the skill links
  # above, xdg.userDirs below, and the default browser. The script itself
  # cannot finish on Nix, because install/user/all.sh is not shipped. Without
  # its done marker, omarchy-provision-first-run calls it at every login. On
  # the way it runs xdg-user-dirs-update --set, which ignores enabled=False
  # and writes a plain user-dirs.dirs over the Home Manager link. The next
  # switch then stops when the backup of that file already exists.
  home.activation.markOmarchyUserProvisioned = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.local/state/omarchy/done"
    $DRY_RUN_CMD touch "$HOME/.local/state/omarchy/done/finalize-user"
  '';

  # Lock the session before suspend. Mirrors upstream
  # default/systemd/user/omarchy-sleep-lock.service; the monitor holds a delay
  # inhibitor (see modules/nixos/tuning.nix InhibitDelayMaxSec) and locks in it.
  systemd.user.services.omarchy-sleep-lock = {
    Unit = {
      Description = "Lock Omarchy before suspend";
      After = ["dbus.socket" "wayland-session-waitenv.service"];
      Requires = ["dbus.socket"];
      PartOf = ["graphical-session.target"];
      ConditionEnvironment = ["OMARCHY_PATH" "WAYLAND_DISPLAY"];
    };
    Service = {
      Type = "simple";
      ExecStart = "%h/.local/share/omarchy/bin/omarchy-system-sleep-monitor";
      Restart = "always";
      RestartSec = 2;
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  # fcitx5 runs the input methods and turns the Shift + CapsLock compose
  # sequences in ~/.XCompose into text for Wayland clients
  # (default/systemd/user/omarchy-fcitx5.service). The upstream unit also has
  # ConditionPathExists=/usr/bin/fcitx5. It is left out here, because the
  # store path always exists.
  systemd.user.services.omarchy-fcitx5 = {
    Unit = {
      Description = "Fcitx5 input methods and XCompose sequences";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
      # Ordering alone does not stop an SSH session's user manager from starting
      # this; without WAYLAND_DISPLAY fcitx5 comes up unable to reach any client
      # and then blocks the real one at graphical login.
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      Type = "dbus";
      BusName = "org.fcitx.Fcitx5";
      # notificationitem duplicates the tray entry omarchy renders itself.
      # --replace takes the bus name from a fcitx5 started outside the unit.
      ExecStart = "${fcitx5Package}/bin/fcitx5 --replace --disable notificationitem";
      # always, not on-failure: fcitx5 exits 0 when another instance owns its bus
      # name, and a clean exit still leaves the user with no input method.
      Restart = "always";
      RestartSec = 2;
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  # D-Bus activation goes through the unit above
  # (default/input-methods/org.fcitx.Fcitx5.service). Upstream's
  # omarchy-input-method writes this file with Exec=/usr/bin/fcitx5. Here it
  # names the store path, and omarchy-input-method leaves a file that has
  # SystemdService= alone.
  xdg.dataFile."dbus-1/services/org.fcitx.Fcitx5.service".text = ''
    # Installed per-user so D-Bus activation uses the supervised Omarchy unit.
    [D-BUS Service]
    Name=org.fcitx.Fcitx5
    Exec=${fcitx5Package}/bin/fcitx5
    SystemdService=omarchy-fcitx5.service
  '';

  # Bluetooth pairing agent (default/systemd/user/bt-agent.service). The shell
  # panel pairs through non-interactive bluetoothctl, which registers no agent.
  # With no agent, BlueZ turns bonding off, so a pairing connects once but
  # stores no link key and the device fails to reconnect.
  systemd.user.services.bt-agent = {
    Unit = {
      Description = "Bluetooth pairing agent (auto-accept)";
      Documentation = "man:bt-agent(1)";
      ConditionPathIsDirectory = "/sys/class/bluetooth";
      After = ["dbus.socket"];
      Requires = ["dbus.socket"];
    };
    Service = {
      Type = "simple";
      ExecCondition = "${pkgs.systemd}/bin/systemctl is-active --quiet bluetooth.service";
      ExecStart = "${pkgs.bluez-tools}/bin/bt-agent -c NoInputNoOutput";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  # Announce process crashes and offer an AI diagnosis
  # (default/systemd/user/omarchy-crash-watch.service).
  systemd.user.services.omarchy-crash-watch = {
    Unit = {
      Description = "Announce process crashes and offer an AI diagnosis";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
      ConditionEnvironment = "WAYLAND_DISPLAY";
      # Set by omarchy-toggle-crash-capture, so a disabled watcher stays disabled
      # across logins without the unit itself being disabled.
      ConditionPathExists = "!%h/.local/state/omarchy/toggles/crash-capture-off";
    };
    Service = {
      Type = "simple";
      ExecStart = "%h/.local/share/omarchy/bin/omarchy-crash-watch";
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  # XDG user directories (omarchy install/config/user-dirs.sh equivalent)
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    download = "${config.home.homeDirectory}/Downloads";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
    desktop = config.home.homeDirectory;
    publicShare = config.home.homeDirectory;
    templates = config.home.homeDirectory;
    # Adopt the HM >= 26.05 default explicitly; otherwise legacy stateVersion
    # users get a "default has changed" warning at evaluation time.
    setSessionVariables = false;
  };

  colorScheme = selectedColorScheme;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme =
        if isLightModeEnabled
        then "prefer-light"
        else "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    gtk4.theme = null;
    theme = {
      name =
        if isLightModeEnabled
        then "Adwaita"
        else "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    cursorTheme = {
      name =
        if isLightModeEnabled
        then "Bibata-Modern-Classic"
        else "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    name =
      if isLightModeEnabled
      then "Bibata-Modern-Classic"
      else "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
  };

  # TODO: Add an actual nvim config
  programs.neovim = {
    enable = true;
    withRuby = false;
    withPython3 = false;
  };
}
