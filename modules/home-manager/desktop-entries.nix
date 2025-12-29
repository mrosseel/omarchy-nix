{
  config,
  pkgs,
  ...
}: {
  # Custom desktop entries for applications
  # Provides proper MIME associations and Wayland support

  xdg.desktopEntries = {
    # IMV - Image viewer with custom MIME types
    imv = {
      name = "Image Viewer";
      exec = "imv %F";
      icon = "imv";
      type = "Application";
      terminal = false;
      categories = ["Graphics" "Viewer"];
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
    };

    # MPV - Media player with pseudo-GUI mode
    mpv = {
      name = "Media Player";
      genericName = "Multimedia player";
      comment = "Play movies and songs";
      exec = "mpv --player-operation-mode=pseudo-gui -- %U";
      tryExec = "mpv";
      icon = "mpv";
      type = "Application";
      terminal = false;
      categories = ["AudioVideo" "Audio" "Video" "Player" "TV"];
      startupWMClass = "mpv";
      mimeType = [
        # Audio formats
        "audio/aac" "audio/x-aac" "audio/mp3" "audio/x-mp3" "audio/mpeg"
        "audio/ogg" "audio/flac" "audio/wav" "audio/x-wav" "audio/opus"
        "audio/webm" "audio/mp4" "audio/x-m4a" "application/x-extension-m4a"
        # Video formats
        "video/mp4" "video/x-matroska" "video/mkv" "video/webm"
        "video/mpeg" "video/x-msvideo" "video/avi" "video/quicktime"
        "video/x-flv" "video/ogg" "video/3gp" "video/3gpp"
        # Playlists
        "application/x-mpegurl" "audio/x-mpegurl" "audio/mpegurl"
      ];
    };

    # Typora - Markdown editor with Wayland IME support
    typora = {
      name = "Typora";
      genericName = "Markdown Editor";
      exec = "typora --enable-wayland-ime %U";
      icon = "typora";
      type = "Application";
      startupNotify = true;
      categories = ["Office" "WordProcessor"];
      mimeType = ["text/markdown" "text/x-markdown"];
    };
  };
}
