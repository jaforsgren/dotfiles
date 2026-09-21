ALIASES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# Search loaded aliases by name/definition. Kept separate from the `alias`
# builtin itself: ble.sh calls `alias` on a hot path (syntax highlighting),
# and overriding it as a function there caused a severe interactive slowdown.
als() {
  if [ $# -eq 0 ]; then
    builtin alias
  else
    builtin alias | grep -i -- "$@"
  fi
}

# Copy last command + its output to clipboard (macOS)
cprev() {
  cmd=$(fc -ln -1)
  printf '%s\n%s\n' "$cmd" "$(eval "$cmd" 2>&1)" | pbcopy
}

alias yp='pwd | pbcopy'

# Misc setup stuff
# ---------------------------------------------
alias pipenv='python3.6 -m pipenv'
alias update='source ~/.bashrc'
alias bashrc="cd-notes &&  nvim ./setup/.bashrc ./setup/.bash_aliases"
alias nvimconf="cd ~/.config/nvim && nvim"
alias cd-nvim="cd ~/.config/nvim/"
alias cbashrc="cat ~/.bashrc"
alias reload="source ~/.bashrc && tmux source-file ~/.tmux.conf"
alias thelp="glow $DEVDIR/dotfiles/docs/tmux.md"
alias nhelp="glow $DEVDIR/dotfiles/docs/nvim.md"
alias openwebui="docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main"

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias rm='rm -i'
alias cp='cp'
alias mv='mv'

# # -> Prevents accidentally clobbering files.
alias mkdir='mkdir -p'

alias h='history'
alias j='jobs -l'
alias which='type -a'

alias homebrew="/opt/homebrew"

# AI aliases
# ---------------------------------------------

alias qwen='aider --model ollama_chat/qwen2.5-coder:7b'
alias sonnet='aider --model openai/claude-3.7-sonnet'

# git aliases
# ---------------------------------------------

alias gut='git'
alias got='git'
alias lg=log_git
alias gd="git diff -w -- ':!*json' ':!yarn.lock'"
alias st="git status"
alias diff=difffunc
alias difflog="git diff -G '.*console.log.*'"

alias rebasei="git rebase -i HEAD~"
alias gitconsole="git diff --name-only | xargs -I {} grep -Hn 'console.log' {}"
alias consolelogs="gitconsole"

alias cm="git commit"
alias pull="git pull && lg"
alias brclean="git branch -D $(git branch --merged | grep -v \* | xargs)"
alias rebased="git pull --rebase origin develop"
alias rbd="rebased"
alias rebasem="git pull --rebase origin main"
alias rbm="rebasem"

alias gsl="git stash list"
alias github='open "$(git remote get-url origin 2>/dev/null | sed -E '\''s/git@github.com:(.*)\.git/https:\/\/github.com\/\1/; s/\.git$//'\'' )"'
alias ghb=github

# rebase interactive against all comits in branch (agains develop)
alias rbdi='git rebase -i $(git merge-base HEAD $(git for-each-ref --format="%(upstream:short)" "$(git symbolic-ref -q HEAD)" || echo origin/develop))'

# alias cm='git commit -m'

alias ghpr='gh pr view && gh api repos/$(gh repo view --json owner,name --jq ".owner.login + \"/\" + .name")/pulls/$(gh pr view --json number --jq .number)/comments --paginate --jq ".[] | {path: .path, line: .line, author: .user.login, body: .body}"'
alias pr='git remote get-url origin | \
sed -E "s#git@ssh.dev.azure.com:v3/([^/]+)/([^/]+)/(.+)#https://dev.azure.com/\1/\2/_git/\3/pullrequests?_a=mine#" | \
xargs open'

# cd aliases
# --------------------------------------------
alias cd-dev='cd ~/DEV/'
alias cd-notes='cd $HOME/DEV/weapp-notes'
alias cd-kanban='cd-notes && cd kanban'
alias notes="cd-notes && glow"
alias ..="cd .."
alias cd-p="cd-dev && cd PERSONAL"
alias cd-n="cd-dev && cd personal-notes"
alias cd-dot="cd-dev && cd dotfiles"
alias cd-d=cd-dot

# docker / k8s stuff
# --------------------------------------------

alias dcb="docker compose build"
alias dcu="docker compose up -d"
alias dcd="docker compose down"

alias cd-docker-conf="cd ~/Library/Containers/com.docker.docker/"
alias cd-docekr-conf-user="cd ~/.docker"

alias dc="docker compose"

alias k9sconf="nvim $HOME/Library/Application Support/k9s/config.yml"

alias kubetest="az aks get-credentials --resource-group rg-upplysa-test --name aks-upplysa-test"
alias kubedev="az aks get-credentials --resource-group rg-upplysa-dev --name aks-upplysa-dev"

alias get-ctx="kubectl config get-contexts"
alias contestdocker="kubectl config use-context docker-desktop"
alias contestUpplysa="kubectl config use-context aks-upplysa-dev"
alias contestUpplysatest="kubectl config use-context aks-upplysa-test"
alias upplysa-dev="kubedev && contestUpplysa"
alias upplysa-test="kubetest && contestUpplysatest"

alias resetDocker="sudo pkill -f docker && sudo rm -rf ~/Library/Group\ Containers/group.com.docker && sudo rm -rf ~/Library/Containers/com.docker.* && rm -rf $HOME/.docker && rm -rf Library/Application\ Support/Docker\ Desktop"

# npm
# --------------------------------------------
alias nrd="npm run dev"
alias nrb="npm run build"
alias ni="npm install"
alias nu="npm uninstall"
alias nr="npm run"
alias nrp="npm run prisma:studio"
alias cdk="yarn cdk"

# AWS
# --------------------------------------------

alias cf='aws cloudformation'
alias awsgetDB="aws rds describe-db-instances --query \"DBInstances[*].{DBInstance:DBInstanceIdentifier,Endpoint:Endpoint.Address,Port:Endpoint.Port}\" --output table"
alias getstack="cf describe-stacks --stack-name"

# tmux
# --------------------------------------------

unalias tls 2>/dev/null

tls() {
  local current
  current="$(tmux list-sessions -F '#{session_name}' 2>/dev/null)"

  tmux list-sessions -F '#{session_id}: #{session_name}' 2>/dev/null

  echo "--- restorable (not running) ---"

  local script assignment
  for script in "${ALIASES_DIR}"/tmux-sessions/start-*.sh; do
    [[ -e "$script" ]] || continue
    [[ "$(basename -- "$script")" == "start-all.sh" ]] && continue

    local SESSION=""
    assignment="$(grep -m1 '^SESSION=' "$script")"
    eval "$assignment"

    if [[ -n "$SESSION" ]] && ! grep -qxF "$SESSION" <<<"$current"; then
      echo "$SESSION"
    fi
  done
}

alias tn="tmux new -s"

ta() {
  if [ $# -eq 0 ]; then
    tmux attach
  elif [[ "$1" =~ ^[0-9]+$ ]]; then
    tmux attach -t "\$$1"
  else
    local session="$1"
    local start_script="${ALIASES_DIR}/tmux-sessions/start-${session}.sh"

    if ! tmux has-session -t "=${session}" 2>/dev/null && [ -x "$start_script" ]; then
      "$start_script"
    fi

    tmux attach -t "$session"
  fi
}

# Attach by session ID or name
taid() {
  tmux attach -t "$1"
}

# Switch to a session from inside tmux
ts() {
  tmux switch-client -t "$1"
}

# Kill a session by ID or name
tkill() {
  tmux kill-session -t "$1"
}

alias t-save="${ALIASES_DIR}/save-tmux-sessions.sh"
alias tsave="t-save"
alias t-restore="${ALIASES_DIR}/tmux-sessions/start-all.sh"
alias tres="t-restore"
alias trestore="tres"

# Misc weird stuff
# --------------------------------------------

alias godot='/Applications/Godot_mono.app/Contents/MacOS/Godot'

alias startsshagent='eval "$(ssh-agent -s)"' # start sshagent i bg

alias teamsclear="rm -rf ~/Library/Containers/com.microsoft.teams2 && rm -rf ~/Library/Group Containers/UBF8T346G9.com.microsoft.teams && rm -rf ~/Library/Containers/com.microsoft.teams2.notificationcenter && rm -rf ~/Library/Application\ Support/Microsoft/Teams && rm -rf ~/Library/Application\ Support/Teams"

alias pyclear="find . \( -name '__pycache__' -or -name '*.pyc' \) -delete"

alias codi="code-insiders"

alias cl='claude'
alias oc='opencode'

# OpenCode OCR aliases
# Automatically quote the prompt for 'oc run --auto' and 'oc run --auto --continue'
ocr() {
  oc run --auto "$*"
}

ocrc() {
  oc run --auto --continue "$*"
}

alias occ="ocrc"

# Open a .thmp.md file in nvim, then pipe content to oc prompt --auto on save/exit
ocv() {
  local file="${1:-$(date +%Y%m%d_%H%M%S).thmp.md}"
  nvim "$file"
  cat "$file" | oc prompt --auto
  rm "$file"
}

alias lgtm='/Users/johanforsgren/DEV/PERSONAL/LGTMFaster/lgtmfaster'
alias postoffice='/Users/johanforsgren/DEV/PERSONAL/postOffice/postOffice'
alias po='postoffice'
alias cmdban='/Users/johanforsgren/DEV/PERSONAL/cmdban/cmdban'
alias kanban='cmdban'
alias ban='cmdban'
alias dotnet9="/opt/homebrew/opt/dotnet@9/libexec/dotnet"
alias dtest="dotnet build && dotnet test --no-build"
alias drun="dotnet run --launch-profile http"

alias rider='open -a "Rider" .'
alias rec='/Users/johanforsgren/DEV/dotfiles/scripts/rec.sh'

source $HOME/DEV/dotfiles/.weapp_aliases

echo "Aliases loaded..."
