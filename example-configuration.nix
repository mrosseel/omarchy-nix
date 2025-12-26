# Example NixOS configuration using omarchy-nix with seamless boot
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    omarchy-nix = {
      url = "github:henrysipp/omarchy-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, omarchy-nix, home-manager, ... }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      modules = [
        omarchy-nix.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          # Configure omarchy with seamless boot
          omarchy = {
            full_name = "Your Name";
            email_address = "your.email@example.com";
            theme = "tokyo-night";
            
            # NEW: Seamless boot configuration
            seamless_boot = {
              enable = true;
              username = "your-username";  # Required for auto-login
              plymouth_theme = "omarchy";  # Default
              silent_boot = true;          # Default
            };
          };
          
          home-manager = {
            users.your-username = {
              imports = [ omarchy-nix.homeManagerModules.default ];
            };
          };
        }
      ];
    };
  };
}