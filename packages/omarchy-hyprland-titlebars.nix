{
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  # Pass the Hyprland the session runs (the omarchy-nix flake input). A Hyprland
  # plugin loads only into the exact Hyprland build it was compiled against.
  hyprland,
}:
# Titlebars for quattro's floating workspace mode. default/hypr/workspace-modes.lua
# loads titlebars.so with hl.plugin.load the first time a workspace floats.
#
# This follows nixpkgs' mkHyprlandPlugin: Hyprland's own stdenv and its build
# inputs, so the plugin sees the same headers and compiler as the compositor.
hyprland.stdenv.mkDerivation (finalAttrs: {
  pname = "omarchy-hyprland-titlebars";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "omacom";
    repo = "omarchy-hyprland-titlebars";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9IvWEwzormNICqCI2V1ss64hes6FNOWFsKc2GcM+6V4=";
  };

  nativeBuildInputs = [cmake pkg-config];
  buildInputs = [hyprland] ++ hyprland.buildInputs;

  # CMakeLists.txt installs the plugin as
  # lib/omarchy-hyprland-titlebars/titlebars.so, the same layout as the
  # PKGBUILD under /usr.
  postInstall = ''
    install -Dm644 ../LICENSE $out/share/licenses/omarchy-hyprland-titlebars/LICENSE
    install -Dm644 ../LICENSE.MIT $out/share/licenses/omarchy-hyprland-titlebars/LICENSE.MIT
  '';

  passthru.pluginPath = "${finalAttrs.finalPackage}/lib/omarchy-hyprland-titlebars/titlebars.so";

  meta = {
    description = "Titlebars for Omarchy's floating workspaces";
    homepage = "https://github.com/omacom/omarchy-hyprland-titlebars";
    license = [lib.licenses.bsd3 lib.licenses.mit];
    platforms = lib.platforms.linux;
  };
})
