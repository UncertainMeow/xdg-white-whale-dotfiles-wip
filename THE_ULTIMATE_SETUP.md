# The Ultimate Setup - Personal Infrastructure as Code

## 🚀 The Vision

**From blank machine to perfect development environment in 30 minutes.**

This isn't just dotfiles management - this is **personal infrastructure as code**. Every tool, every configuration, every secret, every development environment - all declared, version controlled, and reproducible.

## 🏗️ The Architecture

```
                    🌍 THE ULTIMATE SETUP 🌍
                           
┌─────────────────────────────────────────────────────────────────┐
│                      Master Bootstrap                           │
│  curl -fsSL dotfiles.your-domain.com/ultimate | bash           │
└─────────────────┬───────────────────────────────────────────────┘
                  │
         ┌────────┼────────┐
         ▼        ▼        ▼
    
🔧 LAYER 1: SYSTEM      🏠 LAYER 2: HOME MANAGER    🎯 LAYER 3: PERSONAL
┌─────────────────┐     ┌─────────────────────┐     ┌──────────────────┐
│ • OS Detection  │     │ • Package Mgmt      │     │ • XDG Dotfiles   │
│ • Base Tools    │     │ • Basic Configs     │     │ • Secrets (SOPS) │
│ • Prerequisites │     │ • Service Mgmt      │     │ • Dev Containers │
│ • Security      │     │ • Cross-Platform    │     │ • Machine Config │
└─────────────────┘     └─────────────────────┘     └──────────────────┘
         │                        │                         │
         └────────────────────────┼─────────────────────────┘
                                  ▼
                    
                    🎉 COMPLETE ENVIRONMENT
              ┌─────────────────────────────────┐
              │ • All apps installed            │
              │ • All configs applied           │  
              │ • All secrets loaded            │
              │ • All dev envs ready            │
              │ • Machine-specific tweaks       │
              │ • Network-aware settings        │
              │ • Project shortcuts configured  │
              └─────────────────────────────────┘
```

## 🔄 The Complete Workflow

### Stage 1: System Bootstrap (5 minutes)
```bash
# The one command to rule them all
curl -fsSL https://your-domain.com/ultimate-bootstrap | bash

# What happens:
1. 🕵️  Detect OS, architecture, network
2. 📦 Install base tools (git, curl, nix, age, sops)
3. 🔐 Set up initial security (age keys, SSH)
4. 📁 Create XDG directory structure
5. 🏠 Install Nix Home Manager
```

### Stage 2: Home Manager Declaration (10 minutes)
```bash
# Clone your infrastructure-as-code repo
git clone git@github.com:youruser/ultimate-dotfiles.git ~/.config/dotfiles

# Apply your declared environment
home-manager switch --flake ~/.config/dotfiles

# What Home Manager handles:
✅ All packages (ripgrep, fd, tmux, docker, kubectl, etc.)
✅ Basic program configs (git, zsh, tmux basics)  
✅ Service management (Docker daemon, etc.)
✅ Cross-platform compatibility
✅ Atomic updates with rollback
```

### Stage 3: Personal Layer (10 minutes)
```bash
# Apply your personal configurations
~/.config/dotfiles/apply-personal-configs.sh

# What happens:
🎯 XDG-compliant dotfiles applied
🔐 Secrets decrypted and loaded  
🐳 Development containers built
⚙️  Machine-specific configurations
🌐 Network-aware settings
📱 Project shortcuts created
```

### Stage 4: Verification & Completion (5 minutes)
```bash
# Comprehensive health check
~/.config/dotfiles/verify-setup.sh

# What's verified:
✅ All packages installed and accessible
✅ All configurations applied correctly
✅ All secrets loaded and working
✅ All development environments functional
✅ Machine-specific tweaks in place
✅ Ready for immediate productivity
```

## 📋 The Repository Structure

```
ultimate-dotfiles/
├── flake.nix                    # Nix Home Manager entry point
├── home.nix                     # Main Home Manager config  
├── bootstrap/
│   ├── ultimate-bootstrap.sh    # The master bootstrap script
│   ├── detect-system.sh         # OS/platform detection
│   ├── install-base-tools.sh    # Essential tools installer
│   └── setup-security.sh        # Initial security setup
├── home-manager/
│   ├── packages/                # Package declarations by category
│   ├── programs/                # Program configurations  
│   ├── services/                # Service management
│   └── platforms/               # Platform-specific configs
├── personal/
│   ├── dotfiles/                # XDG-compliant configurations
│   │   ├── zsh/                 # Your modular shell configs
│   │   ├── git/                 # Git configuration
│   │   ├── tmux/                # Tmux setup
│   │   └── nvim/                # Neovim configuration
│   ├── secrets/                 # SOPS-encrypted secrets
│   │   ├── personal/            # Personal API keys, tokens
│   │   ├── work/                # Work-related secrets
│   │   └── machines/            # Machine-specific secrets
│   ├── dev-environments/        # Container definitions
│   │   ├── python-dev/
│   │   ├── node-dev/
│   │   ├── rust-dev/
│   │   └── containers.yaml      # Environment definitions
│   └── machines/                # Machine-specific configs
│       ├── work-laptop/
│       ├── personal-desktop/
│       └── remote-servers/
├── scripts/
│   ├── apply-personal-configs.sh    # Personal layer installer
│   ├── dev-environment-launcher.sh  # The Jake@Linux magic
│   ├── secrets-manager.sh          # SOPS/age integration
│   ├── project-navigator.sh        # Smart project switching
│   └── verify-setup.sh             # Health checking
└── docs/
    ├── INSTALLATION.md
    ├── MACHINE_SETUP.md
    └── TROUBLESHOOTING.md
```

## 🏠 Home Manager Integration

### flake.nix (The Entry Point)
```nix
{
  description = "Ultimate Personal Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";  # or x86_64-linux, etc.
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."kellen" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
}
```

### home.nix (The Declaration)
```nix
{ config, pkgs, ... }:

let
  # Dynamic system detection
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  
  # Load machine-specific config
  hostname = builtins.readFile /etc/hostname;
  
in {
  # Essential packages (cross-platform)
  home.packages = with pkgs; [
    # Modern CLI tools
    ripgrep fd bat eza fzf
    tmux starship
    
    # Development essentials
    git neovim
    docker docker-compose
    kubectl k9s
    
    # Languages
    nodejs python3 rustc cargo go
    
    # Security tools
    age sops gnupg
    
    # Productivity
    jq yq curl wget
    htop btop
  ] ++ lib.optionals isDarwin [
    # macOS-specific packages
  ] ++ lib.optionals isLinux [
    # Linux-specific packages
  ];

  # Program configurations
  programs = {
    git = {
      enable = true;
      userName = "Kellen";
      userEmail = "your@email.com";
      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
      };
    };

    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      
      # Integration with your personal dotfiles
      initExtra = ''
        # Source personal configurations
        export XDG_CONFIG_HOME="$HOME/.config"
        
        # Load personal modular configs
        for config in "$XDG_CONFIG_HOME/zsh"/{environment,aliases,functions}.zsh; do
          [[ -f "$config" ]] && source "$config"
        done
        
        # Load machine-specific config
        [[ -f "$XDG_CONFIG_HOME/zsh/machines/$(hostname).zsh" ]] && 
          source "$XDG_CONFIG_HOME/zsh/machines/$(hostname).zsh"
        
        # Load secrets
        [[ -f "$XDG_CONFIG_HOME/secrets/$(hostname).env" ]] && 
          sops -d "$XDG_CONFIG_HOME/secrets/$(hostname).env" | source /dev/stdin
      '';
    };

    tmux = {
      enable = true;
      terminal = "screen-256color";
      keyMode = "vi";
      customPaneNavigationAndResize = true;
      
      extraConfig = ''
        # Load personal tmux config
        source-file ~/.config/tmux/tmux.conf
      '';
    };
  };

  # Home Manager state version
  home.stateVersion = "23.11";
}
```

## 🔐 Secrets Integration

### SOPS Configuration (.sops.yaml)
```yaml
keys:
  - &personal_key age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  - &work_laptop age1yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
  - &home_desktop age1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz

creation_rules:
  - path_regex: secrets/personal/.*\.env$
    key_groups:
      - age:
          - *personal_key
          
  - path_regex: secrets/work/.*\.env$
    key_groups:
      - age:
          - *personal_key
          - *work_laptop
          
  - path_regex: secrets/machines/.*\.env$
    key_groups:
      - age:
          - *personal_key
```

### Encrypted Secrets (secrets/personal/api-keys.env)
```bash
# This file is encrypted with SOPS
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
export OPENAI_API_KEY="sk-xxxxxxxxxxxxxxxxxxxx"
export AWS_ACCESS_KEY_ID="AKIAXXXXXXXXXXXXXXXX"
export DATABASE_URL="postgresql://user:pass@host:port/db"
```

## 🐳 Development Environment Launcher

### The Magic Script (scripts/dev-environment-launcher.sh)
```bash
#!/usr/bin/env bash

# The Jake@Linux inspired development environment launcher
# Hotkey: ⌘+Shift+D

set -euo pipefail

# Load container definitions
CONTAINERS_CONFIG="$XDG_CONFIG_HOME/dev-environments/containers.yaml"
PROJECTS_DIR="$HOME/Documents/coding-projects"

# Beautiful TUI menu
show_environment_menu() {
    local options=()
    
    # Development containers
    options+=("🐍 Python Development")
    options+=("🟢 Node.js Development") 
    options+=("🦀 Rust Development")
    options+=("🐹 Go Development")
    options+=("🧪 Clean Test Environment")
    
    # Running containers
    local running=$(docker ps --format "table {{.Names}}\t{{.Image}}" | tail -n +2)
    if [[ -n "$running" ]]; then
        options+=("───── Running Containers ─────")
        while IFS= read -r line; do
            options+=("🔄 $line")
        done <<< "$running"
    fi
    
    # VMs (if available)
    if command -v utm > /dev/null 2>&1; then
        options+=("───── Virtual Machines ─────")
        options+=("🖥️  Ubuntu 22.04 VM")
        options+=("🖥️  Fedora Latest VM")
    fi
    
    # System operations
    options+=("───── System Operations ─────")
    options+=("🧹 Cleanup Unused Containers")
    options+=("⚙️  Configure Environments")
    options+=("📊 System Status")
    
    # Show menu with fzf
    printf '%s\n' "${options[@]}" | fzf \
        --prompt="🚀 Select Development Environment: " \
        --height=60% \
        --layout=reverse \
        --border \
        --preview='echo "This will show container/VM details and recent activity"' \
        --preview-window=right:50%
}

# Container launcher
launch_container() {
    local container_type="$1"
    
    case "$container_type" in
        "python")
            docker run -it --rm \
                -v "$PWD:/workspace" \
                -v "$HOME/.config:/home/dev/.config:ro" \
                -w /workspace \
                --name "python-dev-$(date +%s)" \
                python:3.11-slim bash
            ;;
        "node")
            docker run -it --rm \
                -v "$PWD:/workspace" \
                -v "$HOME/.config:/home/node/.config:ro" \
                -w /workspace \
                --name "node-dev-$(date +%s)" \
                node:20-alpine sh
            ;;
        "rust")
            docker run -it --rm \
                -v "$PWD:/workspace" \
                -v "$HOME/.cargo:/usr/local/cargo" \
                -w /workspace \
                --name "rust-dev-$(date +%s)" \
                rust:latest bash
            ;;
    esac
}

# Main execution
main() {
    local selection=$(show_environment_menu)
    
    case "$selection" in
        "🐍 Python Development")
            launch_container "python"
            ;;
        "🟢 Node.js Development")
            launch_container "node"
            ;;
        "🦀 Rust Development")
            launch_container "rust"
            ;;
        "🧹 Cleanup Unused Containers")
            docker system prune -af
            echo "✅ Cleanup complete"
            ;;
        *)
            echo "Selection: $selection"
            ;;
    esac
}

main "$@"
```

## 🚀 The Master Bootstrap Script

### bootstrap/ultimate-bootstrap.sh
```bash
#!/usr/bin/env bash

# The Ultimate Setup Bootstrap
# One command to create the perfect development environment

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
REPO_URL="git@github.com:youruser/ultimate-dotfiles.git"
CONFIG_DIR="$HOME/.config/dotfiles"

# Fancy banner
show_banner() {
    echo -e "${PURPLE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                    🚀 THE ULTIMATE SETUP 🚀                  ║
║                                                              ║
║  Personal Infrastructure as Code                             ║
║  From zero to hero in 30 minutes                            ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Progress indicator
progress() {
    local step="$1"
    local total="$2" 
    local message="$3"
    
    echo -e "${BLUE}[$step/$total]${NC} $message"
}

# Main orchestration
main() {
    show_banner
    
    echo "This will set up your complete development environment."
    echo "Press Enter to continue or Ctrl+C to abort..."
    read -r
    
    progress 1 4 "🔍 Detecting system and installing base tools..."
    source "$(dirname "$0")/detect-system.sh"
    source "$(dirname "$0")/install-base-tools.sh"
    
    progress 2 4 "🏠 Setting up Nix Home Manager..."
    install_nix_home_manager
    
    progress 3 4 "🎯 Applying personal configurations..."
    clone_dotfiles_repo
    apply_home_manager_config
    apply_personal_layer
    
    progress 4 4 "✅ Verifying setup..."
    verify_installation
    
    show_completion_message
}

# Individual functions...
install_nix_home_manager() {
    if ! command -v nix > /dev/null; then
        curl -L https://install.determinate.systems/nix | sh -s -- install
    fi
    
    nix run home-manager/master -- init --switch
}

apply_home_manager_config() {
    cd "$CONFIG_DIR"
    home-manager switch --flake .
}

apply_personal_layer() {
    "$CONFIG_DIR/scripts/apply-personal-configs.sh"
}

verify_installation() {
    "$CONFIG_DIR/scripts/verify-setup.sh"
}

show_completion_message() {
    echo -e "${GREEN}"
    cat << 'EOF'
🎉 THE ULTIMATE SETUP IS COMPLETE! 🎉

Your environment is now fully configured:
✅ All packages installed via Home Manager  
✅ XDG-compliant dotfiles applied
✅ Secrets decrypted and loaded
✅ Development environments ready
✅ Machine-specific configurations applied

Next steps:
1. Restart your terminal
2. Try: dev-launcher (⌘+Shift+D)
3. Test: funcs
4. Start coding! 🚀

Happy hacking!
EOF
    echo -e "${NC}"
}

main "$@"
```

## 🎯 The Power of Integration

This isn't just dotfiles - it's **personal infrastructure as code**:

1. **Declarative Everything** - Every tool, every config, every secret declared
2. **Cross-Platform** - Same setup on macOS, Linux, anywhere
3. **Machine-Aware** - Different configs for work vs personal vs server
4. **Security-First** - Secrets encrypted, keys managed properly
5. **Developer-Focused** - Instant dev environments, project navigation
6. **Rollback Ready** - Any change can be undone instantly
7. **Network-Aware** - Different configs for different networks
8. **Self-Documenting** - The config IS the documentation

**The ultimate goal:** Clone one repo, run one command, get your perfect environment anywhere.

Ready to build this ultimate system? 🚀