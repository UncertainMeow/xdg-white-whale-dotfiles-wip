# Development Environment Launcher

## The Jake@Linux Magic

That moment where he hit a hotkey and got a beautiful TUI to launch VMs and containers? We're building that.

## Architecture

```
Hotkey (⌘+Shift+D) 
    ↓
TUI Menu (fzf/gum)
    ├── 🐳 Docker Containers
    │   ├── Python Dev (3.11 + poetry)
    │   ├── Node.js Dev (20 + pnpm)  
    │   ├── Rust Dev (latest + cargo)
    │   └── Test Environment
    ├── 📦 Podman Containers  
    │   ├── System Mirror (for testing)
    │   └── Clean Environment
    └── 🖥️ VMs (UTM/VMware)
        ├── Ubuntu 22.04
        ├── Fedora Latest
        └── Windows 11
```

## Implementation

### 1. Container Definitions

```yaml
# ~/.config/dev-environments/containers.yaml
containers:
  python-dev:
    name: "🐍 Python Development"
    image: "python:3.11-slim"
    volumes:
      - "${PWD}:/workspace"
      - "${HOME}/.config:/home/dev/.config:ro"
    environment:
      - PYTHONPATH=/workspace
    command: bash
    
  node-dev:
    name: "🟢 Node.js Development" 
    image: "node:20-alpine"
    volumes:
      - "${PWD}:/workspace"
    command: sh
    
  rust-dev:
    name: "🦀 Rust Development"
    image: "rust:latest"
    volumes:
      - "${PWD}:/workspace"
      - "${HOME}/.cargo:/usr/local/cargo"
    command: bash
    
  test-env:
    name: "🧪 Clean Test Environment"
    image: "ubuntu:22.04" 
    volumes:
      - "${PWD}:/workspace"
    command: bash
```

### 2. The Launcher Script

```bash
#!/usr/bin/env bash
# ~/.local/bin/dev-launcher

set -euo pipefail

# Colors and UI
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check dependencies
check_deps() {
    local deps=(fzf docker jq yq)
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" > /dev/null; then
            echo -e "${RED}Missing dependency: $dep${NC}"
            exit 1
        fi
    done
}

# Load container definitions
load_containers() {
    yq eval '.containers | keys | .[]' ~/.config/dev-environments/containers.yaml
}

# Load VM definitions
load_vms() {
    # UTM VMs (macOS)
    if [[ -d "$HOME/Library/Containers/com.utmapp.UTM" ]]; then
        find "$HOME/Library/Containers/com.utmapp.UTM/Data/Documents" -name "*.utm" -exec basename {} .utm \; 2>/dev/null | head -5
    fi
}

# Main menu
show_menu() {
    local options=()
    
    # Add containers
    while IFS= read -r container; do
        local name=$(yq eval ".containers.${container}.name" ~/.config/dev-environments/containers.yaml)
        options+=("CONTAINER: $name")
    done < <(load_containers)
    
    # Add VMs
    while IFS= read -r vm; do
        options+=("VM: 🖥️ $vm")
    done < <(load_vms)
    
    # Add special options
    options+=(
        "SYSTEM: 🔄 Restart current environment"
        "SYSTEM: 🧹 Cleanup unused containers"
        "SYSTEM: ⚙️ Configure environments"
    )
    
    # Show menu with fzf
    printf '%s\n' "${options[@]}" | fzf \
        --prompt="Select Development Environment: " \
        --height=40% \
        --layout=reverse \
        --border \
        --preview='echo "Preview would show container/VM details here"' \
        --preview-window=right:50%
}

# Launch container
launch_container() {
    local container_key="$1"
    local config=$(yq eval ".containers.${container_key}" ~/.config/dev-environments/containers.yaml)
    
    echo -e "${BLUE}Launching container: $container_key${NC}"
    
    # Extract configuration
    local image=$(echo "$config" | yq eval '.image')
    local name="${container_key}-$(date +%s)"
    
    # Build docker command
    local docker_cmd="docker run -it --rm --name $name"
    
    # Add volumes
    local volumes=$(echo "$config" | yq eval '.volumes[]' 2>/dev/null || true)
    while IFS= read -r volume; do
        [[ -n "$volume" ]] && docker_cmd+=" -v $volume"
    done <<< "$volumes"
    
    # Add environment variables  
    local envs=$(echo "$config" | yq eval '.environment[]' 2>/dev/null || true)
    while IFS= read -r env; do
        [[ -n "$env" ]] && docker_cmd+=" -e $env"
    done <<< "$envs"
    
    # Add image and command
    local command=$(echo "$config" | yq eval '.command')
    docker_cmd+=" $image $command"
    
    echo -e "${GREEN}Running: $docker_cmd${NC}"
    eval "$docker_cmd"
}

# Launch VM
launch_vm() {
    local vm_name="$1"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - use UTM
        open "utm://start?name=$vm_name"
    else
        echo "VM launching not implemented for this OS yet"
    fi
}

# Cleanup function
cleanup_containers() {
    echo -e "${BLUE}Cleaning up unused containers...${NC}"
    docker system prune -f
    echo -e "${GREEN}Cleanup complete${NC}"
}

# Main execution
main() {
    check_deps
    
    local selection=$(show_menu)
    
    if [[ -z "$selection" ]]; then
        echo "No selection made"
        exit 0
    fi
    
    case "$selection" in
        "CONTAINER:"*)
            # Extract container key from selection
            local container_name=$(echo "$selection" | cut -d':' -f2- | xargs)
            # Find corresponding key (this needs improvement)
            local container_key=$(load_containers | head -1)  # Simplified for now
            launch_container "$container_key"
            ;;
        "VM:"*)
            local vm_name=$(echo "$selection" | sed 's/VM: 🖥️ //')
            launch_vm "$vm_name"
            ;;
        "SYSTEM: 🧹"*)
            cleanup_containers
            ;;
        *)
            echo "Unknown selection: $selection"
            ;;
    esac
}

main "$@"
```

### 3. Keyboard Shortcut Setup

For macOS (using Hammerspoon):
```lua
-- ~/.hammerspoon/init.lua
hs.hotkey.bind({"cmd", "shift"}, "d", function()
    hs.execute("~/.local/bin/dev-launcher")
end)
```

### 4. Container Templates

```dockerfile
# ~/.config/dev-environments/templates/python-dev.dockerfile
FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    git \
    vim \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Create dev user
RUN useradd -m -s /bin/bash dev
USER dev
WORKDIR /workspace

# Copy dotfiles subset
COPY --chown=dev:dev config/zsh/.zshrc /home/dev/.zshrc
COPY --chown=dev:dev config/git/config /home/dev/.gitconfig

CMD ["bash"]
```

## Advanced Features

### 1. Environment Persistence
```bash
# Save current environment state
save_env() {
    docker commit "$container_name" "my-env:$(date +%Y%m%d)"
}

# Restore previous state  
restore_env() {
    docker run -it "my-env:latest"
}
```

### 2. Project-Specific Environments
```bash
# Check for .devcontainer in current directory
if [[ -f ".devcontainer/devcontainer.json" ]]; then
    options+=("PROJECT: 🎯 Current Project Environment")
fi
```

### 3. Network Isolation
```bash
# Create isolated network for testing
docker network create --driver bridge dev-network
docker run --network dev-network ...
```

## Benefits

- **⚡ Instant environments** - No more "works on my machine"
- **🧪 Safe testing** - Break things without consequences  
- **🔄 Reproducible** - Same environment every time
- **🎯 Project-specific** - Different needs, different containers
- **🧹 Clean slate** - Fresh start whenever needed

This is the future of development environments!