{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  imports = [
    ./autostart.nix
    ./bindings.nix
    ./envs.nix
    ./input.nix
    ./looknfeel.nix
    ./windows.nix
  ];
  wayland.windowManager.hyprland.settings = {
    # Default applications with launch-or-focus
    "$terminal" = lib.mkDefault "ghostty";
    "$fileManager" = lib.mkDefault "~/.local/share/omarchy/bin/omarchy-launch-or-focus nautilus 'nautilus --new-window'";
    "$browser" = lib.mkDefault (
      if cfg.browser == "brave" then
        "~/.local/share/omarchy/bin/omarchy-launch-or-focus brave 'brave --new-window --ozone-platform=wayland'"
      else
        "~/.local/share/omarchy/bin/omarchy-launch-or-focus chromium 'chromium --new-window --ozone-platform=wayland'"
    );
    "$music" = lib.mkDefault "~/.local/share/omarchy/bin/omarchy-launch-or-focus spotify spotify";
    "$passwordManager" = lib.mkDefault "~/.local/share/omarchy/bin/omarchy-launch-or-focus 1password 1password";
    "$messenger" = lib.mkDefault "~/.local/share/omarchy/bin/omarchy-launch-or-focus signal 'signal-desktop'";
    "$webapp" = lib.mkDefault "$browser --app";

    monitor = cfg.monitors;
  };
}
