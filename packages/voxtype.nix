{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, alsa-lib
, vulkan-loader
, wtype
, wl-clipboard
}:

stdenv.mkDerivation rec {
  pname = "voxtype";
  version = "0.4.13";

  srcs = [
    (fetchurl {
      url = "https://github.com/peteonrails/voxtype/releases/download/v${version}/voxtype-${version}-linux-x86_64-avx2";
      hash = "sha256-phGlbSsKr0Yq2MGJ5pz3CxL2gl94QD19E+ecLZZc9PQ=";
      name = "voxtype-cpu";
    })
    (fetchurl {
      url = "https://github.com/peteonrails/voxtype/releases/download/v${version}/voxtype-${version}-linux-x86_64-vulkan";
      hash = "sha256-NCOiMdMgUtFEDxXk/d0Aks7nSjHjJQ2UPF1IN784Umk=";
      name = "voxtype-vulkan";
    })
  ];

  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    vulkan-loader
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/voxtype

    # Install Vulkan binary as main executable (GPU acceleration by default)
    cp ${builtins.elemAt srcs 1} $out/bin/voxtype
    chmod +x $out/bin/voxtype

    # Install CPU binary as fallback
    cp ${builtins.elemAt srcs 0} $out/lib/voxtype/voxtype-cpu
    chmod +x $out/lib/voxtype/voxtype-cpu

    # Also install Vulkan binary in lib for voxtype's expected paths
    cp ${builtins.elemAt srcs 1} $out/lib/voxtype/voxtype-vulkan
    chmod +x $out/lib/voxtype/voxtype-vulkan

    # Create symlinks expected by voxtype
    ln -s $out/lib/voxtype/voxtype-vulkan $out/lib/voxtype/voxtype-gpu

    # Wrap main binary (Vulkan) with GPU support
    # NixOS puts Vulkan ICD files in /run/opengl-driver/share/vulkan/icd.d/
    # Adding this to XDG_DATA_DIRS lets the Vulkan loader find them
    # GGML_VK_VISIBLE_DEVICES=0 tells ggml-vulkan to use the first GPU
    wrapProgram $out/bin/voxtype \
      --prefix PATH : ${lib.makeBinPath [ wtype wl-clipboard ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader ]} \
      --prefix XDG_DATA_DIRS : /run/opengl-driver/share \
      --set GGML_VK_VISIBLE_DEVICES 0

    # Wrap CPU fallback binary
    wrapProgram $out/lib/voxtype/voxtype-cpu \
      --prefix PATH : ${lib.makeBinPath [ wtype wl-clipboard ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader ]}

    # Wrap lib Vulkan binary too (for voxtype setup gpu commands)
    wrapProgram $out/lib/voxtype/voxtype-vulkan \
      --prefix PATH : ${lib.makeBinPath [ wtype wl-clipboard ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader ]} \
      --prefix XDG_DATA_DIRS : /run/opengl-driver/share \
      --set GGML_VK_VISIBLE_DEVICES 0

    runHook postInstall
  '';

  meta = with lib; {
    description = "Local voice dictation using Whisper AI";
    homepage = "https://github.com/peteonrails/voxtype";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
