{
  config,
  lib,
  pkgs,
  osConfig ? {},
  ...
}:
let
  cfg = config.omarchy;
  hasNvidiaDrivers = builtins.elem "nvidia" osConfig.services.xserver.videoDrivers;
  nvidiaEnv = [
    "NVD_BACKEND,direct"
    "LIBVA_DRIVER_NAME,nvidia"
    "__GLX_VENDOR_LIBRARY_NAME,nvidia"
  ];
in
{
  wayland.windowManager.hyprland.settings = {
    # Environment variables
    env = (lib.optionals hasNvidiaDrivers nvidiaEnv) ++ [
      "GDK_SCALE,${toString cfg.scale}"
      
      # Cursor size
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_SIZE,24"

      # Cursor theme
      "XCURSOR_THEME,Bibata-Modern-Classic"
      "HYPRCURSOR_THEME,Bibata-Modern-Classic"

      # Force all apps to use Wayland
      "GDK_BACKEND,wayland"
      "QT_QPA_PLATFORM,wayland"
      "QT_STYLE_OVERRIDE,kvantum"
      "SDL_VIDEODRIVER,wayland"
      "MOZ_ENABLE_WAYLAND,1"
      "ELECTRON_OZONE_PLATFORM_HINT,wayland"
      "OZONE_PLATFORM,wayland"

      # Make Chromium use XCompose and all Wayland
      "CHROMIUM_FLAGS,\"--enable-features=UseOzonePlatform --ozone-platform=wayland --gtk-version=4\""

      # Make .desktop files available for wofi
      "XDG_DATA_DIRS,$XDG_DATA_DIRS:$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share"

      # Use XCompose file
      "XCOMPOSEFILE,~/.XCompose"
      "EDITOR,nvim"
      # "DOCKER_HOST,unix://$XDG_RUNTIME_DIR/podman/podman.sock"
      
      # XDG Desktop Portal
      "XDG_CURRENT_DESKTOP,Hyprland"
      "XDG_SESSION_TYPE,wayland"
      "XDG_SESSION_DESKTOP,Hyprland"
    ];

    xwayland = {
      force_zero_scaling = true;
    };

    # Don't show update on first launch
    ecosystem = {
      no_update_news = true;
    };
  };
}
