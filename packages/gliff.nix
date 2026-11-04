{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  nasm,
  wrapGAppsHook4,
  gtk4,
  libadwaita,
  libdrm,
  libva,
  libxkbcommon,
  libgbm,
  dbus,
  wayland,
  vulkan-loader,
  openssh,
}:
# gliff is a Hyprland remote desktop over SSH. The client (gliff, in
# gliff.desktop) runs `ssh <host> gliff-server --stdio`, so gliff-server must
# be on the PATH of a non-interactive SSH session on the remote machine.
# quattro's shell watches for a running gliff-server and lights the
# RemoteSession bar indicator while someone is connected.
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gliff";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "gliff";
    tag = "v${finalAttrs.version}";
    hash = "sha256-v2EhlYP1hjp9bdoFIKbYyTWdOjx8sjjCAq66s3I5iZA=";
  };

  cargoHash = "sha256-eM8h3tFay3KVe5dS/4BqCt4vHFFFeF/geuUogQRnB4U=";

  # openh264 is built from source with its nasm x86 kernels, as on Arch.
  nativeBuildInputs = [pkg-config nasm wrapGAppsHook4];
  buildInputs = [
    gtk4
    libadwaita
    libdrm
    libva
    libxkbcommon
    libgbm
    dbus
    wayland
  ];

  # The PKGBUILD runs the whole workspace test suite.
  cargoTestFlags = ["--workspace"];

  postInstall = ''
    install -Dm644 pkgbuild/gliff.svg $out/share/icons/hicolor/scalable/apps/gliff.svg
    install -Dm644 pkgbuild/gliff.desktop $out/share/applications/gliff.desktop
    install -Dm644 NOTICE $out/share/licenses/gliff/NOTICE
    install -Dm644 README.md $out/share/doc/gliff/README.md
    install -Dm644 docs/hardware-quirks.md $out/share/doc/gliff/hardware-quirks.md
  '';

  # ash loads libvulkan at runtime, and the client spawns ssh. Arch finds both
  # in /usr. On Nix, add the loader to the RPATH and ssh to the PATH.
  postFixup = ''
    for bin in gliff gliff-server gliff-probe; do
      patchelf --add-rpath ${lib.makeLibraryPath [vulkan-loader]} $out/bin/.$bin-wrapped
    done
  '';

  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [openssh]})
  '';

  meta = {
    description = "Hyprland remote desktop over SSH (GPU H.264, 4:4:4)";
    homepage = "https://github.com/omacom/gliff";
    license = with lib.licenses; [mit bsd2];
    mainProgram = "gliff";
    platforms = lib.platforms.linux;
  };
})
