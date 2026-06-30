inputs: {
  config,
  pkgs,
  lib,
  ...
}: let
  packages = import ../packages.nix {inherit pkgs config lib;};

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
    (import ./theme-generator.nix inputs)
  ];

  home.file = {
    ".local/share/omarchy/bin" = {
      source = ../../bin;
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
    ".config/omarchy/screensaver" = {
      source = ../../config/screensaver;
      recursive = true;
    };
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
        .${config.omarchy.terminal}
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
    ".local/share/omarchy/default/hypr" = {
      source = ../../default/hypr;
      recursive = true;
    };
    ".local/share/omarchy/default/themed" = {
      source = ../../default/themed;
      recursive = true;
    };
    # omarchy-shell menu definition + launcher hides (the shell menu plugin reads
    # $OMARCHY_PATH/default/omarchy/omarchy-menu.jsonc; missing = "Nothing here yet").
    ".local/share/omarchy/default/omarchy" = {
      source = ../../default/omarchy;
      recursive = true;
    };
    # Per-terminal screensaver configs. omarchy-launch-screensaver loads
    # $OMARCHY_PATH/default/<terminal>/screensaver* for whatever xdg-terminal-exec
    # resolves as default; missing = ghostty/foot/etc. "error opening" on launch.
    ".local/share/omarchy/default/ghostty" = {
      source = ../../default/ghostty;
      recursive = true;
    };
    ".local/share/omarchy/default/alacritty" = {
      source = ../../default/alacritty;
      recursive = true;
    };
    ".local/share/omarchy/default/foot" = {
      source = ../../default/foot;
      recursive = true;
    };
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
  # toggle ON (0 gaps, square single windows). voxtype.lua carries the F9
  # dictation binds, so seed it only when voxtype is enabled.
  home.activation.seedHyprToggles = lib.hm.dag.entryAfter ["writeBoundary"] ''
    src="$HOME/.local/share/omarchy/default/hypr/toggles"
    dst="$HOME/.local/state/omarchy/toggles/hypr"
    mkdir -p "$dst"
    [ -e "$dst/flags.lua" ] || cp "$src/flags.lua" "$dst/flags.lua" 2>/dev/null || true
    ${lib.optionalString config.omarchy.voxtype.enable ''
      [ -e "$dst/voxtype.lua" ] || cp "$src/voxtype.lua" "$dst/voxtype.lua" 2>/dev/null || true
    ''}
    # One-time cleanup of stale v3 .conf toggles from earlier builds.
    rm -f "$dst"/*.conf 2>/dev/null || true
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
