{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  libgcc,
  libxcb,
  libxkbcommon,
  wayland,
  libGL,
  vulkan-loader,
}:
# Disktree replaces the dua Disk Usage TUI in quattro. Users start it from the
# app launcher (disktree.desktop). `disktree --disk` scans the whole disk.
#
# Upstream ships the vendor's prebuilt release (AUR/OPR disktree-bin), so this
# does the same and patches the ELF for the Nix store.
let
  sources = {
    x86_64-linux = {
      arch = "x86_64";
      hash = "sha256-fnWvoig8i0+SkNUurb/ADZ8UwTrtLSJMzfD3gm/MBbI=";
    };
    aarch64-linux = {
      arch = "aarch64";
      hash = "sha256-PHX5yCBp5AMQyCE1elKu4vEanD4rRUUsmJPb98teRUo=";
    };
  };
  source =
    sources.${stdenv.hostPlatform.system}
    or (throw "disktree: unsupported system ${stdenv.hostPlatform.system}");
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "disktree";
    version = "0.11.0";

    src = fetchurl {
      url = "https://github.com/tobi/disktree/releases/download/v${finalAttrs.version}/disktree-${finalAttrs.version}-${source.arch}-linux.tar.gz";
      inherit (source) hash;
    };

    sourceRoot = "disktree-${finalAttrs.version}-${source.arch}-linux";

    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = [libgcc libxcb libxkbcommon];

    # GPUI loads the Wayland, EGL and Vulkan libraries with dlopen, so they are
    # not in the ELF NEEDED list. Add them to the RPATH.
    runtimeDependencies = [wayland libGL vulkan-loader libxkbcommon];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 disktree $out/bin/disktree
      mkdir -p $out/share/applications
      sed -e "s|@BINDIR@/||" -e "s|@VERSION@|${finalAttrs.version}|" disktree.desktop.in \
        > $out/share/applications/disktree.desktop
      install -Dm644 disktree.svg $out/share/icons/hicolor/scalable/apps/disktree.svg
      install -Dm644 README.md $out/share/doc/disktree/README.md
      runHook postInstall
    '';

    meta = {
      description = "Disk space treemap: see what fills a disk, mark what should go, and remove it";
      homepage = "https://github.com/tobi/disktree";
      license = lib.licenses.mit;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      mainProgram = "disktree";
      platforms = builtins.attrNames sources;
    };
  })
