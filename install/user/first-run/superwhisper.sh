#!/bin/bash

# Superwhisper ships as the default dictation backend, but its per-user setup
# (service, shortcuts, bar panel) needs a live session, so it runs here rather
# than in the image. Unattended: no settings window, no toast. An image built
# without the package is left alone, since first-run cannot ask for sudo.
#
# Omarchy-Nix: upstream asks pacman (omarchy-pkg-present) for the package.
# Here the superwhisper command and its installer script must both be on PATH.

set -e

if omarchy-cmd-present superwhisper omarchy-install-dictation-superwhisper &&
  [[ $(omarchy-default-dictation 2>/dev/null) == "superwhisper" ]]; then
  omarchy-install-dictation-superwhisper --background
fi
