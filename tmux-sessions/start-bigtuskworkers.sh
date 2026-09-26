#!/usr/bin/env bash

set -euo pipefail

SESSION=bigtuskworkers
RUN_CMD="dotnet run"

# Index 0 is the main pane (created via new-session); 1-4 are the worker
# panes actually checked/started. Index 5 (lfant scratch pane) is deliberate
# and excluded from both PANES and DIRS below.
PANES=(1.0 1.1 1.2 1.3 1.4)
DIRS=(
    /Users/johanforsgren/DEV/lfant/sejfa/Sejfa.Internal/src/04-Presentation/Sejfa.Internal.Presentation.Worker
    /Users/johanforsgren/DEV/lfant/big-tusks-services/whisper/src/04-Presentation/Whisper.Presentation.Worker
    /Users/johanforsgren/DEV/lfant/big-tusks-services/Insurify/src/04-Presentation/Insurify.Presentation.Worker
    /Users/johanforsgren/DEV/lfant/big-tusks-services/claim-documentation/src/04-Presentation/ClaimDocumentation.Presentation.Worker
    /Users/johanforsgren/DEV/lfant/big-tusks-services/persona/src/04-Presentation/Persona.Presentation.Worker
)

run_if_idle() {
    local pane="$1"
    local dir="$2"
    local current

    current="$(tmux display-message -t "$pane" -p '#{pane_current_command}')"

    if [[ "$current" == "dotnet" ]]; then
        local actual_path
        actual_path="$(tmux display-message -t "$pane" -p '#{pane_current_path}')"

        if [[ "$actual_path" != "$dir" ]]; then
            echo "Warning: pane ${pane} is running dotnet in ${actual_path}, expected ${dir}; leaving it alone"
        fi

        return
    fi

    # cd explicitly instead of trusting the pane's current directory, in case
    # someone cd'd around in there since it was created.
    tmux send-keys -t "$pane" "cd '${dir}' && ${RUN_CMD}" C-m
}

if tmux has-session -t "=${SESSION}" 2>/dev/null; then
    # display-message silently falls back to another pane in the window when
    # the target pane doesn't exist, so list-panes is used to check first.
    # A missing pane means the layout is broken in a way we can't safely
    # patch in place (which project belongs in that slot, at what size), so
    # rebuild the whole session from scratch instead.
    missing_pane=0
    for pane in "${PANES[@]}"; do
        if ! tmux list-panes -t "=${SESSION}:${pane}" &>/dev/null; then
            missing_pane=1
            break
        fi
    done

    if [[ "$missing_pane" -eq 0 ]]; then
        echo "Session already running: ${SESSION}"

        for i in "${!PANES[@]}"; do
            run_if_idle "=${SESSION}:${PANES[$i]}" "${DIRS[$i]}"
        done

        echo "Checked panes, started any that were idle."
        exit 0
    fi

    echo "Session ${SESSION} is missing a pane, rebuilding it"
    tmux kill-session -t "=${SESSION}"
fi

MAIN_PANE="$(tmux new-session -d -s "$SESSION" -n bash -c "${DIRS[0]}" -P -F '#{pane_id}')"

# Splits always target the shrinking main pane (not the newest pane) so 6
# panes fit on any reasonably sized terminal instead of halving space away.
# The split order below is reversed on purpose: each new pane is inserted
# right after MAIN_PANE, so splitting in this order yields final indices
# 1=whisper, 2=Insurify, 3=claim-documentation, 4=persona, 5=lfant (scratch).
tmux split-window -t "$MAIN_PANE" -p 17 -c /Users/johanforsgren/DEV/lfant
tmux split-window -t "$MAIN_PANE" -p 20 -c "${DIRS[4]}"
tmux split-window -t "$MAIN_PANE" -p 25 -c "${DIRS[3]}"
tmux split-window -t "$MAIN_PANE" -p 33 -c "${DIRS[2]}"
tmux split-window -t "$MAIN_PANE" -p 50 -c "${DIRS[1]}"
tmux select-layout -t "=${SESSION}:1" 6be1\,188x55\,0\,0\[188x17\,0\,0\{101x17\,0\,0\,10\,86x17\,102\,0\,12\}\,188x18\,0\,18\{101x18\,0\,18\,13\,86x18\,102\,18\,14\}\,188x18\,0\,37\{101x18\,0\,37\,15\,86x18\,102\,37\,11\}\]

for i in "${!PANES[@]}"; do
    run_if_idle "=${SESSION}:${PANES[$i]}" "${DIRS[$i]}"
done

tmux select-window -t "=${SESSION}:1"

echo "Restored session: ${SESSION}"
echo "Attach with: tmux attach-session -t \"=${SESSION}\""
