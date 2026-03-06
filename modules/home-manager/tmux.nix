{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
    ];
    extraConfig = builtins.readFile ../../config/tmux/tmux.conf;
  };
}
