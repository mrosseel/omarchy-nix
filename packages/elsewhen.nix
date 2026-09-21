{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}:
# Elsewhen is the world clock plugin quattro installs by default and places
# immediately before the centre clock in config/omarchy/shell.json. The shell
# loads it from its bundled plugin directory, so the tree lands under
# share/omarchy/shell/plugins/omacom.elsewhen and omarchy-shell.nix links it in.
stdenv.mkDerivation (finalAttrs: {
  pname = "elsewhen";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "elsewhen";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UZ+p/ZkqtjGOxwxFaCXRkBzlJeyWHRP3VrlH04ylak8=";
  };

  dontBuild = true;

  # worldclock-data.py is run as `python3 <path>`, so it needs an interpreter on
  # PATH rather than an execute bit.
  buildInputs = [python3];

  # Mirrors the PKGBUILD's allow-list, so tests/ and .github/ never ship.
  installPhase = ''
    runHook preInstall

    plugin=$out/share/omarchy/shell/plugins/omacom.elsewhen
    for file in manifest.json cities.json world.json worldclock-data.py *.qml *.js; do
      install -Dm644 "$file" "$plugin/$file"
    done

    install -Dm644 LICENSE $out/share/licenses/elsewhen/LICENSE

    runHook postInstall
  '';

  meta = {
    description = "World clock plugin for the Omarchy shell, with a spinnable globe";
    homepage = "https://github.com/omacom/elsewhen";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
