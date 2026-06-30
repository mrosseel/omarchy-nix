{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
  browserDesktop = if cfg.browser == "brave" then "brave-browser.desktop" else "chromium-browser.desktop";
in {
  # Custom desktop entries for applications
  # Provides proper MIME associations and Wayland support

  xdg.desktopEntries = {
    # Disk Usage - floating TUI launcher (mirrors Omarchy install/packaging/tuis.sh)
    # Upstream swapped `dust -r` for `dua i`; window class TUI.float is tagged
    # floating in default/hypr/apps/system.conf.
    disk-usage = {
      name = "Disk Usage";
      comment = "Disk Usage";
      exec = "xdg-terminal-exec --app-id=TUI.float -e dua i";
      icon = "${config.home.homeDirectory}/.config/omarchy/webapp-icons/Disk Usage.png";
      type = "Application";
      terminal = false;
      startupNotify = true;
    };

    # btop - system monitor in the launcher. Quattro ships
    # applications/hidden/btop.desktop (NoDisplay) and dropped the waybar CPU
    # button, so btop has no UI hook; surface it like Disk Usage. Uses
    # omarchy-launch-or-focus-tui (app-id org.omarchy.btop, floated + focus-or-launch).
    btop = {
      name = "btop";
      genericName = "System Monitor";
      comment = "Monitor CPU, memory and processes";
      exec = "omarchy-launch-or-focus-tui btop";
      icon = "utilities-system-monitor";
      type = "Application";
      terminal = false;
      startupNotify = true;
      categories = ["System"];
      settings.Keywords = "cpu;system;monitor;activity;process;resources;top;";
    };

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
      icon = "mpv";
      type = "Application";
      terminal = false;
      categories = ["AudioVideo" "Audio" "Video" "Player" "TV"];
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
      categories = ["Office" "WordProcessor"];
      mimeType = ["text/markdown" "text/x-markdown"];
    };
  };

  # Default MIME type associations (matches Omarchy's install/config/mimetypes.sh)
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # File manager
      "inode/directory" = "org.gnome.Nautilus.desktop";

      # Browser (HTTP/HTTPS)
      "x-scheme-handler/http" = browserDesktop;
      "x-scheme-handler/https" = browserDesktop;
      "text/html" = browserDesktop;

      # Images → imv
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/jpg" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/bmp" = "imv.desktop";
      "image/tiff" = "imv.desktop";

      # PDF → Evince
      "application/pdf" = "org.gnome.Evince.desktop";

      # Video → mpv
      "video/mp4" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/x-flv" = "mpv.desktop";
      "video/x-ms-wmv" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";
      "video/ogg" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/3gpp" = "mpv.desktop";
      "video/x-ms-asf" = "mpv.desktop";
      "video/x-ogm+ogg" = "mpv.desktop";
      "video/x-theora+ogg" = "mpv.desktop";
      "application/ogg" = "mpv.desktop";

      # Audio → mpv
      "audio/mpeg" = "mpv.desktop";
      "audio/ogg" = "mpv.desktop";
      "audio/flac" = "mpv.desktop";
      "audio/wav" = "mpv.desktop";
      "audio/x-wav" = "mpv.desktop";
      "audio/mp4" = "mpv.desktop";
      "audio/aac" = "mpv.desktop";
      "audio/opus" = "mpv.desktop";
      "audio/webm" = "mpv.desktop";

      # Text/source → neovim
      "text/plain" = "nvim.desktop";
      "text/x-csrc" = "nvim.desktop";
      "text/x-chdr" = "nvim.desktop";
      "text/x-c++src" = "nvim.desktop";
      "text/x-c++hdr" = "nvim.desktop";
      "text/x-java" = "nvim.desktop";
      "text/x-pascal" = "nvim.desktop";
      "text/x-tcl" = "nvim.desktop";
      "text/x-tex" = "nvim.desktop";
      "text/x-shellscript" = "nvim.desktop";
      "application/xml" = "nvim.desktop";
      "application/x-shellscript" = "nvim.desktop";

      # Markdown → Typora
      "text/markdown" = "typora.desktop";
      "text/x-markdown" = "typora.desktop";
    };
  };
}
