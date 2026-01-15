{...}: {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "omarchy-lock-screen";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        inhibit_sleep = 3; # wait until screen is locked before sleep
      };
      listener = [
        {
          timeout = 150; # 2.5 minutes
          on-timeout = "pidof hyprlock || omarchy-launch-screensaver";
        }
        {
          timeout = 151; # just after screensaver starts
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330; # 5.5 minutes
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
        }
      ];
    };
  };
}
