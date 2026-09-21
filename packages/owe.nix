{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  cmake,
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
  qt6,
}:
# OWE is quattro's video wallpaper engine. It owns the desktop background while
# it runs and feeds the lock screen its frames through the owe-lockfeed QML
# plugin, which omarchy-shell's lock surface imports.
#
# Upstream splits this into two Arch packages built from one tree (owe and
# owe-lockfeed). Nix has no reason to split them, so the QML plugin is built in
# the same derivation and lands in the same qtbase QML import path.
stdenv.mkDerivation (finalAttrs: {
  pname = "owe";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "owe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JvoyGlw9LU0CMB0HQfcl9T98Z+161F7H/16jQiCilhI=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cmake
    makeWrapper
    wayland-scanner
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libGL
    libepoxy
    mpv-unwrapped
    ffmpeg
    systemdLibs
    qt6.qtbase
    qt6.qtdeclarative
  ];

  # The tree carries both a meson project (the daemon, renderer and CLI) and a
  # standalone CMake project for the lock feed plugin. mesonConfigurePhase would
  # try to configure the CMake one too, so drive the plugin build by hand.
  dontUseCmakeConfigure = true;

  postBuild = ''
    cmake -S ../qml-plugin -B qml-plugin-build \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$out \
      -DCMAKE_INSTALL_LIBDIR=lib
    cmake --build qml-plugin-build
  '';

  postInstall = ''
    cmake --install qml-plugin-build

    install -Dm644 ../systemd/owed.service $out/share/systemd/user/owed.service
    substituteInPlace $out/share/systemd/user/owed.service \
      --replace-fail '%h/.local/bin/owed' "$out/bin/owed"

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
