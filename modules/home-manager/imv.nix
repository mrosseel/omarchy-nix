{pkgs, ...}: {
  # imv image viewer - same as omarchy
  home.packages = [pkgs.imv];

  # imv configuration
  home.file.".config/imv/config".text = ''
    [binds]

    # Print the current image file
    <Ctrl+p> = exec lp "$imv_current_file"

    # Delete the current image and quit the viewer
    <Ctrl+x> = exec rm "$imv_current_file"; quit

    # Delete the current image and move to the next one
    <Ctrl+Shift+X> = exec rm "$imv_current_file"; close

    # Rotate the currently open image by 90 degrees
    <Ctrl+r> = exec mogrify -rotate 90 "$imv_current_file"
  '';

  # Custom desktop entry matching omarchy
  xdg.desktopEntries.imv = {
    name = "Image Viewer";
    exec = "imv %F";
    icon = "imv";
    type = "Application";
    mimeType = [
      "image/png"
      "image/jpeg"
      "image/jpg"
      "image/gif"
      "image/bmp"
      "image/webp"
      "image/tiff"
      "image/x-xcf"
      "image/x-portable-pixmap"
      "image/x-xbitmap"
    ];
    terminal = false;
    categories = ["Graphics" "Viewer"];
  };

  # Set imv as default for images
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/jpg" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/bmp" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/tiff" = "imv.desktop";
      "image/x-xcf" = "imv.desktop";
      "image/x-portable-pixmap" = "imv.desktop";
      "image/x-xbitmap" = "imv.desktop";
    };
  };
}
