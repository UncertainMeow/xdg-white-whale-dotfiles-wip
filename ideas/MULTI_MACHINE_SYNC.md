# Multi-Machine Sync Strategy

## The Three-Machine Problem

```
Work Laptop (macOS)
├── Corporate VPN configs
├── Work-specific aliases  
├── Docker Desktop
└── Kubernetes tools

Personal Desktop (Linux)
├── Gaming shortcuts
├── Personal API keys
├── Media tools  
└── Homelab scripts

Remote Server (Ubuntu)
├── Minimal config
├── Server-specific tools
├── Production secrets
└── Network utilities
```

## Solution: Selective Configuration Architecture

### 1. Git Repository Structure
```
dotfiles/
├── common/                    # Shared across all machines
│   ├── zsh/
│   ├── git/
│   └── tmux/
├── machines/
│   ├── work-laptop/          # Machine-specific
│   ├── personal-desktop/
│   └── remote-server/
├── os/
│   ├── macos/               # OS-specific
│   ├── linux/
│   └── windows/
└── roles/
    ├── development/         # Role-specific
    ├── server/
    └── gaming/
```

### 2. Smart Installation Script
```bash
#!/usr/bin/env bash
# install.sh

HOSTNAME=$(hostname)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ROLE=${1:-development}  # default role

echo "Installing dotfiles for:"
echo "  Machine: $HOSTNAME"
echo "  OS: $OS"  
echo "  Role: $ROLE"

# Install common configs (everyone gets these)
stow -t ~ common

# Install OS-specific configs
if [[ -d "os/$OS" ]]; then
    stow -t ~ "os/$OS"
fi

# Install role-specific configs
if [[ -d "roles/$ROLE" ]]; then
    stow -t ~ "roles/$ROLE"
fi

# Install machine-specific configs
if [[ -d "machines/$HOSTNAME" ]]; then
    stow -t ~ "machines/$HOSTNAME"
fi

# Generate dynamic config based on detected environment
generate_dynamic_config
```

### 3. Dynamic Configuration Generation
```bash
generate_dynamic_config() {
    local config_dir="$HOME/.config/zsh"
    mkdir -p "$config_dir"
    
    # Generate machine info
    cat > "$config_dir/machine.zsh" << EOF
# Auto-generated machine configuration
export MACHINE_HOSTNAME="$HOSTNAME"
export MACHINE_OS="$OS"
export MACHINE_ROLE="$ROLE"
export MACHINE_ARCH="$(uname -m)"

# Machine-specific settings
EOF

    # Add machine-specific PATH modifications
    case "$HOSTNAME" in
        "work-laptop")
            echo 'export PATH="/opt/corporate-tools/bin:$PATH"' >> "$config_dir/machine.zsh"
            ;;
        "personal-desktop")
            echo 'export PATH="$HOME/games/bin:$PATH"' >> "$config_dir/machine.zsh"
            ;;
        "remote-server")
            echo 'export PATH="/usr/local/admin/bin:$PATH"' >> "$config_dir/machine.zsh"
            ;;
    esac

    # Add role-specific configurations
    case "$ROLE" in
        "development")
            echo 'alias k="kubectl"' >> "$config_dir/machine.zsh"
            echo 'export DEVELOPMENT_MODE=true' >> "$config_dir/machine.zsh"
            ;;
        "server")
            echo 'alias syslog="sudo journalctl -f"' >> "$config_dir/machine.zsh"
            echo 'export SERVER_MODE=true' >> "$config_dir/machine.zsh"
            ;;
    esac
}
```

### 4. Conditional Loading in ZSH Config
```bash
# In your main zshrc
ZSH_CONFIG_DIR="$XDG_CONFIG_HOME/zsh"

# Load in order of specificity
source_if_exists() {
    [[ -f "$1" ]] && source "$1"
}

# 1. Common (everyone gets this)
source_if_exists "$ZSH_CONFIG_DIR/common.zsh"

# 2. OS-specific
source_if_exists "$ZSH_CONFIG_DIR/os/$(uname -s | tr '[:upper:]' '[:lower:]').zsh"

# 3. Role-specific  
source_if_exists "$ZSH_CONFIG_DIR/roles/${MACHINE_ROLE:-development}.zsh"

# 4. Machine-specific (highest priority)
source_if_exists "$ZSH_CONFIG_DIR/machines/$(hostname).zsh"

# 5. Dynamic (auto-generated)
source_if_exists "$ZSH_CONFIG_DIR/machine.zsh"

# 6. Local overrides (not in git)
source_if_exists "$ZSG_CONFIG_DIR/local.zsh"
```

### 5. Secrets Distribution Strategy

```bash
# Different secrets for different machines
secrets/
├── common.age              # Shared secrets (encrypted)
├── work/
│   ├── corporate-api.age   # Work-only secrets
│   └── vpn-configs.age
├── personal/
│   ├── homelab-keys.age    # Personal-only secrets
│   └── gaming-tokens.age
└── machines/
    ├── work-laptop.age     # Machine-specific
    └── personal-desktop.age
```

### 6. Network-Aware Configurations

```bash
# Detect network and adjust configs
detect_network() {
    local network_name=""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        network_name=$(networksetup -getairportnetwork en0 | cut -d' ' -f4)
    else
        network_name=$(iwgetid -r 2>/dev/null || echo "unknown")
    fi
    
    case "$network_name" in
        "CorpWiFi"|"VPN-Corporate")
            export WORK_NETWORK=true
            source_if_exists "$ZSH_CONFIG_DIR/networks/corporate.zsh"
            ;;
        "HomeWiFi"|"Homelab")
            export HOME_NETWORK=true  
            source_if_exists "$ZSH_CONFIG_DIR/networks/home.zsh"
            ;;
        *)
            export PUBLIC_NETWORK=true
            source_if_exists "$ZSH_CONFIG_DIR/networks/public.zsh"
            ;;
    esac
}
```

## Sync Workflow

### 1. Making Changes
```bash
# Edit common config (affects all machines)
edit-common() {
    cd ~/dotfiles
    $EDITOR common/zsh/aliases.zsh
    git add . && git commit -m "update: common aliases"
    git push
}

# Edit machine-specific config (affects only this machine)  
edit-machine() {
    cd ~/dotfiles
    $EDITOR "machines/$(hostname)/zsh/local.zsh"
    git add . && git commit -m "update: $(hostname) specific config"
    git push
}
```

### 2. Pulling Updates on Other Machines
```bash
# Smart update (pulls and applies only relevant configs)
update-dotfiles() {
    cd ~/dotfiles
    git pull
    
    # Re-run installation for this machine
    ./install.sh
    
    # Reload shell
    exec zsh
}
```

### 3. Conflict Resolution
```bash
# Preview what would change before applying
preview-updates() {
    cd ~/dotfiles
    git fetch
    echo "Changes that would be applied:"
    git diff HEAD..origin/main --stat
    
    # Show machine-specific changes
    git diff HEAD..origin/main "machines/$(hostname)/"
}
```

## Benefits

- **🎯 Selective sync** - Only get configs relevant to each machine
- **🔒 Secure** - Secrets only go where they belong
- **⚡ Smart** - Network and context aware
- **🔄 Atomic** - All or nothing updates
- **📱 Flexible** - Easy to add new machines/roles

This gives you the "dotfiles as infrastructure" experience!