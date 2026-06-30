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
  home.packages = [quickshellPkg];

  # Deploy the upstream Quickshell tree to $OMARCHY_PATH/shell and the default
  # shell.json to $OMARCHY_PATH/config/omarchy/shell.json. The quickshell
  # autostart + the layer/window rules live in the vendored Lua framework
  # (default/hypr/autostart.lua, default/hypr/apps/omarchy-shell.lua).
  home.file = {
    ".local/share/omarchy/shell".source = shellTree;
    ".local/share/omarchy/config/omarchy/shell.json".source = ../../config/omarchy/shell.json;
  };
}
