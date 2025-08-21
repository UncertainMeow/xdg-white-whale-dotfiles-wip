#!/usr/bin/env zsh

# macOS-specific configuration

# Package management aliases (Homebrew)
alias pkg-update='brew update && brew upgrade'
alias pkg-install='brew install'
alias pkg-search='brew search'
alias pkg-info='brew info'
alias cask-install='brew install --cask'
alias cask-search='brew search --casks'

# Clipboard aliases
alias pbcopy='pbcopy'
alias pbpaste='pbpaste'
alias copy='pbcopy'
alias paste='pbpaste'

# macOS-specific aliases
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
alias spotlight-stop='sudo mdutil -a -i off'
alias spotlight-start='sudo mdutil -a -i on'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'

# Quick access to system preferences
alias sysprefs='open -b com.apple.systempreferences'

# Application shortcuts
alias chrome='open -a "Google Chrome"'
alias firefox='open -a "Firefox"'
alias safari='open -a "Safari"'
alias vscode='open -a "Visual Studio Code"'

# File operations
alias trash='rmtrash'  # Use rmtrash if installed, safer than rm
alias emptytrash='sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl'

# Network information (macOS specific)
alias localip='ipconfig getifaddr en0'
alias wifi-info='system_profiler SPAirPortDataType'
alias wifi-scan='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s'

# System monitoring
alias cpu-usage='top -l 1 -s 0 | grep "CPU usage"'
alias memory-usage='vm_stat'

# Development tools
if command -v code > /dev/null 2>&1; then
    alias c='code'
    alias code.='code .'
fi

# Xcode shortcuts
alias xcode='open -a Xcode'
alias simulator='open -a Simulator'

# Docker Desktop for Mac
alias docker-desktop='open -a Docker'

# === macOS-specific functions ===

# Open current directory in Finder
finder() {
    open -a Finder "${1:-.}"
}

# Quick look at files
ql() {
    qlmanage -p "$@" &> /dev/null
}

# Screen capture shortcuts
screenshot() {
    local filename="screenshot_$(date +%Y%m%d_%H%M%S).png"
    screencapture -i "$filename"
    echo "Screenshot saved: $filename"
}

# Get app info
appinfo() {
    if [[ -z "$1" ]]; then
        echo "Usage: appinfo <app_name>"
        return 1
    fi
    
    local app_path="/Applications/$1.app"
    if [[ -d "$app_path" ]]; then
        mdls "$app_path"
    else
        echo "App not found: $1"
        mdfind "kMDItemKind == 'Application'" | grep -i "$1"
    fi
}

# macOS version info
macos-version() {
    sw_vers
    echo
    system_profiler SPSoftwareDataType | grep "System Version"
}

# Clean up system caches
cleanup-caches() {
    echo "Cleaning system caches..."
    sudo rm -rf /System/Library/Caches/*
    sudo rm -rf /Library/Caches/*
    rm -rf ~/Library/Caches/*
    echo "Cache cleanup complete"
}

# Toggle hidden files in Finder
toggle-hidden() {
    local current=$(defaults read com.apple.finder AppleShowAllFiles)
    if [[ "$current" == "TRUE" ]]; then
        defaults write com.apple.finder AppleShowAllFiles FALSE
        echo "Hidden files are now hidden"
    else
        defaults write com.apple.finder AppleShowAllFiles TRUE
        echo "Hidden files are now visible"
    fi
    killall Finder
}

# macOS-specific PATH additions
# Homebrew paths
if [[ -d "/opt/homebrew/bin" ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
    export PATH="/opt/homebrew/sbin:$PATH"
elif [[ -d "/usr/local/bin" ]]; then
    export PATH="/usr/local/bin:$PATH"
    export PATH="/usr/local/sbin:$PATH"
fi

# macOS development tools
if [[ -d "/Applications/Xcode.app/Contents/Developer/usr/bin" ]]; then
    export PATH="/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH"
fi

# Python3 from Homebrew (if installed)
if [[ -d "/opt/homebrew/opt/python@3.11/bin" ]]; then
    export PATH="/opt/homebrew/opt/python@3.11/bin:$PATH"
fi

# Add Visual Studio Code CLI tool if installed
if [[ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]]; then
    export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
fi

# macOS-specific environment variables
export BROWSER='open'

# Homebrew environment
if command -v brew > /dev/null 2>&1; then
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_AUTO_UPDATE=1
    
    # Add Homebrew completions
    if [[ -d "$(brew --prefix)/share/zsh-completions" ]]; then
        fpath=("$(brew --prefix)/share/zsh-completions" $fpath)
    fi
fi

# Java (if installed via Homebrew)
if [[ -d "/opt/homebrew/opt/openjdk" ]]; then
    export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
    export JAVA_HOME="/opt/homebrew/opt/openjdk"
fi

# iTerm2 integration (if available)
if [[ -f "${HOME}/.iterm2_shell_integration.zsh" ]]; then
    source "${HOME}/.iterm2_shell_integration.zsh"
fi