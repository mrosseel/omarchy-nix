{
  config,
  pkgs,
  lib,
  ...
}: {
  # Create state directory structure
  home.file.".config/omarchy/current/.keep" = {
    text = "";
  };

  # Auto-start swaybg with first wallpaper from current theme
  # omarchy-bg-next reads from ~/.config/omarchy/current/theme/backgrounds/
  # Retired under Omarchy 4: the shell's background plugin owns the wallpaper.
  wayland.windowManager.hyprland.settings.exec-once = lib.optionals (!config.omarchy.shell.enable) [
    "omarchy-bg-next"
  ];
}
