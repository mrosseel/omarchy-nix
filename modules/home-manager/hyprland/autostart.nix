{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  wayland.windowManager.hyprland.settings = {
    exec-once =
      [
        "wl-clip-persist --clipboard regular & clipse -listen"
        "omarchy-powerprofiles-init"
        "uwsm-app -- omarchy-hyprland-monitor-watch"

        # "dropbox-cli start"  # Uncomment to run Dropbox
      ]
      # Background, polkit agent and waybar are owned by omarchy-shell under
      # Omarchy 4; only launch them on the classic (non-shell) stack.
      ++ lib.optionals (!cfg.shell.enable) [
        "uwsm-app -- swaybg -i ~/.config/omarchy/current/background -m fill"
        "systemctl --user start hyprpolkitagent"
        "pkill -x waybar; uwsm-app -- waybar"
      ];

    exec = lib.optionals (!cfg.shell.enable) [
      "pkill -SIGUSR2 waybar"
    ];
  };
}
