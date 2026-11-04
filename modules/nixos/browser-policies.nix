{
  config,
  lib,
  pkgs,
  ...
}: let
  # Upstream default/chromium/policies/omarchy.json, which
  # install/helpers/browser-policy.sh installs in each managed policy dir.
  # Links reach the browser through omarchy-browser.desktop, so the browser
  # never sees itself as the default. Hide its check and its button to become
  # one, which would rewrite mimeapps.list behind Omarchy's back.
  omarchyPolicy = builtins.toJSON {DefaultBrowserSettingEnabled = false;};
in {
  # Create policy directories for browser theme management
  # These directories allow runtime theme color changes for Chromium and Brave
  systemd.tmpfiles.rules = [
    "d /etc/chromium/policies/managed 0777 root root -"
    "d /etc/brave/policies/managed 0777 root root -"
  ];

  environment.etc."chromium/policies/managed/omarchy.json".text = omarchyPolicy;
  environment.etc."brave/policies/managed/omarchy.json".text = omarchyPolicy;
}
