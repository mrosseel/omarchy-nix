{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wrapGAppsHook4,
  copyDesktopItems,
  installShellFiles,
  fontconfig,
  gdk-pixbuf,
  glib,
  gtk4,
  gtk4-layer-shell,
  libadwaita,
  libepoxy,
  libGL,
  libxkbcommon,
}:
# Upstream installs the Arch `tensaku` package (a satty fork; no nixpkgs
# package yet). Mirrors packaging/aur-git/PKGBUILD: the tensaku binary, the
# tensaku-edit wrapper omarchy's screenshot flow calls, desktop entry, icon,
# man page, and completions.
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tensaku";
  version = "0.28.0";

  src = fetchFromGitHub {
    owner = "jondkinney";
    repo = "tensaku";
    rev = "v${finalAttrs.version}";
    hash = "sha256-rkLDfzGFonNghDspDDH6sLikOC/5TZtUCvIPHWtdLXI=";
  };

  cargoHash = "sha256-eFG6MhSnoPzwSX8FkK+qFOSCFsCJay8jiFAMeXgNrds=";

  # Generates the man page and shell completions during the build.
  buildFeatures = ["ci-release"];

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    copyDesktopItems
    installShellFiles
  ];

  buildInputs = [
    fontconfig
    gdk-pixbuf
    glib
    gtk4
    gtk4-layer-shell
    libadwaita
    libepoxy
    libGL
    libxkbcommon
  ];

  postInstall = ''
    install -Dm755 assets/tensaku-edit $out/bin/tensaku-edit
    install -Dm644 assets/tensaku.svg \
      $out/share/icons/hicolor/scalable/apps/dev.tensaku.Tensaku.svg

    installManPage man/tensaku.1
    installShellCompletion --cmd tensaku \
      --bash completions/tensaku.bash \
      --fish completions/tensaku.fish \
      --zsh completions/_tensaku
  '';

  desktopItems = ["dev.tensaku.Tensaku.desktop"];

  meta = {
    description = "Modern screenshot annotation tool for Wayland";
    homepage = "https://github.com/jondkinney/tensaku";
    license = lib.licenses.mpl20;
    mainProgram = "tensaku";
    platforms = lib.platforms.linux;
  };
})
