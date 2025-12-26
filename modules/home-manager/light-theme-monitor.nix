{ config, lib, pkgs, ... }:

let
  lightModeFilePath = "${config.home.homeDirectory}/.config/omarchy/theme/light.mode";
  themeMonitorScript = pkgs.writeShellScript "omarchy-theme-monitor" ''
    set -euo pipefail
    
    # Ensure the theme directory exists
    mkdir -p "${config.home.homeDirectory}/.config/omarchy/theme"
    
    # Function to trigger home-manager switch
    trigger_theme_switch() {
      echo "Theme mode change detected, triggering home-manager switch..."
      ${config.home.homeManagerConfiguration.activationPackage}/bin/activate-home
    }
    
    # Watch for file creation/deletion events
    ${pkgs.inotify-tools}/bin/inotifywait -m -e create,delete,moved_to,moved_from \
      "${config.home.homeDirectory}/.config/omarchy/theme" \
      --format '%w%f %e' | while read file event; do
        if [[ "$file" == *"light.mode"* ]]; then
          echo "Light mode file change detected: $event"
          sleep 0.5  # Brief delay to avoid rapid switches
          trigger_theme_switch
        fi
    done
  '';
in {
  config = lib.mkIf config.omarchy.light_theme_detection.enable {
    # Create the theme directory structure
    home.file.".config/omarchy/theme/.keep".text = "";
    
    # Install theme monitoring utilities
    home.packages = with pkgs; [ inotify-tools ];
    
    # Systemd user service for theme monitoring
    systemd.user.services.omarchy-theme-monitor = {
      Unit = {
        Description = "Omarchy Theme Mode Monitor";
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${themeMonitorScript}";
        Restart = "always";
        RestartSec = "5";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}