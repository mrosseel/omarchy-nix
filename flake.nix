{
  description = "Omarchy - Base configuration flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Use v0.53.0+ for start-hyprland script support
    hyprland.url = "github:hyprwm/Hyprland/v0.53.1";
    nix-colors.url = "github:misterio77/nix-colors";
    elephant.url = "github:abenz1267/elephant";
    walker.url = "github:abenz1267/walker/v2.13.0";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    hyprland,
    nix-colors,
    elephant,
    walker,
    home-manager,
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
