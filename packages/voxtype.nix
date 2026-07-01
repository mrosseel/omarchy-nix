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
  version = "0.7.5";

  # 0.7.x replaced the legacy ROCm execution provider with MIGraphX
  # (voxtype-onnx-rocm -> voxtype-onnx-migraphx). MIGraphX needs ROCm 7.x, but
  # nixpkgs is on 6.3.x, so onnx-migraphx would silently fall back to CPU here —
  # as did the old onnx-rocm on RX 7000-class GPUs. The Vulkan build accelerates
  # on AMD via Mesa/RADV with no ROCm dependency, so ship Vulkan as the main
  # binary with an avx2 CPU fallback. (Revisit migraphx once nixpkgs ships ROCm 7.x.)
  srcs = [
    (fetchurl {
      url = "https://github.com/peteonrails/voxtype/releases/download/v${version}/voxtype-${version}-linux-x86_64-avx2";
      hash = "sha256-GK4FENDJZGifjJtxGcC5pFVpmF6Cl33E8e9Ndv3diHw=";
      name = "voxtype-cpu";
    })
    (fetchurl {
      url = "https://github.com/peteonrails/voxtype/releases/download/v${version}/voxtype-${version}-linux-x86_64-vulkan";
      hash = "sha256-ZGJtB/Oq4oJd24LqZoePcIyKggo/0+znbZn/mEd/Ey0=";
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

    # voxtype resolves its variant binaries from lib/voxtype (the nixos module
    # symlinks /usr/lib/voxtype -> here) and the daemon service runs
    # `lib/voxtype/voxtype-vulkan daemon`, so the variants MUST live there.
    cp ${builtins.elemAt srcs 1} $out/lib/voxtype/voxtype-vulkan
    cp ${builtins.elemAt srcs 0} $out/lib/voxtype/voxtype-avx2
    chmod +x $out/lib/voxtype/voxtype-vulkan $out/lib/voxtype/voxtype-avx2

    # Wrap the Vulkan variant. XDG_DATA_DIRS -> /run/opengl-driver/share so the
    # Vulkan loader finds the RADV ICD; GGML_VK_VISIBLE_DEVICES pins the GPU.
    wrapProgram $out/lib/voxtype/voxtype-vulkan \
      --prefix PATH : ${lib.makeBinPath [ wtype wl-clipboard ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader ]} \
      --prefix XDG_DATA_DIRS : /run/opengl-driver/share \
      --set GGML_VK_VISIBLE_DEVICES 0

    # Wrap the avx2 CPU fallback variant.
    wrapProgram $out/lib/voxtype/voxtype-avx2 \
      --prefix PATH : ${lib.makeBinPath [ wtype wl-clipboard ]}

    # Main CLI entry point = the Vulkan build.
    ln -s $out/lib/voxtype/voxtype-vulkan $out/bin/voxtype

    runHook postInstall
  '';

  meta = with lib; {
    description = "Local voice dictation using Whisper/Parakeet AI";
    homepage = "https://github.com/peteonrails/voxtype";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
