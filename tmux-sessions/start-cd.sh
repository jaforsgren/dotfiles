#!/usr/bin/env bash

set -euo pipefail

SESSION=cd

if tmux has-session -t "=${SESSION}" 2>/dev/null; then
    echo "Skipping existing session: ${SESSION}"
    exit 0
fi

tmux new-session -d -s "$SESSION" -n CLAIMDOCS -c /Users/johanforsgren/DEV/lfant/big-tusks-services/claim-documentation
tmux split-window -t "=${SESSION}:1" -c /Users/johanforsgren/DEV/lfant/big-tusks-services/claim-documentation
tmux split-window -t "=${SESSION}:1" -c /Users/johanforsgren/.config/nvim
tmux select-layout -t "=${SESSION}:1" fab4\,188x55\,0\,0\{93x55\,0\,0\,8\,94x55\,94\,0\[94x27\,94\,0\,5\,94x27\,94\,28\,6\]\}

tmux new-window -t "=${SESSION}" -n make -c /Users/johanforsgren/DEV/lfant/big-tusks-services/claim-documentation
tmux split-window -t "=${SESSION}:2" -c /Users/johanforsgren/DEV/lfant/big-tusks-services/claim-documentation
tmux select-layout -t "=${SESSION}:2" eb70\,188x55\,0\,0\{94x55\,0\,0\,24\,93x55\,95\,0\,25\}

tmux select-window -t "=${SESSION}:1"

echo "Restored session: ${SESSION}"
echo "Attach with: tmux attach-session -t \"=${SESSION}\""
