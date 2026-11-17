#!/usr/bin/env bash

set -euo pipefail

SESSION=infra

if tmux has-session -t "=${SESSION}" 2>/dev/null; then
    echo "Skipping existing session: ${SESSION}"
    exit 0
fi

tmux new-session -d -s "$SESSION" -n claude.exe -c /Users/johanforsgren/DEV/lfant/big-tusks-services/shared-cloud-resources-infrastructure
tmux split-window -t "=${SESSION}:1" -c /Users/johanforsgren/DEV/lfant/common/apps-of-apps
tmux split-window -t "=${SESSION}:1" -c /Users/johanforsgren/DEV/lfant/sejfa/sejfa-internal-infrastructure
tmux select-layout -t "=${SESSION}:1" 1492\,188x55\,0\,0\{94x55\,0\,0\,13\,93x55\,95\,0\[93x27\,95\,0\,14\,93x27\,95\,28\,15\]\}

tmux new-window -t "=${SESSION}" -n bash -c /Users/johanforsgren/DEV/lfant/big-tusks-services/big-tusks-services-infrastructure
tmux split-window -t "=${SESSION}:2" -c /Users/johanforsgren/DEV/lfant/big-tusks-services/shared-cloud-resources-infrastructure
tmux select-layout -t "=${SESSION}:2" eb79\,188x55\,0\,0\{94x55\,0\,0\,39\,93x55\,95\,0\,40\}

tmux select-window -t "=${SESSION}:1"

echo "Restored session: ${SESSION}"
echo "Attach with: tmux attach-session -t \"=${SESSION}\""
