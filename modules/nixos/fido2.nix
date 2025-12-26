{ config, lib, pkgs, ... }:

let
  cfg = config.omarchy;
in {
  config = lib.mkIf (cfg ? fido2_auth && cfg.fido2_auth.enable) {
    # Enable FIDO2/WebAuthn support
    security.pam.u2f = {
      enable = true;
      # Allow fallback to password if FIDO2 fails
      cue = true;
      # Interactive mode for user prompts
      interactive = true;
    };

    # Required packages for FIDO2 support
    environment.systemPackages = with pkgs; [
      libfido2
      pamu2fcfg  # Tool for mapping FIDO2 devices
      yubikey-manager
      yubikey-personalization
    ];

    # udev rules for FIDO2 devices
    services.udev.packages = with pkgs; [
      yubikey-personalization
      libfido2
    ];

    # Enable smart card services (needed for some FIDO2 devices)
    services.pcscd.enable = true;

    # Configure PAM for sudo with FIDO2
    security.pam.services = lib.mkIf (cfg.fido2_auth.sudo_auth) {
      sudo = {
        u2fAuth = true;
        # Try FIDO2 first, then fall back to password
        text = lib.mkOrder 100 ''
          auth sufficient pam_u2f.so cue
          auth include system-auth
        '';
      };
    };

    # Add fingerprint support if enabled
    services.fprintd = lib.mkIf (cfg.fido2_auth.fingerprint_support) {
      enable = true;
    };

    # Configure PAM for fingerprint authentication
    security.pam.services = lib.mkIf (cfg.fido2_auth.fingerprint_support) {
      login.fprintAuth = true;
      sudo.fprintAuth = cfg.fido2_auth.sudo_auth;
      hyprlock.fprintAuth = true;
    };
  };
}