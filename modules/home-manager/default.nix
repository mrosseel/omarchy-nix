inputs: {
  config,
  pkgs,
  ...
}: let
  packages = import ../packages.nix {inherit pkgs;};

  themes = import ../themes.nix;
  selectedTheme = themes.${config.omarchy.theme};
in {
  imports = [
    (import ./hyprland.nix inputs)
    (import ./hyprlock.nix inputs)
    (import ./swaybg.nix)
    (import ./hypridle.nix)
    (import ./ghostty.nix)
    (import ./btop.nix)
    (import ./direnv.nix)
    (import ./git.nix)
    (import ./mako.nix)
    # (import ./starship.nix)
    (import ./vscode.nix)
    (import ./waybar.nix inputs)
    (import ./walker.nix)
    (import ./zoxide.nix)
    (import ./zsh.nix)
  ];

  home.file = {
    ".local/share/omarchy/bin" = {
      source = ../../bin;
      recursive = true;
    };
  };
  home.packages = packages.homePackages;

  colorScheme = inputs.nix-colors.colorSchemes.${selectedTheme.base16-theme};

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  # TODO: Add an actual nvim config
  programs.neovim.enable = true;
}
