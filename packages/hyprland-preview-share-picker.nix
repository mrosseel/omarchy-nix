{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, gtk4
, gtk4-layer-shell
}:

rustPlatform.buildRustPackage rec {
  pname = "hyprland-preview-share-picker";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "WhySoBad";
    repo = "hyprland-preview-share-picker";
    rev = "v${version}";
    hash = "sha256-Zztb0soSN/NynWnBIGPuUNRKt2xSx/+f+QpYIPRyRdc=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-AqX9jKj7JLEx1SLefyaWYGbRdk0c3H/NDTIsZy6B6hY=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    gtk4
    gtk4-layer-shell
  ];

  meta = with lib; {
    description = "An alternative share picker for Hyprland with window and monitor previews";
    homepage = "https://github.com/WhySoBad/hyprland-preview-share-picker";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
