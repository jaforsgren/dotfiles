#!/usr/bin/env bash

set -euo pipefail

SESSION=proj

if tmux has-session -t "=${SESSION}" 2>/dev/null; then
    echo "Skipping existing session: ${SESSION}"
    exit 0
fi

tmux new-session -d -s "$SESSION" -n PROJECT -c /Users/johanforsgren/DEV/lfant/big-tusks-services/whisper/src/04-Presentation/Whisper.Presentation.GrpcServer
tmux split-window -t "=${SESSION}:1" -c /Users/johanforsgren/DEV/lfant/big-tusks-services/whisper/src/04-Presentation/Whisper.Presentation.GrpcServer
tmux select-layout -t "=${SESSION}:1" ab65\,188x55\,0\,0\{94x55\,0\,0\,10\,93x55\,95\,0\,11\}

tmux select-window -t "=${SESSION}:1"

echo "Restored session: ${SESSION}"
echo "Attach with: tmux attach-session -t \"=${SESSION}\""
