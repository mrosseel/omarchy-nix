{
  config,
  pkgs,
  lib,
  ...
}: let
  themes = import ../themes.nix;
  availableThemes = builtins.attrNames themes;
  
  themeUpdateScript = pkgs.writeShellScript "omarchy-theme-update" ''
    set -euo pipefail
    
    THEME_FILE="$HOME/.config/omarchy/current-theme"
    CONFIG_PATH="$HOME/nixos-config"
    
    # Check if theme file exists
    if [[ ! -f "$THEME_FILE" ]]; then
      echo "No theme file found at $THEME_FILE"
      exit 0
    fi
    
    # Read the requested theme
    THEME_NAME=$(cat "$THEME_FILE")
    
    # Validate theme
    AVAILABLE_THEMES=(${lib.concatStringsSep " " (map (t: ''"${t}"'') availableThemes)})
    if [[ ! " ''${AVAILABLE_THEMES[@]} " =~ " $THEME_NAME " ]]; then
      echo "Invalid theme: $THEME_NAME"
      echo "Available themes: ''${AVAILABLE_THEMES[*]}"
      exit 1
    fi
    
    echo "Switching to theme: $THEME_NAME"
    
    # Update configuration file
    if [[ ! -d "$CONFIG_PATH" ]]; then
      echo "Error: NixOS configuration directory not found at $CONFIG_PATH"
      exit 1
    fi
    
    cd "$CONFIG_PATH"
    
    # Find the configuration file that contains theme setting
    CONFIG_FILE=$(${pkgs.gnugrep}/bin/grep -r -l "theme.*=" . --include="*.nix" | head -1)
    if [[ -z "$CONFIG_FILE" ]]; then
      echo "Error: Could not find theme setting in configuration"
      exit 1
    fi
    
    echo "Found configuration file: $CONFIG_FILE"
    
    # Create backup
    ${pkgs.coreutils}/bin/cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(${pkgs.coreutils}/bin/date +%s)"
    
    # Update the theme in the config file
    if ${pkgs.gnused}/bin/sed -i "s/theme = \"[^\"]*\"/theme = \"$THEME_NAME\"/g" "$CONFIG_FILE"; then
      echo "Configuration updated successfully"
      
      # Rebuild system configuration
      echo "Rebuilding system configuration..."
      if /run/wrappers/bin/sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake .; then
        echo "Theme switched to $THEME_NAME successfully!"
        
        # Restart components that need reload
        ${pkgs.procps}/bin/pkill -SIGUSR2 waybar 2>/dev/null || true
        ${pkgs.procps}/bin/pkill swayosd-server 2>/dev/null || true
        ${pkgs.util-linux}/bin/setsid swayosd-server &>/dev/null &
        ${pkgs.mako}/bin/makoctl reload 2>/dev/null || true
        ${pkgs.hyprland}/bin/hyprctl reload 2>/dev/null || true
        
        # Update wallpaper
        "$HOME/.local/share/omarchy/bin/omarchy-bg-next" 2>/dev/null || true
        
        # Send notification
        ${pkgs.libnotify}/bin/notify-send "Theme changed to $THEME_NAME" -t 3000 2>/dev/null || true
      else
        echo "Failed to rebuild system configuration"
        # Restore backup
        ${pkgs.coreutils}/bin/mv "$CONFIG_FILE.backup."* "$CONFIG_FILE" 2>/dev/null || true
        exit 1
      fi
    else
      echo "Failed to update configuration file"
      exit 1
    fi
  '';
in {
  systemd.user = {
    services.omarchy-theme-switcher = {
      Unit = {
        Description = "Omarchy theme switcher service";
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${themeUpdateScript}";
        Environment = [
          "PATH=${lib.makeBinPath [
            pkgs.nixos-rebuild
            pkgs.gnugrep
            pkgs.gnused
            pkgs.coreutils
            pkgs.procps
            pkgs.util-linux
            pkgs.mako
            pkgs.hyprland
            pkgs.libnotify
          ]}"
        ];
      };
    };

    paths.omarchy-theme-watcher = {
      Unit = {
        Description = "Watch for Omarchy theme changes";
        Documentation = "Automatically rebuilds system when theme file changes";
      };
      Path = {
        PathChanged = "%h/.config/omarchy/current-theme";
        Unit = "omarchy-theme-switcher.service";
      };
      Install = {
        WantedBy = [ "paths.target" ];
      };
    };
  };

  # Create the initial theme file if it doesn't exist
  home.activation.omarchy-theme-init = lib.hm.dag.entryAfter ["writeBoundary"] ''
    THEME_FILE="$HOME/.config/omarchy/current-theme"
    if [[ ! -f "$THEME_FILE" ]]; then
      mkdir -p "$(dirname "$THEME_FILE")"
      echo "${config.omarchy.theme}" > "$THEME_FILE"
    fi
  '';
}