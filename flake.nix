{
  description = "Omarchy - Base configuration flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Pin to v0.52.2 to match Omarchy (Arch Linux stable)
    hyprland.url = "github:hyprwm/Hyprland/v0.52.2";
    nix-colors.url = "github:misterio77/nix-colors";
    # Fork with state handler nil pointer fix applied
    elephant.url = "git+file:///home/mike/dev/elephant-patched?ref=fix-state-handler";
    walker.url = "github:abenz1267/walker/v2.12.2";
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
