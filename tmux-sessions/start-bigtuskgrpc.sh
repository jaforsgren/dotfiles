#!/usr/bin/env bash

set -euo pipefail

SESSION=bigtuskgrpc
RUN_CMD="dotnet run --configuration http"

PANES=(1.0 1.1 1.2 1.3)
DIRS=(
    /Users/johanforsgren/DEV/lfant/big-tusks-services/claim-documentation/src/04-Presentation/ClaimDocumentation.Presentation.GrpcServer
    /Users/johanforsgren/DEV/lfant/big-tusks-services/persona/src/04-Presentation/Persona.Presentation.GrpcServer
    /Users/johanforsgren/DEV/lfant/big-tusks-services/iib-proxy/src/04-Presentation/IibProxy.Presentation.GrpcServer
    /Users/johanforsgren/DEV/lfant/big-tusks-services/whisper/src/04-Presentation/Whisper.Presentation.GrpcServer
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

tmux new-session -d -s "$SESSION" -n bash -c "${DIRS[0]}"
tmux split-window -t "=${SESSION}:1" -c "${DIRS[1]}"
tmux split-window -t "=${SESSION}:1" -c "${DIRS[2]}"
tmux split-window -t "=${SESSION}:1" -c "${DIRS[3]}"
tmux select-layout -t "=${SESSION}:1" c495\,188x55\,0\,0\[188x19\,0\,0\{100x19\,0\,0\,0\,87x19\,101\,0\,3\}\,188x35\,0\,20\{100x35\,0\,20\,1\,87x35\,101\,20\,2\}\]

for i in "${!PANES[@]}"; do
    run_if_idle "=${SESSION}:${PANES[$i]}" "${DIRS[$i]}"
done

tmux select-window -t "=${SESSION}:1"

echo "Restored session: ${SESSION}"
echo "Attach with: tmux attach-session -t \"=${SESSION}\""
