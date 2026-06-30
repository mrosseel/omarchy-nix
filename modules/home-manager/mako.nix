{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  # Retired by the Omarchy 4 shell (omarchy-shell owns notifications). Gated off
  # when omarchy.shell.enable so the shell's notifications plugin is sole owner.
  config = lib.mkIf (!cfg.shell.enable) {
    # Enable mako service
    services.mako.enable = true;

    # Install mako core config
    home.file.".local/share/omarchy/default/mako/core.ini".source = ../../default/mako/core.ini;

    # Mako config reads from symlinked theme directory
    xdg.configFile."mako/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/omarchy/current/theme/mako.ini";
  };
}
