{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.omarchy;
  colors = config.colorScheme.palette;
in {
  programs.walker = {
    enable = true;
    runAsService = true;
    
    # Configure walker with theme colors
    config = {
      search = {
        delay = 0;
        placeholder = "Search applications...";
      };
      
      ui = {
        fullscreen = false;
        width = 600;
        height = 400;
        margins = {
          top = 100;
          bottom = 100;
          end = 0;
          start = 0;
        };
        anchors = {
          top = true;
          left = false;
          right = false;
          bottom = false;
        };
      };
      
      list = {
        height = 200;
        always_show = true;
      };
      
      modules = [
        {
          name = "applications";
          prefix = "";
        }
        {
          name = "runner";
          prefix = ">";  
        }
        {
          name = "calc";
          prefix = "=";
        }
        {
          name = "emojis";
          prefix = ":";
        }
      ];
    };
    
    # Style walker with current theme colors
    style = ''
      * {
        color: #${colors.base05};
        font-family: "CaskaydiaMono Nerd Font";
        font-size: 14px;
      }
      
      #window {
        background-color: rgba(${toString (lib.toInt "0x${colors.base00}")}, ${toString (lib.toInt "0x${colors.base00}")}, ${toString (lib.toInt "0x${colors.base00}")}, 0.9);
        border: 2px solid #${colors.base0C};
        border-radius: 10px;
      }
      
      #input {
        background-color: #${colors.base01};
        border: 1px solid #${colors.base03};
        border-radius: 5px;
        padding: 8px 12px;
        margin: 10px;
        color: #${colors.base05};
      }
      
      #list {
        background-color: transparent;
        margin: 0px 10px 10px 10px;
      }
      
      .item {
        background-color: transparent;
        border-radius: 5px;
        margin: 2px 0px;
        padding: 8px;
      }
      
      .item:selected {
        background-color: #${colors.base02};
        color: #${colors.base0D};
      }
      
      .item:hover {
        background-color: #${colors.base02};
      }
      
      .item .label {
        color: #${colors.base05};
      }
      
      .item:selected .label {
        color: #${colors.base0D};
      }
    '';
  };
}