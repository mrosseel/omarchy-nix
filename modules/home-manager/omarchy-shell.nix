{
  config,
  pkgs,
  lib,
  ...
}: {
  # Omarchy 4 desktop shell. The whole desktop is a single long-running
  # Quickshell instance (omarchy-shell) that hosts the bar, launcher, menu,
  # notifications, OSD, lock and polkit as plugins under $OMARCHY_PATH/shell.
  # This is THE desktop on Omarchy 4 — it fully replaces
  # waybar/walker/mako/swayosd/hyprlock/hyprpolkitagent/swaybg.
  home.packages = [pkgs.quickshell];

  # Deploy the upstream Quickshell tree verbatim to $OMARCHY_PATH/shell and
  # the default shell.json to $OMARCHY_PATH/config/omarchy/shell.json,
  # mirroring Omarchy's install of repo shell/ -> /usr/share/omarchy/shell.
  # The quickshell autostart + the layer/window rules for its surfaces now live
  # in the vendored Lua framework (default/hypr/autostart.lua and
  # default/hypr/apps/omarchy-shell.lua), so nothing Hyprland-side is set here.
  home.file = {
    ".local/share/omarchy/shell" = {
      source = ../../shell;
      recursive = true;
    };
    ".local/share/omarchy/config/omarchy/shell.json".source = ../../config/omarchy/shell.json;
  };
}
