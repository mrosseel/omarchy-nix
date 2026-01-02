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

  # Add user to docker group for permission access (like omarchy does with usermod -aG docker ${USER})
  users.users.${cfg.username} = lib.mkIf config.virtualisation.docker.enable {
    extraGroups = ["docker"];
  };
}
