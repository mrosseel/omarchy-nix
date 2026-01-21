{
  config,
  lib,
  pkgs,
  ...
}: {
  # Create policy directories for browser theme management
  # These directories allow runtime theme color changes for Chromium and Brave
  systemd.tmpfiles.rules = [
    "d /etc/chromium/policies/managed 0777 root root -"
    "d /etc/brave/policies/managed 0777 root root -"
  ];
}
