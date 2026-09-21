{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  makeWrapper,
  wayland-scanner,
  wayland-protocols,
  wayland,
  qt6,
  layer-shell-qt,
  tesseract,
  wl-clipboard,
}:
# quattro replaced tensaku with omasnap: the screenshot overlay, annotation
# editor and OCR path behind omarchy-capture-screenshot and omarchy-clipboard-open.
stdenv.mkDerivation (finalAttrs: {
  pname = "omasnap";
  version = "1.21.0";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "omasnap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kpoPb5F5yqcczBRUfENsEfv+BD67zQsTG9Ur6Bi3viE=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    makeWrapper
    wayland-scanner
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    wayland
    qt6.qtbase
    layer-shell-qt
  ];

  # CMakeLists.txt names the staging protocols by their Arch absolute paths.
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail /usr/share/wayland-protocols/ \
        ${wayland-protocols}/share/wayland-protocols/
  '';

  cmakeFlags = [(lib.cmakeBool "BUILD_TESTING" false)];

  # Text extraction shells out to tesseract and the clipboard write to wl-copy;
  # neither is a runtime dependency Nix would otherwise retain.
  postFixup = ''
    wrapProgram $out/bin/omasnap \
      --prefix PATH : ${lib.makeBinPath [tesseract wl-clipboard]}
  '';

  meta = {
    description = "Native Wayland screenshot and annotation editor for Omarchy and Hyprland";
    homepage = "https://github.com/omacom/omasnap";
    license = [lib.licenses.mit lib.licenses.ofl];
    mainProgram = "omasnap";
    platforms = lib.platforms.linux;
  };
})
