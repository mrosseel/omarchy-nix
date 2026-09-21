{pkgs, ...}: let
  owe = pkgs.callPackage ../../packages/owe.nix {};
in {
  # OWE, quattro's video wallpaper engine. While owed runs it owns the desktop
  # video layer: shell/plugins/background/Background.qml keeps its own layer
  # empty behind a video so OWE's shows through, and the lock screen draws its
  # frames from the OWE lock feed through shell/plugins/lock/LockFeedSurface.qml.
  #
  # Upstream enables owed.service in install/user/first-run/enable-user-units.sh
  # and installs the theme-set hook with
  # `omarchy-hook-install theme-set /usr/share/owe/10-owe-sync`.
  # mpv does the decoding; ffmpeg probes and transcodes the sources OWE accepts.
  home.packages = [owe pkgs.mpv pkgs.ffmpeg];

  # LockFeedSurface.qml does `import Owe.LockFeed`, which the shell only
  # resolves if the plugin's QML import path is on QML2_IMPORT_PATH. The plugin
  # lives in this derivation rather than in quickshell's own import path.
  home.sessionVariables.QML2_IMPORT_PATH = "${owe}/lib/qt6/qml\${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}";

  systemd.user.services.owed = {
    Unit = {
      Description = "owe wallpaper engine daemon";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${owe}/bin/owed";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  # The hook only pings the daemon to refresh; it does no heavy work. Deployed
  # rather than seeded, so a theme switch keeps working after an OWE bump.
  home.file.".config/omarchy/hooks/theme-set.d/10-owe-sync" = {
    source = "${owe}/share/owe/10-owe-sync";
    executable = true;
  };

  # Upstream ships the same file as /usr/share/doc/owe/config.toml.example and
  # leaves ~/.config/owe/config.toml to the user.
  home.file.".config/omarchy/owe/config.toml.example".source = "${owe}/share/doc/owe/config.toml.example";
}
