# Source aliases
# --------------------------------------------------------------------------
#
export LANG=en_US.UTF-8

set -o vi # VIM keymapping in cmdline

export ME=$(whoami)

export DEVDIR=$HOME/DEV

loadenv() {
  local envfile="${1:-$DEVDIR/dotfiles/.env}"

  if [ ! -f "$envfile" ]; then
    echo "loadenv: no env file at $envfile"
    return 1
  fi

  local exported_vars=()
  local line key value

  while IFS= read -r line || [ -n "$line" ]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    key="${line%%=*}"
    value="${line#*=}"
    key="$(echo "$key" | xargs)"
    [[ -z "$key" ]] && continue

    export "$key=$value"
    exported_vars+=("$key")
  done < "$envfile"

  echo "----- exported env vars  -----"
  printf '%s\n' "${exported_vars[@]}"
  echo "-----------------------------"
}

loadenv

echo "============================="
echo "~/.bashrc loaded!!!"
echo "============================="

if [ -f $DEVDIR/dotfiles/.bash_aliases ]; then
  echo "loading .bash_aliases"
  . $DEVDIR/dotfiles/.bash_aliases
fi
#
# if [ -f $DEVDIR/notes/setup/.rapid_aliases ]; then
#   echo "loading .rapid_aliases"
#   . $DEVDIR/notes/setup/.rapid_aliases
# fi

export NVIM_DIR=~/.config/nvim

# Load ble.sh, but do not attach to the terminal yet
# --------------------------------------------------------------------------
if [[ $- == *i* ]] && [[ -f "$HOME/.local/share/blesh/ble.sh" ]]; then
  source "$HOME/.local/share/blesh/ble.sh" --attach=none
fi

# GIT functions
# --------------------------------------------------------------------------
difffunc() { git diff -G ".*$@.*" -- ':!*json'; }

log_git() {
  local num=1
  if [ "$#" -gt 0 ]; then
    num="$1"
  fi
  git lg -n "$num"
}

# GIT rendering in iterm
parse_git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

gsa() {
  git stash apply "stash@{$1}"
}

gsp() {
  git stash pop "stash@{$1}"
}

_commit() {
  local type="$1"
  local msg

  read -erp "$type: " msg
  [[ -z "$msg" ]] && return

  git commit -m "$type: $msg"
}

cmf() { _commit "Feat"; }
cmfx() { _commit "Fix"; }
cmc() { _commit "Chore"; }
cmd() { _commit "Docs"; }
cmr() { _commit "Refactor"; }
cmt() { _commit "Test"; }

# MISC
# --------------------------------------------------------------------------

export PS1="\u@\h \[\033[32m\]\w\$(parse_git_branch)\[\033[00m\] $ "
export EDITOR=nvim
export VISUAL=nvim

killport() { kill -9 $(lsof -t -i:$1); }

calc() { bc -l <<< "$*"; }

# aws
# --------------------------------------------------------------------------
listrec() {
  aws route53 list-resource-record-sets --hosted-zone-id "/hostedzone/$1" --profile "$2"
}

# --------------------------------------------------------------------------
# Source other scripts
[ -f "$HOME/tt.sh" ] && source "$HOME/tt.sh"

# ----------------------------------------
# Bash history
# ----------------------------------------
HISTFILE="$HOME/.bash_history"
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoreboth:erasedups

shopt -s histappend

PROMPT_COMMAND="history -a; history -n${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# ----------------------------------------
# NVM setup
# ----------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"                                       # Loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" # Loads nvm bash_completion

# ----------------------------------------
# Homebrew and local bins
# ----------------------------------------
# export DOTNET_ROOT=/usr/local/share/dotnet
# export PATH=$DOTNET_ROOT:$PATH
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$PATH"

export DOTNET_ROOT=/usr/local/share/dotnet
export PATH=$DOTNET_ROOT:$PATH

# --------------------------------------------------------------------------

# kimi-code
export PATH="/Users/johanforsgren/.kimi-code/bin:$PATH"

# opencode
export PATH=/Users/johanforsgren/.opencode/bin:$PATH

# attach ble
[[ ${BLE_VERSION-} ]] && ble-attach
