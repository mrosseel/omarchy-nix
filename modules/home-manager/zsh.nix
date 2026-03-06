{...}: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    initExtra = ''
      # Source tmux layout functions (tdl, tdlm, tsl)
      for fn in ~/.local/share/omarchy/default/bash/fns/*; do
        [[ -f "$fn" ]] && source "$fn"
      done
    '';
    zplug = {
      enable = true;
      plugins = [
        {
          name = "plugins/git";
          tags = [from:oh-my-zsh];
        }
        {
          name = "fdellwing/zsh-bat";
          tags = [as:command];
        }
      ];
    };
  };
}
