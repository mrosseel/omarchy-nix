{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  qt6,
  libpulseaudio,
  ffmpeg,
}:
# Monologue is the webcam recorder that quattro ships by default. Users start
# it from the app launcher (monologue.desktop).
stdenv.mkDerivation (finalAttrs: {
  pname = "monologue";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "monologue";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sQm/n0kHl13JQ3iOcOM5rZcP9xqrPpw6EKTVBLWha/I=";
  };

  nativeBuildInputs = [qt6.qmake qt6.wrapQtAppsHook pkg-config];
  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtmultimedia
    qt6.qtwayland
    libpulseaudio
  ];

  # The project file has no install target. Install the same files as the
  # upstream PKGBUILD by hand.
  installPhase = ''
    runHook preInstall
    install -Dm755 monologue $out/bin/monologue
    install -Dm644 pkgbuild/monologue.svg $out/share/icons/hicolor/scalable/apps/monologue.svg
    install -Dm644 pkgbuild/monologue.desktop $out/share/applications/monologue.desktop
    runHook postInstall
  '';

  # Monologue runs ffmpeg and ffprobe to encode and inspect clips, and shows
  # "unavailable" when it cannot find them. Arch gets them from depends.
  qtWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ffmpeg]}"
  ];

  meta = {
    description = "Simple, theme-synced webcam recorder for Omarchy";
    homepage = "https://github.com/omacom/monologue";
    license = lib.licenses.mit;
    mainProgram = "monologue";
    platforms = lib.platforms.linux;
  };
})
