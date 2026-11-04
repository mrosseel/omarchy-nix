{
  lib,
  stdenv,
  fetchFromGitHub,
  qt6,
  zlib,
  libwebp,
  ffmpeg,
  sourceHighlight,
}:
# Hype is the Markdown presentation app that quattro ships by default. Users
# start it from the app launcher (hype.desktop runs `hype open %f`).
stdenv.mkDerivation (finalAttrs: {
  pname = "hype";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "hype";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lDrDfo0LqGbWD8X7rejOYf9nKqyNNZh6wMlL9wRRJoU=";
  };

  nativeBuildInputs = [qt6.qmake qt6.wrapQtAppsHook];
  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtmultimedia
    qt6.qtsvg
    qt6.qtimageformats
    qt6.qtwayland
    zlib
    libwebp
  ];

  # The project file has no install target. Install the same files as the
  # upstream PKGBUILD by hand.
  installPhase = ''
    runHook preInstall
    install -Dm755 hype $out/bin/hype
    install -Dm644 pkgbuild/hype.svg $out/share/icons/hicolor/scalable/apps/hype.svg
    install -Dm644 pkgbuild/hype.desktop $out/share/applications/hype.desktop
    install -Dm644 README.md $out/share/doc/hype/README.md
    runHook postInstall
  '';

  # Hype runs ffmpeg and ffprobe for video slides and exports, and
  # source-highlight for code blocks. Arch gets them from package depends.
  qtWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ffmpeg sourceHighlight]}"
  ];

  meta = {
    description = "Simple Markdown presentations with a visual slide editor";
    homepage = "https://github.com/omacom/hype";
    license = lib.licenses.mit;
    mainProgram = "hype";
    platforms = lib.platforms.linux;
  };
})
