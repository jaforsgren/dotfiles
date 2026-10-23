#!/usr/bin/env bash
# Shell overmind runs each Procfile process with (--shell). overmind writes the process command
# to a temp script and passes its path as $1.

# shellcheck source=lfant.sh
source "$(dirname "${BASH_SOURCE[0]}")/lfant.sh"
overmind_lfant_load_aliases

# Each process runs in overmind's tmux, so the MSBuild terminal logger thinks it has an interactive
# terminal and streams a redrawing progress spinner (cursor moves + "(1.9s)") that floods the log.
export MSBUILDTERMINALLOGGER=off

# shellcheck disable=SC1090 # path comes from overmind at runtime
source "$1"
