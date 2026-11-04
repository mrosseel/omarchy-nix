inputs: {
  config,
  pkgs,
  lib,
  ...
}: let
  # Omarchy 4 (quattro) targets rolling quickshell; nixpkgs' 0.3.0 left the
  # background reveal transition + network/weather panels broken. Use the
  # upstream quickshell flake instead of pkgs.quickshell.
  quickshellBase = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Theme backgrounds are webp since upstream a4219f8f, and Qt reads webp only
  # through the qtimageformats plugin. Arch pulls it in as the qt6-imageformats
  # package (upstream added it to omarchy-base.packages in the same change); on
  # Nix it is a separate output that Qt finds only via QT_PLUGIN_PATH. Without
  # it every background, theme preview and lock wallpaper renders blank.
  # Prefixed onto quickshell alone rather than exported session-wide, so no
  # other Qt app is handed a plugin dir from a different Qt build.
  quickshellPkg = pkgs.symlinkJoin {
    name = "quickshell-omarchy";
    paths = [quickshellBase];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/quickshell \
        --prefix QT_PLUGIN_PATH : ${pkgs.qt6.qtimageformats}/lib/qt-6/plugins
      wrapProgram $out/bin/qs \
        --prefix QT_PLUGIN_PATH : ${pkgs.qt6.qtimageformats}/lib/qt-6/plugins
    '';
  };

  # CRITICAL Nix deviation: deploy the shell tree as a single symlink to a
  # real-file copy, NOT via `home.file recursive = true`. The shell's
  # PluginRegistry discovers plugins with `find <dir> -type f -name manifest.json`,
  # and home-manager's per-file symlinks are `-type l`, so `find -type f` matches
  # nothing → zero plugins load → empty/invisible bar, no launcher, no background.
  # runCommand copies the tree to a store path of real files; the single symlink
  # lets `find -type f` see them. (lua framework under default/hypr is fine as
  # per-file symlinks because lua require() follows symlinks.)

  # NixOS has no /usr/share. Two shell files read fixed paths there, so point
  # them at the NixOS locations:
  # - Elsewhen reads zone1970.tab for the coordinates of a zone it cannot
  #   geocode. NixOS puts the tzdata files at /etc/zoneinfo.
  # - The app icon index also scans /usr/share/pixmaps. Nix packages put
  #   pixmaps in share/pixmaps of each XDG data dir, so scan those too. Without
  #   this, apps such as VS Code show no icon in the launcher.
  patchUsrPaths = ''
    substituteInPlace $out/plugins/panels/elsewhen/Panel.qml \
      --replace-fail '/usr/share/zoneinfo/zone1970.tab' '/etc/zoneinfo/zone1970.tab'
    substituteInPlace $out/services/AppLibrary.qml \
      --replace-fail 'do dirs="$dirs $d/icons"; done;' 'do dirs="$dirs $d/icons"; pixmaps="$pixmaps $d/pixmaps"; done;' \
      --replace-fail 'find /usr/share/pixmaps -maxdepth 1' 'find /usr/share/pixmaps $pixmaps -maxdepth 1'
  '';

  shellTree = pkgs.runCommand "omarchy-shell-tree" {} ''
    cp -r ${../../shell} $out
    chmod -R u+w $out
    ${patchUsrPaths}
  '';
in {
  # Upstream now gives each monitor its own block of ten workspaces
  # (default/hypr/monitor-workspaces.lua). The bar shows the monitor's own block
  # and, after a gap, any other workspace that is on that monitor. The old
  # `id <= 10` limit that workspace_count raised is gone, so the option does
  # nothing now.
  warnings = lib.optional (config.omarchy.shell.workspace_count != 10) ''
    omarchy.shell.workspace_count has no effect. The bar now shows every
    workspace on a monitor: its own block of ten first, then the others.
  '';

  # Omarchy 4 desktop shell. The whole desktop is a single long-running
  # Quickshell instance (omarchy-shell) that hosts the bar, launcher, menu,
  # notifications, OSD, lock and polkit as plugins under $OMARCHY_PATH/shell.
  # This is THE desktop on Omarchy 4 — it fully replaces
  # waybar/walker/mako/swayosd/hyprlock/hyprpolkitagent/swaybg.
  #
  # gtk3 provides `gtk-launch`, which the launcher uses to spawn apps
  # (Launcher.qml: `gtk-launch <desktopId>`). It's always present on Arch but not
  # on Nix, so without it EVERY launcher app-launch silently fails ("Launching
  # <app>…" with nothing opening).
  #
  # libxkbcommon provides `xkbcli`. The bar's keyboard layout widget runs
  # `xkbcli list` for the layout names, and omarchy-menu-keybindings (SUPER K)
  # runs `xkbcli compile-keymap`. Arch always has it; Nix does not.
  #
  # inotify-tools provides `inotifywait`. PluginRegistry uses it to reload a
  # plugin when its files change, and InputDevices uses it to see a keyboard or
  # mouse come and go. Upstream lists it in omarchy-base.packages.
  home.packages = [quickshellPkg pkgs.gtk3 pkgs.libxkbcommon pkgs.inotify-tools];

  # Deploy the upstream Quickshell tree to $OMARCHY_PATH/shell and the default
  # shell.json to $OMARCHY_PATH/config/omarchy/shell.json. The quickshell
  # autostart + the layer/window rules live in the vendored Lua framework
  # (default/hypr/autostart.lua, default/hypr/apps/omarchy-shell.lua).
  home.file = {
    ".local/share/omarchy/shell" = {
      source = shellTree;
      # Quickshell watches the resolved store files, not this symlink, so a
      # store-path swap on `home-manager switch` leaves the old instance running
      # stale QML: dead clipboard watcher, missing `shell toggle` IPC, overlays
      # that never load. Restart the shell whenever the tree changes so the new
      # plugins/IPC take effect without a reboot. omarchy-restart-shell imports
      # the session env from the running instance (works from the non-graphical
      # activation context) and pkills every instance before launching one, so
      # it also collapses any accidental duplicate instances. Best-effort: a
      # headless/pre-login switch (no running shell) must not fail activation.
      onChange = ''
        # home-manager-<user>.service has no XDG_RUNTIME_DIR (and sets
        # QT_QPA_PLATFORM=offscreen), so quickshell kill finds no instance
        # sockets and the old shell silently survives the switch.
        export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
        unset QT_QPA_PLATFORM
        OMARCHY_PATH="$HOME/.local/share/omarchy" \
        PATH="${lib.makeBinPath [
          quickshellPkg
          pkgs.procps
          # flake's hyprland (for hyprctl) — pkgs.hyprland would be a second, uncached build
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland
          pkgs.coreutils
          pkgs.findutils
          pkgs.gnused
          pkgs.gnugrep
          pkgs.util-linux
        ]}:$PATH" \
          "$HOME/.local/share/omarchy/bin/omarchy-restart-shell" 2>/dev/null || true
      '';
    };
    ".local/share/omarchy/config/omarchy/shell.json".source = ../../config/omarchy/shell.json;
  };
}
