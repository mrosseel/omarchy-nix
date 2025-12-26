{ config, lib, pkgs, ... }:

let
  cfg = config.omarchy;
in {
  config = lib.mkIf (cfg ? firewall && cfg.firewall.enable) {
    # Enable the firewall
    networking.firewall.enable = true;

    # Install ufw for easier firewall management
    environment.systemPackages = with pkgs; [
      ufw
    ];

    # Basic firewall configuration
    networking.firewall = {
      # Combine all allowed TCP ports
      allowedTCPPorts = 
        (lib.optionals (cfg.firewall.allow_ssh) [ 22 ]) ++
        (lib.optionals (cfg.firewall.allow_dev_ports) [ 
          3000  # React/Node.js dev server
          3001  # Alternative dev server
          4000  # Rails/Phoenix dev server
          5000  # Flask dev server
          8000  # Django/HTTP dev server
          8080  # Alternative HTTP server
          9000  # Alternative dev server
        ]) ++
        cfg.firewall.allowed_tcp_ports;

      # Custom allowed UDP ports
      allowedUDPPorts = cfg.firewall.allowed_udp_ports;
    };

    # Docker firewall protection
    # This prevents Docker from bypassing ufw rules
    systemd.services.docker-firewall-setup = lib.mkIf (cfg.firewall.docker_protection && config.virtualisation.docker.enable) {
      description = "Configure Docker firewall rules";
      after = [ "docker.service" "network.target" ];
      wants = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeScript "setup-docker-firewall" ''
          #!${pkgs.bash}/bin/bash
          set -euo pipefail
          
          # Ensure Docker doesn't bypass firewall rules
          # Add DOCKER-USER chain rules to control Docker traffic
          ${pkgs.iptables}/bin/iptables -N DOCKER-USER 2>/dev/null || true
          
          # Block all forward traffic by default for Docker
          ${pkgs.iptables}/bin/iptables -I DOCKER-USER -j DROP
          
          # Allow established and related connections
          ${pkgs.iptables}/bin/iptables -I DOCKER-USER -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
          
          # Allow loopback traffic
          ${pkgs.iptables}/bin/iptables -I DOCKER-USER -i lo -j ACCEPT
          ${pkgs.iptables}/bin/iptables -I DOCKER-USER -o lo -j ACCEPT
          
          # Allow internal Docker network communication
          ${pkgs.iptables}/bin/iptables -I DOCKER-USER -s 172.16.0.0/12 -d 172.16.0.0/12 -j ACCEPT
          
          # Allow Docker containers to reach the host (for development)
          ${pkgs.iptables}/bin/iptables -I DOCKER-USER -s 172.16.0.0/12 -d 172.17.0.1 -j ACCEPT
          
          echo "Docker firewall rules applied successfully"
        '';
      };
    };

    # UFW configuration via systemd service
    systemd.services.ufw-setup = lib.mkIf (cfg.firewall.use_ufw) {
      description = "Configure UFW firewall";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeScript "setup-ufw" ''
          #!${pkgs.bash}/bin/bash
          set -euo pipefail
          
          # Enable UFW if not already enabled
          ${pkgs.ufw}/bin/ufw --force enable
          
          # Set default policies
          ${pkgs.ufw}/bin/ufw default deny incoming
          ${pkgs.ufw}/bin/ufw default allow outgoing
          
          # Allow SSH if configured
          ${lib.optionalString (cfg.firewall.allow_ssh) "${pkgs.ufw}/bin/ufw allow ssh"}
          
          # Allow development ports if configured
          ${lib.optionalString (cfg.firewall.allow_dev_ports) ''
            ${pkgs.ufw}/bin/ufw allow 3000/tcp
            ${pkgs.ufw}/bin/ufw allow 3001/tcp
            ${pkgs.ufw}/bin/ufw allow 4000/tcp
            ${pkgs.ufw}/bin/ufw allow 5000/tcp
            ${pkgs.ufw}/bin/ufw allow 8000/tcp
            ${pkgs.ufw}/bin/ufw allow 8080/tcp
            ${pkgs.ufw}/bin/ufw allow 9000/tcp
          ''}
          
          echo "UFW configuration completed successfully"
        '';
      };
    };
  };
}