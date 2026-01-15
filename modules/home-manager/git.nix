{config, ...}: let
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
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };
}
