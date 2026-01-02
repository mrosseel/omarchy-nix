{pkgs, ...}: {
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = ["Noto Serif"];
      sansSerif = ["Noto Sans"];
      monospace = ["Caskaydia Mono Nerd Font"];
    };
  };

  # Install omarchy icon font as a nix package
  home.packages = [
    (pkgs.stdenvNoCC.mkDerivation {
      name = "omarchy-font";
      src = ../../config;
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/share/fonts/truetype
        cp $src/omarchy.ttf $out/share/fonts/truetype/omarchy.ttf
      '';
    })
  ];
}
