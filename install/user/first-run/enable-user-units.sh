#!/bin/bash

# Omarchy-Nix: upstream also enables and starts the user units it ships
# (bt-agent, sleep lock, crash watch, ...). Here Home Manager declares those
# units with their WantedBy targets and starts them on every switch, so that
# part is left out.

set -euo pipefail

omarchy-input-method configure --defaults || echo "Input method defaults deferred; run omarchy setup input after login." >&2
