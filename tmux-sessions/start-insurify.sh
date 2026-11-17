#!/usr/bin/env bash

set -euo pipefail

SESSION=insurify

if tmux has-session -t "=${SESSION}" 2>/dev/null; then
    echo "Skipping existing session: ${SESSION}"
    exit 0
fi

tmux new-session -d -s "$SESSION" -n bash -c /Users/johanforsgren/DEV/lfant/big-tusks-services/Insurify
tmux split-window -t "=${SESSION}:1" -c /Users/johanforsgren/DEV/lfant/big-tusks-services/Insurify
tmux split-window -t "=${SESSION}:1" -c /Users/johanforsgren/DEV/lfant/big-tusks-services/Insurify
tmux split-window -t "=${SESSION}:1" -c /Users/johanforsgren/DEV/lfant/big-tusks-services/Insurify
tmux select-layout -t "=${SESSION}:1" 9640\,188x55\,0\,0\{95x55\,0\,0\[95x28\,0\,0\,32\,95x26\,0\,29\,33\]\,92x55\,96\,0\[92x29\,96\,0\,34\,92x25\,96\,30\,35\]\}

tmux select-window -t "=${SESSION}:1"

echo "Restored session: ${SESSION}"
echo "Attach with: tmux attach-session -t \"=${SESSION}\""
