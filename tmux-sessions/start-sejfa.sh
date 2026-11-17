#!/usr/bin/env bash

set -euo pipefail

SESSION=sejfa

if tmux has-session -t "=${SESSION}" 2>/dev/null; then
    echo "Skipping existing session: ${SESSION}"
    exit 0
fi

tmux new-session -d -s "$SESSION" -n bash -c /Users/johanforsgren/DEV/lfant/sejfa/Sejfa.Internal
tmux split-window -t "=${SESSION}:1" -c /Users/johanforsgren/DEV/lfant/sejfa/Sejfa.Internal
tmux split-window -t "=${SESSION}:1" -c /Users/johanforsgren/DEV/lfant/common/develophub.common
tmux select-layout -t "=${SESSION}:1" 436c\,188x55\,0\,0\{94x55\,0\,0\,7\,93x55\,95\,0\[93x27\,95\,0\,1\,93x27\,95\,28\,9\]\}

tmux new-window -t "=${SESSION}" -n make -c /Users/johanforsgren/DEV/lfant/sejfa/Sejfa.Internal
tmux split-window -t "=${SESSION}:2" -c /Users/johanforsgren/DEV/lfant/sejfa/Sejfa.Internal
tmux select-layout -t "=${SESSION}:2" ab77\,188x55\,0\,0\{94x55\,0\,0\,36\,93x55\,95\,0\,38\}

tmux select-window -t "=${SESSION}:1"

echo "Restored session: ${SESSION}"
echo "Attach with: tmux attach-session -t \"=${SESSION}\""
