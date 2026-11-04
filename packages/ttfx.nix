{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
}:
# quattro replaced python-terminaltexteffects with ttfx, a parity-exact Rust
# port that renders byte-identical frames from a single dependency-free binary.
# omarchy-screensaver links the same crate for its effects.
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ttfx";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "ttfx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/cECljrthspJsg6fgWMm4QIv8V3FJLuP/pbZoRKFVAc=";
  };

  cargoHash = "sha256-xSv2a0Q1biE20cOHkSOADxFfRNYKH/1MNCA03hQX9pE=";

  nativeBuildInputs = [installShellFiles];

  # The PKGBUILD ships the bash and zsh completions the binary prints.
  postInstall =
    ''
      install -Dm644 LICENSE $out/share/licenses/ttfx/LICENSE
      install -Dm644 NOTICE $out/share/licenses/ttfx/NOTICE
      install -Dm644 README.md $out/share/doc/ttfx/README.md
    ''
    + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installShellCompletion --cmd ttfx \
        --bash <($out/bin/ttfx --print-completion bash) \
        --zsh <($out/bin/ttfx --print-completion zsh)
    '';

  meta = {
    description = "Terminal text effects as a single static binary";
    homepage = "https://github.com/omacom/ttfx";
    license = lib.licenses.mit;
    mainProgram = "ttfx";
    platforms = lib.platforms.linux;
  };
})
