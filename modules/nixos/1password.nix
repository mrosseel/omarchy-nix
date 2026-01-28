{config, ...}: let
  cfg = config.omarchy;
in {
  programs = {
    _1password.enable = true;
    _1password-gui.enable = true;
    _1password-gui.polkitPolicyOwners = [cfg.username];
  };
}
