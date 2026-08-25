{
  description = "Omarchy - Base configuration flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # 0.56 fixed alpha premultiplication in the color-management shader
    # (hyprwm/Hyprland#14403); quattro's opacity values are tuned for it, so the
    # vendored default/hypr looks wrong on 0.55.
    hyprland.url = "github:hyprwm/Hyprland/v0.56.0";
    nix-colors.url = "github:misterio77/nix-colors";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Omarchy 4 (quattro) is back on packaged quickshell now that 0.3.1 kills
    # synchronously; nixpkgs still lags (0.3.0), so pin the release tag.
    quickshell = {
      url = "github:quickshell-mirror/quickshell/v0.3.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    hyprland,
    nix-colors,
    home-manager,
    quickshell,
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
