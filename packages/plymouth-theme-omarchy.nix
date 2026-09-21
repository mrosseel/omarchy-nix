{
  pkgs,
  lib,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "plymouth-theme-omarchy";
  version = "1.0.0";

  # Use local assets from our repo
  src = ./plymouth-assets;

  buildInputs = [pkgs.imagemagick];

  buildPhase = ''
        mkdir -p theme

        # Copy all image assets from our repo
        cp $src/*.png theme/

        # Create omarchy.plymouth file
        cat > theme/omarchy.plymouth << 'EOF'
    [Plymouth Theme]
    Name=Omarchy
    Description=Omarchy splash screen.
    ModuleName=script

    [script]
    ImageDir=$out/share/plymouth/themes/omarchy
    ScriptFile=$out/share/plymouth/themes/omarchy/omarchy.script
    ConsoleLogBackgroundColor=0x1a1b26
    EOF

        # The upstream script, vendored verbatim from
        # default/plymouth/omarchy.script so a sync is a plain overwrite.
        cp $src/omarchy.script theme/omarchy.script
  '';

  installPhase = ''
    mkdir -p $out/share/plymouth/themes/omarchy
    cp -r theme/* $out/share/plymouth/themes/omarchy/

    # Fix the .plymouth file to have correct paths
    sed -i "s|$out|$out|g" $out/share/plymouth/themes/omarchy/omarchy.plymouth
  '';

  meta = with lib; {
    description = "Omarchy Plymouth boot splash theme";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
