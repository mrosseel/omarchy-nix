{...}: {
  # Mirrors Omarchy 4 default/hypr/autostart.lua. The shell itself
  # (quickshell) is launched by omarchy-shell.nix; the bar/launcher/menu/
  # notifications/osd/lock/polkit/background all live inside it, so nothing
  # for waybar/swaybg/mako/swayosd/hyprpolkitagent is started here.
  wayland.windowManager.hyprland.settings.exec-once = [
    "uwsm-app -- fcitx5 --disable notificationitem"
    "omarchy-powerprofiles-init"
    "uwsm-app -- omarchy-hyprland-monitor-watch"
    "uwsm-app -- udiskie --automount --notify --no-tray"
    "wl-clip-persist --clipboard regular & clipse -listen"

    # "dropbox-cli start"  # Uncomment to run Dropbox
  ];
}
