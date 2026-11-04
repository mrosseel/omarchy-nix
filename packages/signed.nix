{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  qt6,
  qt6Packages,
  qpdf,
  nss,
}:
# Signed replaces Xournal++ for signing PDFs and filling them in. Users start
# it from the app launcher, or open a PDF with it from the file manager
# (signed.desktop runs `signed open %f` and claims application/pdf).
stdenv.mkDerivation (finalAttrs: {
  pname = "signed";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "signed";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fH5jXdO0uNsRblramzU0lcP3Dvv7pMZjf41FdE3lKjY=";
  };

  nativeBuildInputs = [qt6.qmake qt6.wrapQtAppsHook pkg-config];
  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtwayland
    qt6Packages.poppler
    qpdf
  ];

  # The project file has no install target. Install the same files as the
  # upstream PKGBUILD by hand.
  installPhase = ''
    runHook preInstall
    install -Dm755 signed $out/bin/signed
    install -Dm644 pkgbuild/signed.svg $out/share/icons/hicolor/scalable/apps/signed.svg
    install -Dm644 pkgbuild/signed.desktop $out/share/applications/signed.desktop
    install -Dm644 README.md $out/share/doc/signed/README.md
    runHook postInstall
  '';

  # Signed runs certutil and pk12util to keep its signing certificates. On
  # Arch they come with nss, a poppler dependency. On Nix they live in
  # nss.tools, so put them on PATH. Text uses Noto Sans, which the system
  # font set must provide.
  qtWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [nss.tools]}"
  ];

  meta = {
    description = "Sign PDFs and fill them in with text and dates";
    homepage = "https://github.com/omacom/signed";
    license = lib.licenses.mit;
    mainProgram = "signed";
    platforms = lib.platforms.linux;
  };
})
