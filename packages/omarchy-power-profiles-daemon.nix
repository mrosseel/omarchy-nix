{
  lib,
  power-profiles-daemon,
}:
# Omarchy replaces stock power-profiles-daemon with this build. It is stock 0.30
# plus six patches. Stock 0.30 has no cppc_cpufreq driver, so profiles do
# nothing on ARM laptops. Upstream goes back to stock once MR !236 and !239
# merge. The patches come from omacom/omarchy-pkgs
# (pkgbuilds/omarchy-power-profiles-daemon, pkgrel 5) and apply in the same
# order as the PKGBUILD's prepare().
#
# Set it as services.power-profiles-daemon.package. The NixOS module then
# installs the D-Bus service, the polkit policy and powerprofilesctl from it.
power-profiles-daemon.overrideAttrs (old: {
  pname = "omarchy-power-profiles-daemon";

  patches =
    (old.patches or [])
    ++ map (name: ./power-profiles-daemon-patches/${name}) [
      # NVIDIA RTX Spark (N1X) cppc_cpufreq driver. Upstream MR !236.
      "nvidia-rtx-spark-power-profiles.patch"
      # The GB10 desktops report "GB10", so the driver above matches it too.
      "nvidia-gb10.patch"
      # Merged upstream after 0.30 (!238, !237).
      "balanced-performance-spelling.patch"
      "cpufreq-boost-driver.patch"
      # Snapdragon X frequency caps per profile. Upstream MR !239.
      "cpufreq-caps.patch"
      # Apple Silicon without boost frequencies (M3 Max) caps power-saver.
      "cpufreq-apple-no-boost.patch"
    ];

  meta =
    old.meta
    // {
      description = "Power profiles over D-Bus, with NVIDIA RTX Spark, GB10 and Snapdragon X CPU profiles";
      homepage = "https://github.com/omacom/omarchy-pkgs/tree/main/pkgbuilds/omarchy-power-profiles-daemon";
      license = lib.licenses.gpl3Only;
    };
})
