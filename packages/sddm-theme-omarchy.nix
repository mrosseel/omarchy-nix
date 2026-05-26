{ pkgs, lib, ... }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "sddm-theme-omarchy";
  version = "1.0";

  src = ../default/sddm/omarchy;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -dm755 $out/share/sddm/themes/omarchy
    cp -r $src/. $out/share/sddm/themes/omarchy/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Omarchy SDDM theme (terminal-style minimal greeter)";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
