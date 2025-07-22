{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
  wallpapers = {
    "tokyo-night" = [
      "1-Pawel-Czerwinski-Abstract-Purple-Blue.jpg"
      "2-Milad-Fakurian-Abstract-Purple-Blue.jpg"
      "3-scenery-pink-lakeside-sunset-lake-landscape-scenic-panorama-7680x3215-144.png"
    ];
    "kanagawa" = [
      "kanagawa-1.png"
    ];
    "everforest" = [
      "1-everforest.jpg"
    ];
    "nord" = [
      "nord-1.png"
    ];
    "gruvbox" = [
      "gruvbox-1.jpg"
    ];
    "gruvbox-light" = [
      "gruvbox-1.jpg"
    ];
    "catppuccin-latte" = [
      "1-Pawel-Czerwinski-Abstract-Purple-Blue.jpg"  # Fallback to Tokyo Night for now
    ];
  };

  # Get the first wallpaper as default
  selected_wallpaper = builtins.elemAt (wallpapers.${cfg.theme}) 0;
  selected_wallpaper_path = "~/Pictures/Wallpapers/${selected_wallpaper}";
  
  # Create background state directory
  background_state_dir = "~/.config/omarchy/current";
in {
  # Copy wallpapers to home directory
  home.file = {
    "Pictures/Wallpapers" = {
      source = ../../config/themes/wallpapers;
      recursive = true;
    };
    
    # Create state directory structure
    ".config/omarchy/current/.keep" = {
      text = "";
    };
  };
  
  # Create background management scripts
  home.file.".local/bin/omarchy-bg-set" = {
    text = ''
      #!/usr/bin/env bash
      # Set a specific background
      WALLPAPER_PATH="$1"
      
      if [[ -z "$WALLPAPER_PATH" ]]; then
        echo "Usage: omarchy-bg-set <wallpaper-path>"
        exit 1
      fi
      
      # Kill existing swaybg processes
      pkill swaybg 2>/dev/null || true
      
      # Start swaybg with new wallpaper
      swaybg -i "$WALLPAPER_PATH" -m fill &
      
      # Update current background symlink
      mkdir -p ~/.config/omarchy/current
      rm -f ~/.config/omarchy/current/background
      ln -sf "$WALLPAPER_PATH" ~/.config/omarchy/current/background
    '';
    executable = true;
  };

  # Auto-start swaybg with default wallpaper
  wayland.windowManager.hyprland.settings.exec-once = [
    "~/.local/bin/omarchy-bg-set ${selected_wallpaper_path}"
  ];
}