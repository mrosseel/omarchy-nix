{
  callPackage,
  hexSrc,
}:
# Hex is one of the three dictation backends in quattro, next to Superwhisper
# and Voxtype. It is not the nixpkgs `hex` (a hex dump tool that installs
# `hx`). bin/omarchy-dictation-hex drives it with `hex dictation start|stop`,
# and bin/omarchy-install-dictation-hex runs `hex model install` and enables
# hex.service.
#
# Upstream installs the vendor's prebuilt release (OPR hex-bin). Omarchy-Nix
# builds the same release from source with the vendor's own nix/package.nix,
# and adds the user unit that hex-bin installs to /usr/lib/systemd/user.
(callPackage "${hexSrc}/nix/package.nix" {}).overrideAttrs (old: {
  postInstall =
    old.postInstall
    + ''
      install -Dm644 ${hexSrc}/packaging/hex.service $out/share/systemd/user/hex.service
      substituteInPlace $out/share/systemd/user/hex.service \
        --replace-fail /usr/bin/hex $out/bin/hex
    '';
})
