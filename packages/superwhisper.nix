{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook4,
  gobject-introspection,
  zstd,
  python3,
  vulkan-loader,
  gtk4,
  gtk4-layer-shell,
  gdk-pixbuf,
  cairo,
  graphene,
  glib,
  at-spi2-core,
  librsvg,
  libxcb,
  fontconfig,
  libxkbcommon,
  wayland,
  fcitx5,
  wl-clipboard,
  ffmpeg,
  libnotify,
  pulseaudio,
  xdg-utils,
  foot,
}:
# Superwhisper is the default dictation backend in quattro (cloud processing,
# with optional local models). Omarchy-Nix installs it only when
# omarchy.superwhisper.enable is set. bin/omarchy-dictation-superwhisper drives it
# with `superwhisper start|stop|record`, and
# bin/omarchy-install-dictation-superwhisper runs share/superwhisper/setup-user
# and sets its native shortcuts.
#
# This follows the OPR superwhisper-bin recipe. The vendor's portable bundle
# goes to opt/superwhisper. The launcher, user service, desktop files and
# setup-user come from the OPR recipe, with /usr/bin and /opt paths pointed at
# the store. The vendor checks the archive with Minisign. Nix pins it with a
# fixed hash instead.
let
  version = "1.1.3";
  oprCommit = "c00af952f854d369c4c612f15220505923429a54";
  oprFile = name: hash:
    fetchurl {
      url = "https://raw.githubusercontent.com/omacom/omarchy-pkgs/${oprCommit}/pkgbuilds/superwhisper-bin/${name}";
      inherit hash;
    };
  sources = {
    x86_64-linux = {
      arch = "x86_64";
      hash = "sha256-bUBT9ZdndIJOEHQp2iNHSTvJZZrdFVSgI+3sDNU0C/w=";
    };
    aarch64-linux = {
      arch = "aarch64";
      hash = "sha256-+7xDMkrmwpuhcmW40hToTaOYg0WVhDr08ZcbayjgiZw=";
    };
  };
  source =
    sources.${stdenv.hostPlatform.system}
    or (throw "superwhisper: unsupported system ${stdenv.hostPlatform.system}");
  bundle = "superwhisper-omarchy-${source.arch}-${version}";

  # The helper scripts import Gtk 4, Gtk4LayerShell, Atspi and cairo through gi.
  pythonEnv = python3.withPackages (ps: [ps.pygobject3 ps.pycairo]);
in
  stdenv.mkDerivation {
    pname = "superwhisper";
    inherit version;

    src = fetchurl {
      url = "https://tux.superwhisper.com/${source.arch}/v${version}/${bundle}.tar.zst";
      inherit (source) hash;
    };

    sourceRoot = bundle;

    launcher = oprFile "superwhisper" "sha256-VKD9V08rEjryQDHpEP4NxHvh1MBV7l33dfHGgeYgHJM=";
    serviceFile = oprFile "superwhisper.service" "sha256-i5osuBpuoBXWY8mYG6Z+2v6TTrDlaQT6tQMPu/3YUGs=";
    desktopFile = oprFile "superwhisper.desktop" "sha256-xlFpyEMiI/JrByyN7+n/Ze+CwmvjTNkqlhftESyyJXA=";
    urlDesktopFile = oprFile "superwhisper-url.desktop" "sha256-5nl40jnhKjhuwzU0axThDMfjvti5sdS8vtQ3fxDUaVo=";
    setupUser = oprFile "setup-user" "sha256-cH9yyvbZBqM5BwPWBLPNaAJFRdmo56rFRv8hgjDh4P0=";

    nativeBuildInputs = [
      zstd
      python3
      autoPatchelfHook
      makeWrapper
      wrapGAppsHook4
      gobject-introspection
    ];

    buildInputs = [
      stdenv.cc.cc.lib
      vulkan-loader
      gtk4
      gtk4-layer-shell
      gdk-pixbuf
      cairo
      graphene
      glib
      at-spi2-core
      librsvg
      libxcb
      fontconfig
      libxkbcommon
      fcitx5
    ];

    # The settings window loads the Wayland client library with dlopen, and
    # the recording pill loads gtk4-layer-shell the same way.
    runtimeDependencies = [wayland libxkbcommon gtk4-layer-shell];

    # The OPR recipe sets !strip.
    dontStrip = true;
    dontConfigure = true;
    dontBuild = true;
    # The launcher is wrapped by hand below.
    dontWrapGApps = true;

    # Qt 6.12 adds a Color type that shadows Omarchy's palette singleton. The
    # OPR recipe qualifies the panel's palette references. Same script.
    postPatch = ''
      [[ $(< VERSION) == "${version}" ]]
      python3 - app/assets/omarchy-plugin/superwhisper-panel <<'PYTHON'
      from pathlib import Path
      import re
      import sys

      for path in Path(sys.argv[1]).glob("*.qml"):
        original = path.read_text()
        updated = re.sub(r"(?<![\w.])Color\b", "Commons.Color", original)
        if updated != original:
          alias = r"(?m)^import qs\.Commons(?: [0-9.]+)? as Commons[ \t]*$"
          if not re.search(alias, updated):
            updated, imports = re.subn(r"(?m)^(import qs\.Commons(?: [0-9.]+)?[ \t]*)$", r"\1\nimport qs.Commons as Commons", updated, count=1)
            if imports != 1:
              raise SystemExit(f"Cannot qualify palette import in {path}")
          if len(re.findall(alias, updated)) != 1 or re.search(r"(?<![\w.])Color\b", updated):
            raise SystemExit(f"Invalid palette references in {path}")
          path.write_text(updated)
      PYTHON
    '';

    installPhase = ''
      runHook preInstall

      opt=$out/opt/superwhisper
      mkdir -p $opt
      cp -a --no-preserve=ownership app/. $opt/
      # Omarchy owns its Dictation menu; omit the portable installer's menu writer.
      rm -f $opt/scripts/omarchy-menu-rows.py

      install -Dm755 $launcher $out/bin/superwhisper
      install -Dm644 $serviceFile $out/share/systemd/user/superwhisper.service
      install -Dm644 $desktopFile $out/share/applications/superwhisper.desktop
      install -Dm644 $urlDesktopFile $out/share/applications/superwhisper-url.desktop
      install -Dm755 $setupUser $out/share/superwhisper/setup-user
      # setup-user keeps the Arch paths. It links them into the home directory,
      # and modules/nixos/superwhisper.nix points them at the current build,
      # so the links follow a rebuild. A store path link would break on GC.
      substituteInPlace $out/bin/superwhisper $out/share/systemd/user/superwhisper.service \
        --replace-quiet /usr/bin/superwhisper $out/bin/superwhisper \
        --replace-quiet /opt/superwhisper $opt

      install -Dm644 -t $out/share/licenses/superwhisper licenses/*
      install -Dm644 README.md $out/share/doc/superwhisper/README.md
      install -Dm644 app/assets/linux-status/SuperwhisperTUI.ttf $out/share/fonts/superwhisper/SuperwhisperTUI.ttf
      for size in 16 32 64 128 256 512 1024; do
        install -Dm644 app/assets/app-icon/$size.png $out/share/icons/hicolor/''${size}x''${size}/apps/superwhisper.png
      done
      mkdir -p $out/share/fcitx5/addon
      sed "s|@LIBRARY@|$opt/lib/fcitx5/libsuperwhisper-fcitx5|" \
        app/assets/fcitx5/superwhisper.conf.in > $out/share/fcitx5/addon/superwhisper.conf

      runHook postInstall
    '';

    # The daemon runs python3 helpers (with gi), ffmpeg, pactl and paplay,
    # wl-copy, notify-send and foot. Arch gets them from package depends. The
    # python with gi goes first on PATH; the rest come after the user's tools.
    # `superwhisper doctor` looks for gtk4-layer-shell in the library search
    # path, where Arch keeps it, so add it there too.
    postFixup = ''
      wrapProgram $out/bin/superwhisper \
        "''${gappsWrapperArgs[@]}" \
        --prefix PATH : ${lib.makeBinPath [pythonEnv]} \
        --suffix PATH : ${lib.makeBinPath [wl-clipboard ffmpeg libnotify pulseaudio xdg-utils foot]} \
        --suffix LD_LIBRARY_PATH : ${lib.makeLibraryPath [gtk4-layer-shell]}
    '';

    meta = {
      description = "Local and cloud voice dictation with Superwhisper";
      homepage = "https://superwhisper.com";
      # The app is proprietary. Bundled components (llama.cpp, onnxruntime)
      # are MIT.
      license = with lib.licenses; [unfree mit];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      mainProgram = "superwhisper";
      platforms = builtins.attrNames sources;
    };
  }
