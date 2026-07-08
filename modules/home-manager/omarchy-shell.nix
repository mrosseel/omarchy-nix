inputs: {
  config,
  pkgs,
  lib,
  ...
}: let
  # Omarchy 4 (quattro) targets rolling quickshell; nixpkgs' 0.3.0 left the
  # background reveal transition + network/weather panels broken. Use the
  # upstream quickshell flake instead of pkgs.quickshell.
  quickshellPkg = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # CRITICAL Nix deviation: deploy the shell tree as a single symlink to a
  # real-file copy, NOT via `home.file recursive = true`. The shell's
  # PluginRegistry discovers plugins with `find <dir> -type f -name manifest.json`,
  # and home-manager's per-file symlinks are `-type l`, so `find -type f` matches
  # nothing → zero plugins load → empty/invisible bar, no launcher, no background.
  # runCommand copies the tree to a store path of real files; the single symlink
  # lets `find -type f` see them. (lua framework under default/hypr is fine as
  # per-file symlinks because lua require() follows symlinks.)
  shellTree = pkgs.runCommand "omarchy-shell-tree" {} ''cp -r ${../../shell} $out'';
in {
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
  home.packages = [quickshellPkg pkgs.gtk3];

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
        OMARCHY_PATH="$HOME/.local/share/omarchy" \
        PATH="${lib.makeBinPath [
          quickshellPkg
          pkgs.procps
          pkgs.hyprland
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
