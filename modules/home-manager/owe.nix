{pkgs, ...}: let
  owe = pkgs.callPackage ../../packages/owe.nix {};
in {
  # OWE, quattro's video wallpaper engine. While owed runs it owns the desktop
  # video layer: shell/plugins/background/Background.qml keeps its own layer
  # empty behind a video so OWE's shows through. The lock screen does not play
  # the video. It shows a still frame that shell/plugins/lock/poster.sh makes
  # with ffmpegthumbnailer, so the shell needs no OWE QML module.
  #
  # Upstream enables owed.service in install/user/first-run/enable-user-units.sh
  # and installs the theme-set hook with
  # `omarchy-hook-install theme-set /usr/share/owe/10-owe-sync`.
  # mpv does the decoding; ffmpeg probes and transcodes the sources OWE accepts.
  home.packages = [owe pkgs.mpv pkgs.ffmpeg];

  systemd.user.services.owed = {
    Unit = {
      Description = "owe wallpaper engine daemon";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      Type = "simple";
      # Same command as the owed.service that the owe package ships: it gets
      # the boot intro ready. A missing helper leaves a plain daemon start.
      ExecStart = "${pkgs.bash}/bin/bash -c 'exec ${owe}/bin/owed --prepare-intro \"$(\"$$OMARCHY_PATH/bin/omarchy-theme-bg-boot-intro\" --resolve-startup 2>/dev/null)\"'";
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
