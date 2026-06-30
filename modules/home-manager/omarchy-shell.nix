{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  # Omarchy 4 desktop shell. The whole desktop is a single long-running
  # Quickshell instance (omarchy-shell) that hosts the bar, launcher, menu,
  # notifications, OSD, lock and polkit as plugins under $OMARCHY_PATH/shell —
  # replacing waybar/walker/mako/swayosd/hyprlock as the port matures.
  # WIP: gated off by default. See OMARCHY4-PORT.md.
  config = lib.mkIf cfg.shell.enable {
    home.packages = [pkgs.quickshell];

    # Deploy the upstream Quickshell tree verbatim to $OMARCHY_PATH/shell and
    # the default shell.json to $OMARCHY_PATH/config/omarchy/shell.json,
    # mirroring Omarchy's install of repo shell/ -> /usr/share/omarchy/shell.
    home.file = {
      ".local/share/omarchy/shell" = {
        source = ../../shell;
        recursive = true;
      };
      ".local/share/omarchy/config/omarchy/shell.json".source = ../../config/omarchy/shell.json;
    };

    wayland.windowManager.hyprland = {
      # Upstream default/hypr/autostart.lua launches the shell with:
      #   quickshell -n -p $OMARCHY_PATH/shell
      settings.exec-once = [
        "quickshell -n -p $OMARCHY_PATH/shell"
      ];

      # Layer/window rules for the Quickshell surfaces, translated from
      # upstream default/hypr/apps/omarchy-shell.lua.
      extraConfig = ''
        # Keep the bar instant: no layer-shell fade/slide animation.
        layerrule = noanim, omarchy-bar
        layerrule = animation none, omarchy-bar

        # Launcher / image selector / emojis / clipboard / keyboard panels pop
        # without compositor layer fades (they keep their own QML opacity).
        layerrule = noanim, ^(omarchy-menu|omarchy-launcher|omarchy-image-selector|omarchy-emojis|omarchy-clipboard|omarchy-keyboard-panel)$
        layerrule = animation none, ^(omarchy-menu|omarchy-launcher|omarchy-image-selector|omarchy-emojis|omarchy-clipboard|omarchy-keyboard-panel)$

        # Dev gallery is the shell workbench: open it maximized.
        windowrule = maximize, match:class ^(org.quickshell)$, match:title ^(Omarchy shell – dev gallery)$
      '';
    };
  };
}
