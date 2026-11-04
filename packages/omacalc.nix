{
  lib,
  stdenv,
  fetchFromGitHub,
  qt6,
}:
# quattro replaced gnome-calculator with omacalc, which follows the Omarchy
# theme and system light/dark mode. Bound to SUPER + SHIFT + Q in
# default/hypr/bindings/applications.lua.
stdenv.mkDerivation (finalAttrs: {
  pname = "omacalc";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "omacom-io";
    repo = "omacalc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Q1LGLTmMz8jqPGptyp8oZKr3iCM2YTR0f/NbmPY8AFQ=";
  };

  # bin/build runs qmake6 and make. The qmake hook does the same steps.
  nativeBuildInputs = [qt6.qmake qt6.wrapQtAppsHook];
  buildInputs = [qt6.qtbase qt6.qtdeclarative];

  # The project has no install target. Install the same files as the PKGBUILD.
  # The iA Writer fonts are compiled into the binary as Qt resources.
  installPhase = ''
    runHook preInstall
    install -Dm755 omacalc $out/bin/omacalc
    install -Dm644 LICENSE $out/share/licenses/omacalc/LICENSE
    install -Dm644 fonts/OFL.txt $out/share/licenses/omacalc/OFL.txt
    install -Dm644 pkgbuild/omacalc.svg $out/share/icons/hicolor/scalable/apps/omacalc.svg
    install -Dm644 pkgbuild/omacalc.desktop $out/share/applications/omacalc.desktop
    runHook postInstall
  '';

  meta = {
    description = "Dead-simple calculator built with Qt Quick";
    homepage = "https://github.com/omacom-io/omacalc";
    license = [lib.licenses.mit lib.licenses.ofl];
    mainProgram = "omacalc";
    platforms = lib.platforms.linux;
  };
})
