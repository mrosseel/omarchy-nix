{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
in {
  virtualisation.containers.enable = true;
  virtualisation = {
    docker.enable = true;
    # podman = {
    #   enable = true;
    #   dockerCompat = true;
    #   dockerSocket.enable = true;
    #   defaultNetwork.settings.dns_enabled = true;
    # };
  };

  # The docker group is root-equivalent, so upstream leaves the user out of it
  # by default and gates daemon access behind a polkit prompt instead
  # (omarchy-sudo-docker / omarchy-launch-docker-tui). Sudoless Docker is the
  # explicit opt-in.
  users.users.${cfg.username} = lib.mkIf (config.virtualisation.docker.enable && cfg.containers.sudoless_docker) {
    extraGroups = ["docker"];
  };
}
