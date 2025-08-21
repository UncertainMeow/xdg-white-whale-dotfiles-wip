#!/usr/bin/env zsh

# Custom Functions - The "Lego Block" Approach

# === Directory Operations ===

# Make directory and cd into it
mkcd() {
    if [[ -z "$1" ]]; then
        echo "Usage: mkcd <directory>"
        return 1
    fi
    mkdir -p "$1" && cd "$1"
}

# Go up N directories
up() {
    local levels=${1:-1}
    local path=""
    for ((i=1; i<=levels; i++)); do
        path="../$path"
    done
    cd "$path"
}

# Find and cd to directory
cdf() {
    if [[ -z "$1" ]]; then
        echo "Usage: cdf <directory_pattern>"
        return 1
    fi
    
    local dir
    if command -v fd > /dev/null 2>&1; then
        dir=$(fd -t d "$1" | head -1)
    else
        dir=$(find . -type d -name "*$1*" | head -1)
    fi
    
    if [[ -n "$dir" ]]; then
        cd "$dir"
        echo "Changed to: $(pwd)"
    else
        echo "Directory matching '$1' not found"
        return 1
    fi
}

# === Project Management ===

# Quick project switcher
proj() {
    if [[ -z "$1" ]]; then
        echo "Available projects:"
        ls -1 "$DEVELOPMENT_DIR" 2>/dev/null | head -10
        return 0
    fi
    
    local project_path="$DEVELOPMENT_DIR/$1"
    if [[ -d "$project_path" ]]; then
        cd "$project_path"
        echo "Switched to project: $1"
        
        # Source project-specific environment if it exists
        [[ -f ".env" ]] && echo "Loading .env..." && source ".env"
        [[ -f ".envrc" ]] && echo "Loading .envrc..." && source ".envrc"
        
        # Show git status if it's a git repo
        if git rev-parse --git-dir > /dev/null 2>&1; then
            echo "\nGit status:"
            git status --short
        fi
        
        # Show recent commits
        if git rev-parse --git-dir > /dev/null 2>&1; then
            echo "\nRecent commits:"
            git log --oneline -5
        fi
    else
        echo "Project '$1' not found in $DEVELOPMENT_DIR"
        return 1
    fi
}

# Create new project with standard structure
newproj() {
    if [[ -z "$1" ]] || [[ -z "$2" ]]; then
        echo "Usage: newproj <language> <project_name>"
        echo "Languages: python, javascript, rust, go, misc"
        return 1
    fi
    
    local lang="$1"
    local name="$2"
    local project_dir="$DEVELOPMENT_DIR/$lang/$name"
    
    if [[ -d "$project_dir" ]]; then
        echo "Project already exists: $project_dir"
        return 1
    fi
    
    mkdir -p "$project_dir"
    cd "$project_dir"
    
    # Initialize git repo
    git init
    
    # Create language-specific structure
    case "$lang" in
        python)
            touch requirements.txt README.md .gitignore
            mkdir -p src tests
            echo "# $name\n\n" > README.md
            curl -s https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore > .gitignore
            ;;
        javascript)
            npm init -y
            touch README.md .gitignore
            mkdir -p src
            echo "node_modules/\n*.log\n.env" > .gitignore
            ;;
        rust)
            cargo init --name "$name"
            ;;
        go)
            go mod init "$name"
            touch main.go README.md
            mkdir -p cmd internal pkg
            ;;
        *)
            touch README.md .gitignore
            ;;
    esac
    
    echo "Created $lang project: $name"
    echo "Location: $project_dir"
}

# === Git Functions ===

# Git commit with timestamp
gct() {
    local message="${1:-Update: $(date '+%Y-%m-%d %H:%M')}"
    git add . && git commit -m "$message"
}

# Quick git status for all repos in current directory
gstatus() {
    for dir in */; do
        if [[ -d "$dir/.git" ]]; then
            echo "=== $dir ==="
            (cd "$dir" && git status --short)
            echo
        fi
    done
}

# Git log with custom format
glogf() {
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
}

# === File Operations ===

# Extract any archive
extract() {
    if [[ -z "$1" ]]; then
        echo "Usage: extract <file>"
        return 1
    fi
    
    if [[ ! -f "$1" ]]; then
        echo "File not found: $1"
        return 1
    fi
    
    case "$1" in
        *.tar.bz2)   tar xvjf "$1"   ;;
        *.tar.gz)    tar xvzf "$1"   ;;
        *.tar.xz)    tar xvJf "$1"   ;;
        *.bz2)       bunzip2 "$1"    ;;
        *.rar)       unrar x "$1"    ;;
        *.gz)        gunzip "$1"     ;;
        *.tar)       tar xvf "$1"    ;;
        *.tbz2)      tar xvjf "$1"   ;;
        *.tgz)       tar xvzf "$1"   ;;
        *.zip)       unzip "$1"      ;;
        *.Z)         uncompress "$1" ;;
        *.7z)        7z x "$1"       ;;
        *.xz)        unxz "$1"       ;;
        *.exe)       cabextract "$1" ;;
        *)           echo "Unknown archive format: $1" ;;
    esac
}

# Quick backup of file or directory
backup() {
    if [[ -z "$1" ]]; then
        echo "Usage: backup <file_or_directory>"
        return 1
    fi
    
    local item="$1"
    local backup_name="${item%.*/}.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [[ -f "$item" ]]; then
        cp "$item" "$backup_name"
    elif [[ -d "$item" ]]; then
        cp -r "$item" "$backup_name"
    else
        echo "File or directory not found: $item"
        return 1
    fi
    
    echo "Backup created: $backup_name"
}

# === System Information ===

# System summary
sysinfo() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "OS: $(uname -sr)"
    echo "Uptime: $(uptime | cut -d',' -f1 | cut -d' ' -f4-)"
    echo "Shell: $SHELL"
    echo "User: $USER"
    echo "Date: $(date)"
    echo
    echo "=== Disk Usage ==="
    df -h | head -5
    echo
    echo "=== Memory Usage ==="
    free -h 2>/dev/null || vm_stat | head -5
    echo
    echo "=== Load Average ==="
    uptime
}

# Show largest files in directory
largest() {
    local count=${1:-10}
    du -ah . | sort -rh | head -n "$count"
}

# === Network Functions ===

# Port checker
port() {
    if [[ -z "$1" ]]; then
        echo "Usage: port <port_number>"
        return 1
    fi
    
    local port="$1"
    if command -v lsof > /dev/null 2>&1; then
        lsof -i ":$port"
    elif command -v netstat > /dev/null 2>&1; then
        netstat -tuln | grep ":$port"
    else
        echo "Neither lsof nor netstat available"
        return 1
    fi
}

# Quick HTTP server
serve() {
    local port=${1:-8000}
    echo "Serving on http://localhost:$port"
    python3 -m http.server "$port"
}

# === Text Processing ===

# Convert tabs to spaces
tabs2spaces() {
    if [[ -z "$1" ]]; then
        echo "Usage: tabs2spaces <file>"
        return 1
    fi
    expand -t 4 "$1" > "${1}.spaces" && mv "${1}.spaces" "$1"
    echo "Converted tabs to spaces in $1"
}

# Count lines of code (excluding empty lines and comments)
loc() {
    local dir=${1:-.}
    find "$dir" -type f \( -name "*.py" -o -name "*.js" -o -name "*.rs" -o -name "*.go" \) \
        -exec grep -v -E '^\s*$|^\s*#|^\s*//' {} \; | wc -l
}

# === Docker Functions ===

# Docker cleanup
dcleanup() {
    echo "Cleaning up Docker..."
    docker system prune -af
    docker volume prune -f
    echo "Docker cleanup complete"
}

# Docker shell into container
dsh() {
    if [[ -z "$1" ]]; then
        echo "Usage: dsh <container_name_or_id>"
        return 1
    fi
    
    local container="$1"
    if docker exec -it "$container" /bin/bash 2>/dev/null; then
        return 0
    elif docker exec -it "$container" /bin/sh 2>/dev/null; then
        return 0
    else
        echo "Failed to get shell in container: $container"
        return 1
    fi
}

# === Utility Functions ===

# Weather for specific city
weather() {
    local city=${1:-"$(curl -s ipinfo.io/city 2>/dev/null)"}
    curl -s "wttr.in/$city"
}

# Generate random password
genpass() {
    local length=${1:-16}
    openssl rand -base64 "$length" | head -c "$length"
    echo
}

# QR code for text
qr() {
    if [[ -z "$1" ]]; then
        echo "Usage: qr <text>"
        return 1
    fi
    curl -s "qr-server.com/api/v1/create-qr-code/?size=150x150&data=$1"
}

# Timer function
timer() {
    local duration="$1"
    if [[ -z "$duration" ]]; then
        echo "Usage: timer <duration> (e.g., 5m, 30s, 1h)"
        return 1
    fi
    
    echo "Timer started for $duration"
    sleep "$duration" && echo "⏰ Timer finished!"
}

# === Help Function ===

# Show available custom functions
funcs() {
    echo "Available custom functions:"
    echo
    echo "Directory:"
    echo "  mkcd <dir>     - Make and cd to directory"
    echo "  up [n]         - Go up N directories"
    echo "  cdf <pattern>  - Find and cd to directory"
    echo
    echo "Projects:"
    echo "  proj [name]    - Switch to project or list projects"
    echo "  newproj <lang> <name> - Create new project"
    echo
    echo "Git:"
    echo "  gct [msg]      - Commit with timestamp"
    echo "  gstatus        - Status of all repos in current dir"
    echo "  glogf          - Formatted git log"
    echo
    echo "Files:"
    echo "  extract <file> - Extract any archive"
    echo "  backup <item>  - Backup file or directory"
    echo "  largest [n]    - Show largest files"
    echo
    echo "System:"
    echo "  sysinfo        - System information summary"
    echo "  port <num>     - Check what's using a port"
    echo
    echo "Utils:"
    echo "  weather [city] - Weather forecast"
    echo "  genpass [len]  - Generate random password"
    echo "  timer <time>   - Countdown timer"
}