#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
OUTPUT_DIR="${SCRIPT_DIR}/tmux-sessions"

mkdir -p "$OUTPUT_DIR"

sanitize_filename() {
    printf '%s' "$1" | tr -c 'a-zA-Z0-9._-' '_'
}

generate_session_script() {
    local session="$1"
    local safe_session
    local outfile
    local first_window=true
    local initial_window_index=""

    safe_session="$(sanitize_filename "$session")"
    outfile="$OUTPUT_DIR/start-${safe_session}.sh"

    {
        echo '#!/usr/bin/env bash'
        echo
        echo 'set -euo pipefail'
        echo
        printf 'SESSION=%q\n' "$session"
        echo
        echo 'if tmux has-session -t "=${SESSION}" 2>/dev/null; then'
        echo '    echo "Skipping existing session: ${SESSION}"'
        echo '    exit 0'
        echo 'fi'
        echo

        while IFS=$'\t' read -r window_index window_name window_layout; do
            local first_pane=true

            if [[ -z "$initial_window_index" ]]; then
                initial_window_index="$window_index"
            fi

            while IFS=$'\t' read -r pane_index pane_path; do
                if [[ "$first_window" == true && "$first_pane" == true ]]; then
                    printf \
                        'tmux new-session -d -s "$SESSION" -n %q -c %q\n' \
                        "$window_name" \
                        "$pane_path"

                    first_window=false
                    first_pane=false

                elif [[ "$first_pane" == true ]]; then
                    printf \
                        'tmux new-window -t "=${SESSION}" -n %q -c %q\n' \
                        "$window_name" \
                        "$pane_path"

                    first_pane=false

                else
                    printf \
                        'tmux split-window -t "=${SESSION}:%s" -c %q\n' \
                        "$window_index" \
                        "$pane_path"
                fi
            done < <(
                tmux list-panes \
                    -t "=${session}:${window_index}" \
                    -F '#{pane_index}	#{pane_current_path}' |
                    sort -n
            )

            printf \
                'tmux select-layout -t "=${SESSION}:%s" %q\n' \
                "$window_index" \
                "$window_layout"

            echo
        done < <(
            tmux list-windows \
                -t "=${session}" \
                -F '#{window_index}	#{window_name}	#{window_layout}' |
                sort -n
        )

        if [[ -n "$initial_window_index" ]]; then
            printf \
                'tmux select-window -t "=${SESSION}:%s"\n' \
                "$initial_window_index"
        fi

        echo
        echo 'echo "Restored session: ${SESSION}"'
        echo 'echo "Attach with: tmux attach-session -t \"=${SESSION}\""'
    } > "$outfile"

    chmod +x "$outfile"

    echo "Created: $outfile"
}

while IFS= read -r session; do
    generate_session_script "$session"
done < <(
    tmux list-sessions -F '#{session_name}'
)

cat > "$OUTPUT_DIR/start-all.sh" <<'EOF'
#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

found=false

for script in "$SCRIPT_DIR"/start-*.sh; do
    [[ -e "$script" ]] || continue
    [[ "$(basename -- "$script")" == "start-all.sh" ]] && continue

    found=true
    "$script"
done

if [[ "$found" == false ]]; then
    echo "No session restore scripts found in: $SCRIPT_DIR"
fi
EOF

chmod +x "$OUTPUT_DIR/start-all.sh"

echo
echo "Session scripts written to:"
echo "  $OUTPUT_DIR"
echo
echo "Restore all missing sessions with:"
echo "  $OUTPUT_DIR/start-all.sh"