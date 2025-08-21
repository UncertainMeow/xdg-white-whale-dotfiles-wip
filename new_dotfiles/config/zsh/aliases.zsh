#!/usr/bin/env zsh

# Modern Aliases - Safety First, Productivity Second

# Safety aliases (prevent accidents)
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

# Better defaults for ls
if command -v eza > /dev/null 2>&1; then
    # Use eza if available (modern ls replacement)
    alias ls='eza'
    alias ll='eza -la --icons --git'
    alias la='eza -a'
    alias lt='eza --tree'
    alias lg='eza -la --icons --git --git-ignore'
else
    # Fallback to traditional ls with colors
    alias ls='ls --color=auto'
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
fi

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'  # Go to previous directory

# Make and change directory in one command
alias mkcd='mkdir -p "$1" && cd "$1"'

# Git aliases (short and sweet)
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias glog='git log --oneline --graph --decorate'
alias gstash='git stash'
alias gpop='git stash pop'

# Development shortcuts
alias dev='cd $DEVELOPMENT_DIR'
alias proj='cd $DEVELOPMENT_DIR'

# Quick project navigation (you can customize these)
alias pyproj='cd $DEVELOPMENT_DIR/python'
alias jsproj='cd $DEVELOPMENT_DIR/javascript'
alias rustproj='cd $DEVELOPMENT_DIR/rust'
alias goproj='cd $DEVELOPMENT_DIR/go'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
alias dprune='docker system prune -af'

# Kubernetes aliases  
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kdesc='kubectl describe'
alias klog='kubectl logs -f'
alias kexec='kubectl exec -it'

# System information
alias ports='netstat -tulanp'
alias psg='ps aux | grep'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime='date +"%d-%m-%Y %T"'

# Network
alias ping='ping -c 5'
alias fastping='ping -c 100 -s 1'
alias ip='curl -s ipinfo.io/ip'  # External IP
alias localip='hostname -I | cut -d" " -f1'  # Local IP

# File operations with progress
alias rsync='rsync --progress'

# Modern tools (if available)
if command -v bat > /dev/null 2>&1; then
    alias cat='bat --paging=never'
    alias less='bat'
fi

if command -v fd > /dev/null 2>&1; then
    alias find='fd'
fi

if command -v rg > /dev/null 2>&1; then
    alias grep='rg'
fi

if command -v htop > /dev/null 2>&1; then
    alias top='htop'
fi

if command -v ncdu > /dev/null 2>&1; then
    alias du='ncdu'
fi

# Package management shortcuts (OS-specific, will be overridden in OS modules)
alias pkg-update='echo "Override this in os-specific config"'
alias pkg-install='echo "Override this in os-specific config"'
alias pkg-search='echo "Override this in os-specific config"'

# Dotfiles management
alias dotfiles='cd $XDG_CONFIG_HOME'
alias reload='source $XDG_CONFIG_HOME/zsh/zshrc'
alias zedit='$EDITOR $XDG_CONFIG_HOME/zsh/zshrc'

# Backup shortcuts
alias backup-dotfiles='rsync -av $HOME/.config/ $HOME/.local/ /path/to/backup/'

# Quick system monitoring
alias meminfo='free -m -l -t'
alias cpuinfo='lscpu'
alias diskinfo='df -h'

# Fun stuff
alias weather='curl -s wttr.in'
alias moon='curl -s wttr.in/Moon'
alias myweather='curl -s wttr.in/$(curl -s ipinfo.io/city)'

# Development server shortcuts (customize as needed)
alias serve='python3 -m http.server'
alias serve8080='python3 -m http.server 8080'

# Text processing
alias urldecode='python3 -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.argv[1]))"'
alias urlencode='python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]))"'

# Clipboard (OS-specific, will be overridden)
alias pbcopy='echo "Override this in os-specific config"'
alias pbpaste='echo "Override this in os-specific config"'

# Quick config editing
alias zshrc='$EDITOR $XDG_CONFIG_HOME/zsh/zshrc'
alias aliases='$EDITOR $XDG_CONFIG_HOME/zsh/aliases.zsh'
alias funcs='$EDITOR $XDG_CONFIG_HOME/zsh/functions.zsh'
alias envs='$EDITOR $XDG_CONFIG_HOME/zsh/environment.zsh'

# XDG-aware applications
alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'