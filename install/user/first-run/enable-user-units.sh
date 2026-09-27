#!/bin/bash

# Omarchy-Nix: a no-op. Upstream enables and starts the user units it ships
# (bt-agent, sleep lock, crash watch, ...). Here Home Manager declares those
# units with their WantedBy targets and starts them on every switch, so there
# is nothing left to enable. Kept so first-run runs the same steps.

exit 0
