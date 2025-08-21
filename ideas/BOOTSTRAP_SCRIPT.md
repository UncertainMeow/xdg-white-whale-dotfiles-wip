# Bootstrap Scripts - Zero to Hero

## The Dream Scenario

```bash
# On a brand new machine:
curl -fsSL https://dotfiles.yourdomain.com/bootstrap | bash

# 30 minutes later:
# ✅ All your apps installed
# ✅ All your configurations applied  
# ✅ All your secrets loaded
# ✅ All your development environments ready
# ✅ SSH keys generated and configured
# ✅ Ready to work
```

## Bootstrap Architecture

```
bootstrap.sh
├── detect_system()        # OS, architecture, package manager
├── install_essentials()   # git, curl, age, etc.
├── setup_dotfiles()      # Clone and install configs
├── install_packages()    # Package manager agnostic
├── setup_secrets()       # Age keys, SOPS, 1Password
├── setup_dev_env()       # Languages, tools, containers
├── apply_settings()      # OS-specific settings
└── verify_setup()        # Health check everything
```

## Implementation

### 1. The Master Bootstrap Script
```bash
#!/usr/bin/env bash
# bootstrap.sh - The magic happens here

set -euo pipefail

# Colors and logging
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}[$(date +'%H:%M:%S')] ✅${NC} $1"; }
warn() { echo -e "${YELLOW}[$(date +'%H:%M:%S')] ⚠️${NC} $1"; }
error() { echo -e "${RED}[$(date +'%H:%M:%S')] ❌${NC} $1"; exit 1; }

# Configuration
DOTFILES_REPO="https://github.com/yourusername/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BOOTSTRAP_CONFIG="$HOME/.bootstrap.conf"

# System detection
detect_system() {
    log "Detecting system information..."
    
    export BOOTSTRAP_OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    export BOOTSTRAP_ARCH=$(uname -m)
    export BOOTSTRAP_DISTRO=""
    
    case "$BOOTSTRAP_OS" in
        "darwin")
            export BOOTSTRAP_PKG_MANAGER="brew"
            ;;
        "linux")
            if command -v apt > /dev/null; then
                export BOOTSTRAP_PKG_MANAGER="apt"
                export BOOTSTRAP_DISTRO="ubuntu"
            elif command -v dnf > /dev/null; then
                export BOOTSTRAP_PKG_MANAGER="dnf"  
                export BOOTSTRAP_DISTRO="fedora"
            elif command -v pacman > /dev/null; then
                export BOOTSTRAP_PKG_MANAGER="pacman"
                export BOOTSTRAP_DISTRO="arch"
            else
                error "Unsupported Linux distribution"
            fi
            ;;
        *)
            error "Unsupported operating system: $BOOTSTRAP_OS"
            ;;
    esac
    
    success "Detected: $BOOTSTRAP_OS/$BOOTSTRAP_ARCH ($BOOTSTRAP_DISTRO) with $BOOTSTRAP_PKG_MANAGER"
}

# Install essential tools
install_essentials() {
    log "Installing essential tools..."
    
    local essentials=("git" "curl" "vim" "zsh")
    
    case "$BOOTSTRAP_PKG_MANAGER" in
        "brew")
            command -v brew > /dev/null || {
                log "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            }
            brew install "${essentials[@]}" age sops
            ;;
        "apt")
            sudo apt update
            sudo apt install -y "${essentials[@]}" 
            install_age_sops_deb
            ;;
        "dnf")
            sudo dnf install -y "${essentials[@]}"
            install_age_sops_rpm
            ;;
        "pacman")
            sudo pacman -Sy --noconfirm "${essentials[@]}" age sops
            ;;
    esac
    
    success "Essential tools installed"
}

# Package manager agnostic installer
install_packages() {
    log "Installing user packages..."
    
    local packages_file="$DOTFILES_DIR/packages/$BOOTSTRAP_OS.txt"
    
    if [[ ! -f "$packages_file" ]]; then
        warn "No package list found for $BOOTSTRAP_OS, skipping"
        return 0
    fi
    
    case "$BOOTSTRAP_PKG_MANAGER" in
        "brew")
            brew bundle --file="$DOTFILES_DIR/packages/Brewfile"
            ;;
        "apt")
            xargs sudo apt install -y < "$packages_file"
            ;;
        "dnf")
            xargs sudo dnf install -y < "$packages_file"
            ;;
        "pacman")
            xargs sudo pacman -S --noconfirm < "$packages_file"
            ;;
    esac
    
    success "Packages installed"
}

# Setup dotfiles repository
setup_dotfiles() {
    log "Setting up dotfiles..."
    
    if [[ -d "$DOTFILES_DIR" ]]; then
        warn "Dotfiles directory exists, pulling latest..."
        cd "$DOTFILES_DIR" && git pull
    else
        log "Cloning dotfiles repository..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    fi
    
    cd "$DOTFILES_DIR"
    
    # Make install script executable
    chmod +x install.sh
    
    # Run dotfiles installer
    ./install.sh
    
    success "Dotfiles configured"
}

# Interactive setup for secrets
setup_secrets() {
    log "Setting up secrets management..."
    
    # Create age directories
    mkdir -p "$HOME/.config/age"
    mkdir -p "$HOME/.config/sops"
    
    # Check if age key exists
    if [[ ! -f "$HOME/.config/age/keys.txt" ]]; then
        log "Generating age key pair..."
        age-keygen -o "$HOME/.config/age/keys.txt"
        
        local public_key=$(age-keygen -y "$HOME/.config/age/keys.txt")
        success "Age key generated. Public key: $public_key"
        
        echo "🔐 IMPORTANT: Save this public key in your dotfiles repo and 1Password!"
        echo "   Public key: $public_key"
        echo "   Press Enter when done..."
        read -r
    fi
    
    # Setup 1Password CLI if on macOS
    if [[ "$BOOTSTRAP_OS" == "darwin" ]]; then
        if ! command -v op > /dev/null; then
            brew install --cask 1password/tap/1password-cli
        fi
        
        log "Please sign in to 1Password CLI:"
        op signin --account your-account.1password.com
    fi
    
    success "Secrets management configured"
}

# Development environment setup
setup_dev_env() {
    log "Setting up development environment..."
    
    # Install programming languages based on detected projects
    local languages=()
    
    # Scan for common project files to determine languages
    if find "$HOME" -name "package.json" -o -name "*.js" -o -name "*.ts" 2>/dev/null | head -1 | read; then
        languages+=("node")
    fi
    
    if find "$HOME" -name "Cargo.toml" -o -name "*.rs" 2>/dev/null | head -1 | read; then
        languages+=("rust")
    fi
    
    if find "$HOME" -name "requirements.txt" -o -name "*.py" 2>/dev/null | head -1 | read; then
        languages+=("python")
    fi
    
    # Install detected languages
    for lang in "${languages[@]}"; do
        case "$lang" in
            "node")
                install_node_env
                ;;
            "rust") 
                install_rust_env
                ;;
            "python")
                install_python_env
                ;;
        esac
    done
    
    # Setup Docker/Podman
    setup_containers
    
    success "Development environment ready"
}

# OS-specific settings  
apply_settings() {
    log "Applying OS-specific settings..."
    
    case "$BOOTSTRAP_OS" in
        "darwin")
            apply_macos_settings
            ;;
        "linux")
            apply_linux_settings
            ;;
    esac
    
    success "Settings applied"
}

apply_macos_settings() {
    # Dock settings
    defaults write com.apple.dock tilesize -int 36
    defaults write com.apple.dock autohide -bool true
    
    # Finder settings  
    defaults write com.apple.finder AppleShowAllFiles -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    
    # Trackpad settings
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    
    killall Dock Finder
}

# Health check
verify_setup() {
    log "Verifying setup..."
    
    local checks=(
        "git --version"
        "zsh --version" 
        "age --version"
        "sops --version"
    )
    
    local failed=0
    
    for check in "${checks[@]}"; do
        if eval "$check" > /dev/null 2>&1; then
            success "$check"
        else
            error "$check"
            ((failed++))
        fi
    done
    
    if [[ $failed -eq 0 ]]; then
        success "All checks passed! 🎉"
        
        cat << EOF
┌─────────────────────────────────────────────┐
│  🎉 Bootstrap Complete!                     │
├─────────────────────────────────────────────┤
│  Next steps:                                │
│  1. Restart your terminal                   │
│  2. Run 'source ~/.config/zsh/zshrc'        │
│  3. Test with 'funcs' command               │
│  4. Start coding! 🚀                       │
└─────────────────────────────────────────────┘
EOF
    else
        error "$failed checks failed. Please review the output above."
    fi
}

# Main execution
main() {
    echo "🚀 Bootstrap Script Starting..."
    echo "This will set up your complete development environment."
    echo "Press Enter to continue or Ctrl+C to abort..."
    read -r
    
    detect_system
    install_essentials  
    setup_dotfiles
    install_packages
    setup_secrets
    setup_dev_env
    apply_settings
    verify_setup
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### 2. Package Lists

```bash
# packages/darwin.txt (macOS Homebrew)
fzf
ripgrep
fd
bat
eza
starship
tmux
neovim
docker

# packages/linux.txt (Ubuntu/Debian)
fzf
ripgrep
fd-find
bat
tmux
neovim-nightly
docker.io
```

### 3. Language-Specific Installers

```bash
install_rust_env() {
    if ! command -v cargo > /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
    
    # Install common tools
    cargo install cargo-watch cargo-edit
}

install_python_env() {
    if ! command -v pyenv > /dev/null; then
        curl https://pyenv.run | bash
    fi
    
    # Install latest Python
    pyenv install 3.11.0
    pyenv global 3.11.0
    
    # Install poetry
    curl -sSL https://install.python-poetry.org | python3 -
}
```

## Advanced Features

### 1. Machine Profiles
```bash
# Different bootstrap profiles
./bootstrap.sh --profile work      # Corporate setup
./bootstrap.sh --profile personal  # Home setup  
./bootstrap.sh --profile server    # Server setup
./bootstrap.sh --profile minimal   # Basic tools only
```

### 2. Incremental Updates
```bash
# Update existing setup
./bootstrap.sh --update-only

# Add new tools without reconfiguring everything
./bootstrap.sh --packages-only
```

### 3. Disaster Recovery
```bash
# Restore from backup codes
./bootstrap.sh --restore-from-codes "recovery-code-1 recovery-code-2"
```

This is how you turn a blank machine into your perfect development environment! 🚀