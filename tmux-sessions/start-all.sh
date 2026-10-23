#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

found=false

for script in "$SCRIPT_DIR"/start-*.sh; do
    [[ -e "$script" ]] || continue
    [[ "$(basename -- "$script")" == "start-all.sh" ]] && continue
    # overmind runs the same apps as bigtuskgrpc/bigtuskworkers; starting both would clash on ports.
    [[ "$(basename -- "$script")" == "start-overmind.sh" ]] && continue

    found=true
    "$script"
done

if [[ "$found" == false ]]; then
    echo "No session restore scripts found in: $SCRIPT_DIR"
fi
