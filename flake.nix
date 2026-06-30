{
  description = "Omarchy - Base configuration flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Use v0.53.0+ for start-hyprland script support
    hyprland.url = "github:hyprwm/Hyprland/v0.55.3";
    nix-colors.url = "github:misterio77/nix-colors";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Omarchy 4 (quattro) tracks rolling quickshell; nixpkgs lags (0.3.0), which
    # left the bg reveal transition + network/weather panels broken. Pin upstream.
    quickshell = {
      url = "github:quickshell-mirror/quickshell";
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
