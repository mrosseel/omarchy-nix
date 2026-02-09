{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, alsa-lib
, vulkan-loader
, wtype
, wl-clipboard
, rocmPackages
}:

stdenv.mkDerivation rec {
  pname = "voxtype";
  version = "0.6.0-rc.2";

  srcs = [
    (fetchurl {
      url = "https://github.com/peteonrails/voxtype/releases/download/v${version}/voxtype-${version}-linux-x86_64-avx2";
      hash = "sha256-l4t8JMAWxXThojrJltVBb/jEQQnQfjKXkPknI8S9EPM=";
      name = "voxtype-cpu";
    })
    (fetchurl {
      url = "https://github.com/peteonrails/voxtype/releases/download/v${version}/voxtype-${version}-linux-x86_64-vulkan";
      hash = "sha256-mRedv+79+B9gUiAQ3/6YlpbRtuEI99TaS7raxMWStOI=";
      name = "voxtype-vulkan";
    })
    (fetchurl {
      url = "https://github.com/peteonrails/voxtype/releases/download/v${version}/voxtype-${version}-linux-x86_64-parakeet-rocm";
      hash = "sha256-QaGNmUXAGYtI/iQh9FoF2qWiWxi9s1Dq0wF7Tx54ybg=";
      name = "voxtype-parakeet-rocm";
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
    rocmPackages.clr
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/voxtype

    # Install parakeet-rocm as main executable (AMD GPU via ROCm)
    cp ${builtins.elemAt srcs 2} $out/bin/voxtype
    chmod +x $out/bin/voxtype

    # Install CPU binary as fallback
    cp ${builtins.elemAt srcs 0} $out/lib/voxtype/voxtype-cpu
    chmod +x $out/lib/voxtype/voxtype-cpu

    # Install Vulkan binary
    cp ${builtins.elemAt srcs 1} $out/lib/voxtype/voxtype-vulkan
    chmod +x $out/lib/voxtype/voxtype-vulkan

    # Install parakeet-rocm in lib too
    cp ${builtins.elemAt srcs 2} $out/lib/voxtype/voxtype-parakeet-rocm
    chmod +x $out/lib/voxtype/voxtype-parakeet-rocm

    # Create symlinks expected by voxtype
    ln -s $out/lib/voxtype/voxtype-parakeet-rocm $out/lib/voxtype/voxtype-gpu

    # Wrap main binary (parakeet-rocm) with ROCm support
    wrapProgram $out/bin/voxtype \
      --prefix PATH : ${lib.makeBinPath [ wtype wl-clipboard ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader rocmPackages.clr ]} \
      --prefix XDG_DATA_DIRS : /run/opengl-driver/share

    # Wrap CPU fallback binary
    wrapProgram $out/lib/voxtype/voxtype-cpu \
      --prefix PATH : ${lib.makeBinPath [ wtype wl-clipboard ]}

    # Wrap Vulkan binary
    wrapProgram $out/lib/voxtype/voxtype-vulkan \
      --prefix PATH : ${lib.makeBinPath [ wtype wl-clipboard ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader ]} \
      --prefix XDG_DATA_DIRS : /run/opengl-driver/share \
      --set GGML_VK_VISIBLE_DEVICES 0

    # Wrap parakeet-rocm binary in lib
    wrapProgram $out/lib/voxtype/voxtype-parakeet-rocm \
      --prefix PATH : ${lib.makeBinPath [ wtype wl-clipboard ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader rocmPackages.clr ]} \
      --prefix XDG_DATA_DIRS : /run/opengl-driver/share

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
