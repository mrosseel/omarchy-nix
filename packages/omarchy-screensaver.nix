{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libxkbcommon,
  fontconfig,
}:
# The native Wayland screensaver that replaced the terminal one on quattro. It
# animates the branding text with ttfx effects on one layer surface per display.
# Omarchy starts it through omarchy-launch-screensaver and stops it with pkill.
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "omarchy-screensaver";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "omarchy-screensaver";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9uvcYUXPExFEUZq2VdvSZz6n2foqiPqyD9CMphgBCTw=";
  };

  cargoHash = "sha256-GnXuI+ceJpNz9npfLE9KpoQHU7MgYD9SnUKgNwfmTgM=";

  nativeBuildInputs = [pkg-config];
  buildInputs = [libxkbcommon];

  # The font lookup falls back to fc-match. NixOS does not put fc-match on PATH
  # by default, so call it from the store.
  postPatch = ''
    substituteInPlace src/raster.rs \
      --replace-fail 'Command::new("fc-match")' 'Command::new("${lib.getExe' fontconfig.bin "fc-match"}")'
  '';

  # The PKGBUILD installs the binary outside PATH, at
  # /usr/lib/omarchy-screensaver/omarchy-screensaver. Keep the same layout
  # under $out, so a pkill pattern on lib/omarchy-screensaver/omarchy-screensaver
  # still matches the process.
  postInstall = ''
    install -Dm755 $out/bin/omarchy-launch-screensaver \
      $out/lib/omarchy-screensaver/omarchy-screensaver
    rm -r $out/bin
    install -Dm644 LICENSE $out/share/licenses/omarchy-screensaver/LICENSE
    install -Dm644 README.md $out/share/doc/omarchy-screensaver/README.md
  '';

  meta = {
    description = "Native Wayland screensaver for Omarchy";
    homepage = "https://github.com/omacom/omarchy-screensaver";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
