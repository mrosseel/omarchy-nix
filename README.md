# Omarchy Nix

Omarchy-nix (Omanix?) is an opinionated NixOS flake to help you get started as fast as possible with NixOS and Hyprland. It is primarily a reimplementation of [DHH's Omarchy](https://github.com/basecamp/omarchy) project - an opinionated Arch/Hyprland setup for modern web development.

This was mostly spun up in a weekend so if you have any issues please let me know, my goal is to eventually make this as seamless an install experience as Omarchy itself!


## Quick Start

To get started you'll first need to set up a fresh [NixOS](https://nixos.org/) install. Just download and create a bootable USB and you should be good to go.


Once ready, add this flake to your system configuration, you'll also need [home-manager](https://github.com/nix-community/home-manager) as well:
(You can find my personal nix setup [here](https://github.com/henrysipp/nix-setup))
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
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
        home-manager.nixosModules.home-manager #Add this import
        {
          # Configure omarchy
          omarchy = {
            full_name = "Your Name";
            email_address = "your.email@example.com";
            theme = "tokyo-night";
            
            # Optional: Seamless boot experience (like original Omarchy)
            seamless_boot = {
              enable = true;              # Enable Plymouth + auto-login
              username = "your-username"; # Required for auto-login
              plymouth_theme = "omarchy"; # Boot splash theme
              silent_boot = true;         # Hide kernel messages
            };
          };
          
          home-manager = {
            users.your-username = {
              imports = [ omarchy-nix.homeManagerModules.default ]; # And this one
            };
          };
        }
      ];
    };
  };
}
```

## Configuration Options

### Basic Configuration
- `full_name` - Your full name for git and system configuration
- `email_address` - Your email address 
- `theme` - Color theme: "tokyo-night", "kanagawa", "everforest", "catppuccin", "nord", "gruvbox", "gruvbox-light"
- `monitors` - List of monitor configurations
- `scale` - Display scale factor (1 for 1x, 2 for 2x displays)

### Seamless Boot (New!)
Omarchy-nix now supports the seamless boot experience from the original Omarchy:

- `seamless_boot.enable` - Enable Plymouth boot splash + auto-login (default: true)
- `seamless_boot.username` - Username for auto-login (required when enabled)
- `seamless_boot.plymouth_theme` - Boot splash theme (default: "omarchy") 
- `seamless_boot.silent_boot` - Hide kernel messages during boot (default: true)

This provides the same smooth boot-to-desktop experience as the original Omarchy, with no visible terminal or login prompts after disk encryption.

Refer to [the root configuration](https://github.com/henrysipp/omarchy-nix/blob/main/config.nix) file for more information on what options are available. 

## License

This project is released under the MIT License, same as the original Omarchy.
