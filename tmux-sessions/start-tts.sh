#!/usr/bin/env bash

set -euo pipefail

SESSION=tts

if tmux has-session -t "=${SESSION}" 2>/dev/null; then
    echo "Skipping existing session: ${SESSION}"
    exit 0
fi

tmux new-session -d -s "$SESSION" -n bash -c /Users/johanforsgren/DEV/PERSONAL/sins/tenthousandstars
tmux split-window -t "=${SESSION}:1" -c /Users/johanforsgren/DEV/PERSONAL/sins/tenthousandstars
tmux select-layout -t "=${SESSION}:1" e8b8\,188x55\,0\,0\{79x55\,0\,0\,27\,108x55\,80\,0\,30\}

tmux new-window -t "=${SESSION}" -n cmdban -c /Users/johanforsgren/DEV/PERSONAL/sins/tenthousandstars
tmux select-layout -t "=${SESSION}:2" 6371\,188x55\,0\,0\,31

tmux select-window -t "=${SESSION}:1"

echo "Restored session: ${SESSION}"
echo "Attach with: tmux attach-session -t \"=${SESSION}\""
