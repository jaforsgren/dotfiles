#!/usr/bin/env bash
# Prints the project directory of a Procfile process: replays its Procfile line with make/dotnet
# stubbed out, so the cd-* aliases and the make target's --project resolve without starting anything.
# Runs as its own non-interactive process (like procshell.sh) so the caller's interactive shell
# state (ble.sh, functions, cwd) can't change the result.

set -uo pipefail

# Exported cd/pwd wrappers or CDPATH make cd print extra output, which would corrupt the result.
unset CDPATH
unset -f cd pwd

PROCESS="$1"
OVERMIND_DIR="$(CDPATH= builtin cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && builtin pwd)"
PROCFILE="${OVERMIND_DIR}/Procfile.lfant"

# shellcheck source=lfant.sh
source "${OVERMIND_DIR}/lfant.sh"
overmind_lfant_load_aliases

make() {
  local project
  project="$(command make -n "$@" 2>/dev/null | sed -nE 's/.*--project ([^ ]+).*/\1/p' | head -1)"
  echo "${PWD}/${project}"
}

dotnet() {
  pwd
}

procfile_command="$(sed -n "s/^${PROCESS}: //p" "$PROCFILE")"
[[ -n "$procfile_command" ]] || { echo "process-dir: unknown process '${PROCESS}'" >&2; exit 1; }

eval "$procfile_command" 2>/dev/null
