# Source aliases
# --------------------------------------------------------------------------
#

set -o vi # VIM keymapping in cmdline

export ME=$(whoami)

export DEVDIR=$HOME/DEV

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

# MISC
# --------------------------------------------------------------------------

export PS1="\u@\h \[\033[32m\]\w\$(parse_git_branch)\[\033[00m\] $ "
export EDITOR=nvim

killport() { kill -9 $(lsof -t -i:$1); }

# aws
# --------------------------------------------------------------------------
listrec() {
  aws route53 list-resource-record-sets --hosted-zone-id "/hostedzone/$1" --profile "$2"
}

# --------------------------------------------------------------------------
# Source other scripts
source /Users/johanforsgren/tt.sh

# GitHub Copilot alias

# ----------------------------------------
# NVM setup
# ----------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"                                       # Loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" # Loads nvm bash_completion

# Add current Node version to PATH safely
if command -v nvm >/dev/null 2>&1; then
  export PATH="$NVM_DIR/versions/node/$(nvm version)/bin:$PATH"
fi

# ----------------------------------------
# Homebrew and local bins
# ----------------------------------------
# export DOTNET_ROOT=/usr/local/share/dotnet
# export PATH=$DOTNET_ROOT:$PATH
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$PATH"

# --------------------------------------------------------------------------
echo "============================="
echo "~/.bashrc loaded!!!"
echo "============================="
