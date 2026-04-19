{
  config,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      # "hypridle & mako & waybar & fcitx5"
      # "waybar"
      "uwsm-app -- swaybg -i ~/.config/omarchy/current/background -m fill"
      "systemctl --user start hyprpolkitagent"
      "wl-clip-persist --clipboard regular & clipse -listen"
      "pkill -x waybar; uwsm-app -- waybar"
      "uwsm-app -- swayosd-server"
      "omarchy-powerprofiles-init"

      # "dropbox-cli start"  # Uncomment to run Dropbox
    ];

    exec = [
      "pkill -SIGUSR2 waybar"
    ];
  };
}
