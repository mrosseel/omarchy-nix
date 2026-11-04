{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3,
}:
# The engine behind `omarchy agent local`: a Python tool with no dependencies
# outside the standard library, plus the curated recipe catalog it reads from
# its own install directory. It runs the models as rootless Podman containers
# through systemd user Quadlet units. Podman, crun and the models are not part
# of this package.
#
# The agents panel and omarchy-agent reach it through omarchy-agent-local,
# which runs `omarchy-local-ai` from PATH.
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "omarchy-local-ai";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "omarchy-local-ai";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0c0oW+FkQgBwma/ajH1yglXJDM7wOK+Gc7ji8EAPIcY=";
  };

  dontBuild = true;

  # The entry point starts with #!/usr/bin/python3. patchShebangs points it at
  # this interpreter.
  buildInputs = [python3];
  nativeCheckInputs = [python3];

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    python3 ./omarchy-local-ai validate .
    runHook postCheck
  '';

  # The engine finds the catalog next to its own real path, so the catalog and
  # the engine ship as one tree, as in the PKGBUILD.
  installPhase = ''
    runHook preInstall

    share=$out/share/omarchy-local-ai
    install -dm755 $share
    cp -a catalog.toml best.toml recipes runtimes reviews measurements $share/
    install -Dm644 agent_local.py $share/agent_local.py
    install -Dm755 omarchy-local-ai $share/omarchy-local-ai

    install -dm755 $out/bin
    ln -s $share/omarchy-local-ai $out/bin/omarchy-local-ai

    install -Dm644 README.md $out/share/doc/omarchy-local-ai/README.md
    install -Dm644 docs/engine.md $out/share/doc/omarchy-local-ai/engine.md
    install -Dm644 LICENSE $out/share/licenses/omarchy-local-ai/LICENSE

    runHook postInstall
  '';

  meta = {
    description = "Run open models locally for Omarchy's coding agents, with curated recipes per machine";
    homepage = "https://github.com/omacom/omarchy-local-ai";
    license = lib.licenses.mit;
    mainProgram = "omarchy-local-ai";
    platforms = lib.platforms.linux;
  };
})
