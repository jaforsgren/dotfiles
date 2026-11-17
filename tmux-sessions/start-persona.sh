#!/usr/bin/env bash

set -euo pipefail

SESSION=persona

if tmux has-session -t "=${SESSION}" 2>/dev/null; then
    echo "Skipping existing session: ${SESSION}"
    exit 0
fi

tmux new-session -d -s "$SESSION" -n PERSONA -c /Users/johanforsgren/DEV/lfant/big-tusks-services/persona
tmux split-window -t "=${SESSION}:1" -c /Users/johanforsgren/DEV/lfant/big-tusks-services/persona
tmux split-window -t "=${SESSION}:1" -c /Users/johanforsgren/DEV/lfant/big-tusks-services/persona
tmux select-layout -t "=${SESSION}:1" 6a44\,188x55\,0\,0\{94x55\,0\,0\,16\,93x55\,95\,0\[93x41\,95\,0\,17\,93x13\,95\,42\,19\]\}

tmux new-window -t "=${SESSION}" -n RUN\ PERSONA -c /Users/johanforsgren/DEV/lfant/big-tusks-services/persona
tmux split-window -t "=${SESSION}:2" -c /Users/johanforsgren/DEV/lfant/big-tusks-services/persona
tmux split-window -t "=${SESSION}:2" -c /Users/johanforsgren/DEV/lfant/big-tusks-services/persona
tmux select-layout -t "=${SESSION}:2" f3f0\,188x55\,0\,0\{94x55\,0\,0\,20\,93x55\,95\,0\[93x27\,95\,0\,22\,93x27\,95\,28\,23\]\}

tmux select-window -t "=${SESSION}:1"

echo "Restored session: ${SESSION}"
echo "Attach with: tmux attach-session -t \"=${SESSION}\""
