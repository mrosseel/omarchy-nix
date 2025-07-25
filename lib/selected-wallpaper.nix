config: let
  cfg = config.omarchy;
  wallpapers = {
    "tokyo-night" = [
      "1-Pawel-Czerwinski-Abstract-Purple-Blue.jpg"
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
  };

  selected_wallpaper = builtins.elemAt (wallpapers.${cfg.theme}) 0;
in {
  wallpaper_path = "~/Pictures/Wallpapers/${selected_wallpaper}";
}
