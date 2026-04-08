# LLM prompts
# ---------------------------------------------
alias llm-analyse=analyseRepository
alias llm-review=reviewGitDiff
alias llm-issues=createRepositoryIssues
alias llm-tests=listMissingRepositoryTest

# Misc setup stuff
# ---------------------------------------------
alias pipenv='python3.6 -m pipenv'
alias update='source ~/.bashrc'
alias bashrc="cd-notes &&  nvim ./setup/.bashrc ./setup/.bash_aliases"
alias nvimconf="cd ~/.config/nvim && nvim"
alias cd-nvim="cd ~/.config/nvim/"
alias cbashrc="cat ~/.bashrc"
alias reload="source ~/.bashrc"
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
alias gd="git diff -- ':!*json' ':!yarn.lock'"
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

# rebase interactive against all comits in branch (agains develop)
alias rbdi='git rebase -i $(git merge-base HEAD $(git for-each-ref --format="%(upstream:short)" "$(git symbolic-ref -q HEAD)" || echo origin/develop))'

# alias cm='git commit -m'

alias pr='gh pr view && gh api repos/$(gh repo view --json owner,name --jq ".owner.login + \"/\" + .name")/pulls/$(gh pr view --json number --jq .number)/comments --paginate --jq ".[] | {path: .path, line: .line, author: .user.login, body: .body}"'

# cd aliases
# --------------------------------------------
alias cd-dev='cd ~/DEV/'
alias cd-notes='cd $HOME/DEV/notes'
alias notes="cd-notes && glow"
alias ..="cd .."

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

# Misc weird stuff
# --------------------------------------------
alias startsshagent="eval '$(ssh-agent -s)'" # start sshagent i bg

alias teamsclear="rm -rf ~/Library/Containers/com.microsoft.teams2 && rm -rf ~/Library/Group Containers/UBF8T346G9.com.microsoft.teams && rm -rf ~/Library/Containers/com.microsoft.teams2.notificationcenter && rm -rf ~/Library/Application\ Support/Microsoft/Teams && rm -rf ~/Library/Application\ Support/Teams"

alias pyclear="find . \( -name '__pycache__' -or -name '*.pyc' \) -delete"


alias codi="code-insiders"

alias cl='claude'

alias lgtm='/Users/johanforsgren/DEV/PERSONAL/LGTMFaster/lgtmfaster'
alias postoffice='/Users/johanforsgren/DEV/PERSONAL/postOffice/postOffice'
alias cmdban='/Users/johanforsgren/DEV/PERSONAL/cmdban/cmdban'
alias kanban='cmdban'
alias ban='cmdban'
alias dotnet9="/opt/homebrew/opt/dotnet@9/libexec/dotnet"

source $HOME/DEV/dotfiles/.weapp_aliases

echo "Aliases loaded..."
