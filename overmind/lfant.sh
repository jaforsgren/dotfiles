# Shared by tmux-sessions/start-overmind.sh and the `dev` helper in .weapp_aliases.
OVERMIND_LFANT_SESSION=overmind
OVERMIND_LFANT_APP_ROOT=/Users/johanforsgren/DEV/lfant
OVERMIND_LFANT_SOCKET=/tmp/overmind-lfant.sock
OVERMIND_LFANT_LOG_FILE=/tmp/overmind-lfant.log
# Copy of the Procfile taken when overmind starts: overmind never re-reads the Procfile, so this
# is what the running instance actually uses.
OVERMIND_LFANT_PROCFILE_SNAPSHOT=/tmp/overmind-lfant.Procfile
# Sourced into interactive shells too, where cd may be wrapped or CDPATH set and print extra output.
OVERMIND_LFANT_DOTFILES_DIR="$(CDPATH= builtin cd -- "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null && builtin pwd)"
# Passed to lnav -I so it loads the overmind_log format (formats/overmind/overmind_log.json).
OVERMIND_LFANT_LNAV_CONFIG_DIR="${OVERMIND_LFANT_DOTFILES_DIR}/overmind/lnav"

# Procfile lines use the cd-* aliases, which non-interactive shells don't have by default.
overmind_lfant_load_aliases() {
  shopt -s expand_aliases
  # .bash_aliases echoes progress lines, which would otherwise land in every process's log.
  source "${OVERMIND_LFANT_DOTFILES_DIR}/.bash_aliases" >/dev/null 2>&1
}

# Asks overmind itself instead of testing for the socket file: a crashed overmind leaves a stale socket behind.
overmind_lfant_is_running() {
  overmind status -s "$OVERMIND_LFANT_SOCKET" >/dev/null 2>&1
}

# Prints "<process> <state>" per line, without the header.
overmind_lfant_statuses() {
  overmind status -s "$OVERMIND_LFANT_SOCKET" 2>/dev/null | awk 'NR > 1 { print $1, $NF }'
}

overmind_lfant_dead_processes() {
  overmind_lfant_statuses | awk '$2 == "dead" { print $1 }'
}
