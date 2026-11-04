{
  description = "Omarchy - Base configuration flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # quattro targets Hyprland 0.57: the vendored default/hypr uses its Lua API,
    # and omarchy-hyprland-titlebars only loads into the Hyprland it was built
    # against. 0.56 already fixed alpha premultiplication (hyprwm/Hyprland#14403),
    # which quattro's opacity values are tuned for.
    hyprland.url = "github:hyprwm/Hyprland/v0.57.1";
    nix-colors.url = "github:misterio77/nix-colors";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Omarchy 4 (quattro) uses packaged quickshell. 0.3.1 kills synchronously,
    # but it does not compile against the Qt 6.12 in current nixpkgs, and 0.3.2
    # does. nixpkgs still lags (0.3.0), so pin the release tag.
    quickshell = {
      url = "github:quickshell-mirror/quickshell/v0.3.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Hex dictation, built from source with the vendor's own nix/package.nix.
    # Upstream installs the prebuilt hex-bin; the source is MIT.
    hex = {
      url = "github:anomalyco/hex/v3.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    hyprland,
    nix-colors,
    home-manager,
    quickshell,
    hex,
  }: {
    nixosModules = {
      default = {
        config,
        lib,
        pkgs,
        ...
      }: {
        imports = [
          (import ./modules/nixos/default.nix inputs)
        ];

        options.omarchy = (import ./config.nix lib).omarchyOptions;
        config = {
          nixpkgs.config.allowUnfree = true;
        };
      };
    };

    homeManagerModules = {
      default = {
        config,
        lib,
        pkgs,
        osConfig ? {},
        ...
      }: {
        imports = [
          nix-colors.homeManagerModules.default
          (import ./modules/home-manager/default.nix inputs)
        ];
        options.omarchy = (import ./config.nix lib).omarchyOptions;
        config = lib.mkIf (osConfig ? omarchy) {
          omarchy = osConfig.omarchy;
        };
      };
    };
  };
}
