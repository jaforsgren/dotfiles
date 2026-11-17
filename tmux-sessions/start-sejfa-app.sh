#!/usr/bin/env bash

set -euo pipefail

SESSION=sejfa-app

if tmux has-session -t "=${SESSION}" 2>/dev/null; then
    echo "Skipping existing session: ${SESSION}"
    exit 0
fi

tmux new-session -d -s "$SESSION" -n bash -c /Users/johanforsgren/DEV/sejfa_ts/sejfa-smartphone
tmux select-layout -t "=${SESSION}:1" e375\,188x55\,0\,0\,26

tmux select-window -t "=${SESSION}:1"

echo "Restored session: ${SESSION}"
echo "Attach with: tmux attach-session -t \"=${SESSION}\""
