{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omarchy;
  voxtype = pkgs.callPackage ../../packages/voxtype.nix {};
in {
  config = lib.mkIf cfg.voxtype.enable {
    # Create /usr/lib/voxtype symlink for voxtype's hardcoded path
    # voxtype expects to find voxtype-vulkan in /usr/lib/voxtype/
    # Also create libvulkan.so.1 symlink for voxtype's Vulkan detection
    systemd.tmpfiles.rules = [
      "d /usr/lib 0755 root root -"
      "L+ /usr/lib/voxtype - - - - ${voxtype}/lib/voxtype"
      "L+ /usr/lib/libvulkan.so.1 - - - - ${pkgs.vulkan-loader}/lib/libvulkan.so.1"
    ];

    # Enable Vulkan support via Mesa RADV (for AMD/Intel) or nvidia driver
    # Required for voxtype GPU acceleration
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
