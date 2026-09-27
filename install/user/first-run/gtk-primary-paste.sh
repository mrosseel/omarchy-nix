# Omarchy-Nix: a no-op. Upstream turns on middle-click paste in GTK at first
# login. On Nix, first-run can run on a machine that is already set up, so it
# does not change a value the user has set. Set it with Home Manager:
#   dconf.settings."org/gnome/desktop/interface".gtk-enable-primary-paste

exit 0
