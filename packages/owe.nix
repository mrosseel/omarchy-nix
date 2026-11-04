{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  makeWrapper,
  wayland-scanner,
  wayland,
  wayland-protocols,
  libGL,
  libepoxy,
  mpv-unwrapped,
  ffmpeg,
  systemdLibs,
  socat,
  bash,
}:
# OWE is quattro's video wallpaper engine. It owns the desktop background while
# it runs.
#
# Upstream also builds owe-lockfeed, a QML plugin from the same tree, but
# dropped it from the base packages when the lock screen moved to a still frame
# (upstream 2a1ff8d83). The shell imports no OWE QML module now, so this
# derivation builds only the owe package.
stdenv.mkDerivation (finalAttrs: {
  pname = "owe";
  version = "0.2.13";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "owe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VQmoE05xMXLdbXhZaRL/My90o7bszwo8hI0++Jb9a8Q=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    makeWrapper
    wayland-scanner
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libGL
    libepoxy
    mpv-unwrapped
    ffmpeg
    systemdLibs
  ];

  # The unit runs owed through /bin/bash, which NixOS does not have.
  postInstall = ''
    install -Dm644 ../systemd/owed.service $out/share/systemd/user/owed.service
    substituteInPlace $out/share/systemd/user/owed.service \
      --replace-fail '%h/.local/bin/owed' "$out/bin/owed" \
      --replace-fail '/bin/bash' '${lib.getExe bash}'

    install -Dm755 ../hooks/owe-idle $out/bin/owe-idle
    install -Dm644 ../hooks/theme-set.d/10-owe-sync $out/share/owe/10-owe-sync
    install -Dm644 ../config/config.toml $out/share/doc/owe/config.toml.example
  '';

  # owed drives playback through mpv and talks to the CLI over a socat socket.
  postFixup = ''
    for bin in $out/bin/owe $out/bin/owed $out/bin/owe-idle; do
      [ -e "$bin" ] || continue
      wrapProgram "$bin" --prefix PATH : ${lib.makeBinPath [socat ffmpeg]}
    done
  '';

  meta = {
    description = "Wallpaper engine for Omarchy (video, gif and still backgrounds)";
    homepage = "https://github.com/omacom/owe";
    license = lib.licenses.mit;
    mainProgram = "owe";
    platforms = lib.platforms.linux;
  };
})
