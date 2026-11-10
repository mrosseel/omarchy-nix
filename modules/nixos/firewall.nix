{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omarchy;
in {
  config = lib.mkIf (cfg ? firewall && cfg.firewall.enable) {
    # Enable the firewall
    networking.firewall.enable = true;

    # Basic firewall configuration
    networking.firewall = {
      # Combine all allowed TCP ports
      allowedTCPPorts =
        (lib.optionals (cfg.firewall.allow_ssh) [22])
        ++ (lib.optionals (cfg.firewall.allow_dev_ports) [
          3000 # React/Node.js dev server
          3001 # Alternative dev server
          4000 # Rails/Phoenix dev server
          5000 # Flask dev server
          8000 # Django/HTTP dev server
          8080 # Alternative HTTP server
          9000 # Alternative dev server
        ])
        ++ cfg.firewall.allowed_tcp_ports;

      # Custom allowed UDP ports
      allowedUDPPorts = cfg.firewall.allowed_udp_ports;
    };

    # Docker firewall protection
    # This prevents Docker from bypassing ufw rules
    systemd.services.docker-firewall-setup = lib.mkIf (cfg.firewall.docker_protection && config.virtualisation.docker.enable) {
      description = "Configure Docker firewall rules";
      after = ["docker.service" "network.target"];
      wants = ["docker.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeScript "setup-docker-firewall" ''
          #!${pkgs.bash}/bin/bash
          set -euo pipefail

          ipt=${pkgs.iptables}/bin/iptables

          # Ensure Docker doesn't bypass firewall rules
          # Rebuild the DOCKER-USER chain from scratch so reruns don't stack duplicate rules
          $ipt -N DOCKER-USER 2>/dev/null || true
          $ipt -F DOCKER-USER

          # Allow Docker containers to reach the host (for development)
          $ipt -A DOCKER-USER -s 172.16.0.0/12 -d 172.17.0.1 -j ACCEPT

          # Allow internal Docker network communication
          $ipt -A DOCKER-USER -s 172.16.0.0/12 -d 172.16.0.0/12 -j ACCEPT

          # Allow loopback traffic
          $ipt -A DOCKER-USER -o lo -j ACCEPT
          $ipt -A DOCKER-USER -i lo -j ACCEPT

          # Allow established and related connections
          $ipt -A DOCKER-USER -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

          # Let trusted interfaces (networking.firewall.trustedInterfaces, e.g. tailscale0
          # for exit node / subnet routing) skip the Docker drop
          ${lib.concatMapStrings (i: "$ipt -A DOCKER-USER -i ${i} -j RETURN\n") (lib.remove "lo" config.networking.firewall.trustedInterfaces)}

          # Block all other forward traffic
          $ipt -A DOCKER-USER -j DROP

          echo "Docker firewall rules applied successfully"
        '';
      };
    };
  };
}
