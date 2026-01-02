{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
  colors = config.colorScheme.palette;

  # Walker config deployed via static files instead of home-manager module
  # See modules/home-manager/default.nix for file deployment
in {
  # Walker is configured manually via deployed config files
  # Not using programs.walker home-manager module to avoid conflicts
}