{
  config,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = cfg.full_name;
        email = cfg.email_address;
      };
      credential.helper = "store";

      # Upstream config/git/config defaults. Per-leaf mkDefault so a user's
      # own programs.git.settings win key by key.
      alias = {
        co = lib.mkDefault "checkout";
        br = lib.mkDefault "branch";
        ci = lib.mkDefault "commit";
        st = lib.mkDefault "status";
      };
      init.defaultBranch = lib.mkDefault "master";
      # Rebase (instead of merge) on pull
      pull.rebase = lib.mkDefault true;
      # Automatically set upstream branch on push
      push.autoSetupRemote = lib.mkDefault true;
      diff = {
        # Clearer diffs on moved/edited lines
        algorithm = lib.mkDefault "histogram";
        # Highlight moved blocks in diffs
        colorMoved = lib.mkDefault "plain";
        # More intuitive refs in diff output
        mnemonicPrefix = lib.mkDefault true;
      };
      # Include diff comment in commit message template
      commit.verbose = lib.mkDefault true;
      # Output in columns when possible
      column.ui = lib.mkDefault "auto";
      # Sort branches by most recent commit first
      branch.sort = lib.mkDefault "-committerdate";
      # Sort version numbers as you would expect
      tag.sort = lib.mkDefault "-version:refname";
      rerere = {
        # Record and reuse conflict resolutions
        enabled = lib.mkDefault true;
        # Apply stored conflict resolutions automatically
        autoupdate = lib.mkDefault true;
      };
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };
}
