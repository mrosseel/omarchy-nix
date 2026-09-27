# Omarchy-Nix: upstream also offers "Update System" once the network is up.
# That runs omarchy-update, which uses pacman. On Nix the system is updated by
# a rebuild of the flake, so the update prompt is left out.

notify_wifi() {
  omarchy-notification-send -u critical -g 󰖩 "Setup Wi-Fi" "Click to configure the wireless network." \
    --exec omarchy-shell shell toggle omarchy.network
}

announce_network() {
  # Ethernet is still negotiating DHCP when the session starts, so probing
  # right away calls a working machine offline. NetworkManager reports startup
  # complete once it has tried every connection it could auto-activate, which
  # is the first moment the answer means anything.
  nm-online -q -s -t 30

  # -x takes that answer as it stands rather than waiting out the timeout, so
  # a laptop with nothing to connect to gets prompted immediately.
  if ! nm-online -q -x -t 30; then
    notify_wifi
  fi
}

# Detached, so a slow or absent connection never holds up the rest of first run.
announce_network &
