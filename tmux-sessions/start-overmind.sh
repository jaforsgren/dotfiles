#!/usr/bin/env bash

set -euo pipefail

# Kept literal (not from lfant.sh): the tmux session listing in .bash_aliases greps for it.
SESSION=overmind
SCRIPT_DIR="$(CDPATH= builtin cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && builtin pwd)"
OVERMIND_DIR="$(CDPATH= builtin cd -- "${SCRIPT_DIR}/../overmind" >/dev/null && builtin pwd)"
PROCFILE="${OVERMIND_DIR}/Procfile.lfant"
# shellcheck source=../overmind/lfant.sh
source "${OVERMIND_DIR}/lfant.sh"
APP_ROOT="$OVERMIND_LFANT_APP_ROOT"
SOCKET="$OVERMIND_LFANT_SOCKET"
LOG_FILE="$OVERMIND_LFANT_LOG_FILE"
PROCFILE_SNAPSHOT="$OVERMIND_LFANT_PROCFILE_SNAPSHOT"
APPS_WINDOW=apps
LOGS_WINDOW=logs
ECHO_RETRY_SECONDS=2

# -N: overmind would otherwise inject $PORT, but ports come from each app's appsettings.
# --any-can-die: by default one crashing app makes overmind stop all the others.
# -H: run processes through procshell.sh so Procfile lines can use the cd-* aliases.
# `command` skips interactive rm/cp aliases (e.g. rm -i) in the pane's shell.
OVERMIND_START_CMD="command rm -f '${SOCKET}' && command cp '${PROCFILE}' '${PROCFILE_SNAPSHOT}' && overmind start -N --any-can-die -H '${OVERMIND_DIR}/procshell.sh' -f '${PROCFILE}' -d '${APP_ROOT}' -s '${SOCKET}'"
# overmind echo exits when the master isn't up yet or restarts, so keep reattaching.
ECHO_LOOP_CMD="while true; do overmind echo -s '${SOCKET}' >> '${LOG_FILE}' 2>/dev/null; sleep ${ECHO_RETRY_SECONDS}; done"

window_exists() {
    tmux list-windows -t "=${SESSION}" -F '#{window_name}' | grep -qxF "$1"
}

create_logs_window() {
    tmux new-window -d -t "=${SESSION}" -n "$LOGS_WINDOW" -c "$APP_ROOT"
    tmux send-keys -t "=${SESSION}:${LOGS_WINDOW}" "$ECHO_LOOP_CMD" C-m
    tmux split-window -t "=${SESSION}:${LOGS_WINDOW}" -p 90 -c "$APP_ROOT" "lnav '${LOG_FILE}'"
}

# A pane still running the previous overmind (e.g. stuck shutting down) would swallow the
# start command as input, so the apps window is replaced rather than reused. It is inserted
# before the logs window, which always exists by the time this runs.
start_overmind_in_new_apps_window() {
    if window_exists "$APPS_WINDOW"; then
        tmux kill-window -t "=${SESSION}:${APPS_WINDOW}"
    fi
    tmux new-window -d -b -t "=${SESSION}:${LOGS_WINDOW}" -n "$APPS_WINDOW" -c "$APP_ROOT"
    tmux send-keys -t "=${SESSION}:${APPS_WINDOW}" "$OVERMIND_START_CMD" C-m
    tmux move-window -r -t "=${SESSION}:"
}

restart_dead_processes() {
    local dead
    dead="$(overmind_lfant_dead_processes | tr '\n' ' ')"

    if [[ -z "${dead// /}" ]]; then
        echo "All processes running, nothing to restart"
        return
    fi

    echo "Restarting dead processes: ${dead}"
    # shellcheck disable=SC2086 # word splitting into separate process names is intended
    overmind restart -s "$SOCKET" $dead
}

# Restarting dead processes would silently reuse the commands overmind loaded at start, so a
# changed Procfile needs a full restart instead.
procfile_changed_since_start() {
    if [[ ! -f "$PROCFILE_SNAPSHOT" ]]; then
        echo "No snapshot of the Procfile overmind started with, can't tell if it changed."
        return 0
    fi

    if cmp -s "$PROCFILE" "$PROCFILE_SNAPSHOT"; then
        return 1
    fi

    echo "Procfile changed since overmind started:"
    diff "$PROCFILE_SNAPSHOT" "$PROCFILE" | grep -E '^[<>]' | sed -e 's/^</  running:/' -e 's/^>/  new:    /'
    return 0
}

if ! tmux has-session -t "=${SESSION}" 2>/dev/null; then
    : > "$LOG_FILE"
    tmux new-session -d -s "$SESSION" -n "$APPS_WINDOW" -c "$APP_ROOT"
    tmux send-keys -t "=${SESSION}:${APPS_WINDOW}" "$OVERMIND_START_CMD" C-m
    create_logs_window
    tmux select-window -t "=${SESSION}:${LOGS_WINDOW}"

    echo "Started session: ${SESSION}"
    echo "Attach with: tmux attach-session -t \"=${SESSION}\""
    exit 0
fi

if ! window_exists "$LOGS_WINDOW"; then
    echo "Recreating missing ${LOGS_WINDOW} window"
    create_logs_window
fi

if overmind_lfant_is_running; then
    if procfile_changed_since_start; then
        echo "Not restarting anything. Run 'dev down && dev up' to apply the Procfile."
        exit 1
    fi
    restart_dead_processes
else
    echo "Session ${SESSION} exists but overmind is not running, starting it"
    start_overmind_in_new_apps_window
fi
