{...}: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    shellAliases = {
      # Fix zoxide interference with git commands in Claude Code
      cc = ''SHELL="/bin/bash" claude'';
    };
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
