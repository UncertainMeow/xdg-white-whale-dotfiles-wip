# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🐋 The White Whale Vision

This is the **"XDG White Whale Dotfiles"** project - the ultimate personal infrastructure system that pushes the limits of what's possible with dotfiles management. We're not just organizing files; we're building a **complete personal computing environment** that's reproducible, declarative, and magical.

## 🌟 THE ULTIMATE SETUP

**One command** (`curl bootstrap | bash`) that can:
- Set up any new machine from scratch
- Deploy encrypted secrets via SOPS/age + 1Password integration
- Launch instant development environments (containers/VMs via hotkey)
- Configure multi-machine awareness (work vs personal vs server)
- Achieve **zero maintenance** through infrastructure as code

## 🎯 Core Philosophy

This isn't just dotfiles management - it's **personal infrastructure as code**:
- **Declarative configuration** using Home Manager + custom dotfiles
- **Environment orchestration** with VM/container magic
- **Security-first** encrypted secrets management
- **Multi-machine awareness** with context-aware configurations
- **Zero top-level dotfiles** via XDG Base Directory Specification

## Key Scripts and Commands

### Core Migration Scripts
- `./audit_home.sh` - Analyzes current home directory structure against XDG best practices, generates compliance score
- `./reddit_method_migrate.sh` - Implements the "zero top-level files" approach, migrating dotfiles to XDG locations
- `./reddit_method_migrate.sh --dry-run` - Preview migration changes without applying them

### Environment Launcher System
- `./environment-launcher/install.sh` - Installs the dev-launcher system and dependencies
- `dev-launcher` - Interactive container/VM launcher with fzf interface (requires fzf, yq)
- Configuration in `environment-launcher/containers.yaml` - Defines available development environments
- Includes homelab-focused containers: Homelab Command Center, Traefik, AI playground, network troubleshooting

### Homelab Integration
- `homelab-integration/README.md` - Complete guide for Docker/Podman, Tailscale, and GitLab setup
- Integration patterns for reverse proxy, monitoring, and CI/CD
- Scripts and configurations for self-hosted GitLab deployment

### Secrets Management Scripts
- `./snippets/step-01-install-tools.sh` - Installs SOPS and age tools for secrets management
- `./snippets/step-02-generate-keys.sh` - Generates age keys for encryption
- `./snippets/secrets-health-check.sh` - Validates secrets management setup

### Testing and Validation
- Run audit script first to understand current state: `./audit_home.sh`
- Always test migrations in dry-run mode before applying: `./reddit_method_migrate.sh --dry-run`
- No formal test suite - validation is done through the audit script

## Architecture Overview

### XDG Directory Structure
The project enforces XDG Base Directory Specification:
- `~/.config/` - Configuration files (replaces scattered dotfiles)
- `~/.local/share/` - Application data files
- `~/.local/state/` - State files (logs, history, recently used)
- `~/.local/bin/` - User-specific executables  
- `~/.cache/` - Temporary/cache data (safe to delete)

### Modular Shell Configuration
Located in `new_dotfiles/config/zsh/`:
- `zshrc` - Main configuration that sources modular components using array-based loading
- Core modules: `environment`, `history`, `completion`, `aliases`, `functions`, `prompt`
- `os/macos.zsh` - OS-specific configurations (also supports `linux.zsh`, `windows.zsh`)
- Machine-specific configs in `machines/$(hostname).zsh` (not version controlled)
- Local overrides in `local.zsh` (not version controlled)
- Secrets loaded from `$XDG_CONFIG_HOME/secrets/$(hostname).env`
- Follows XDG compliance with proper environment variable setup and directory creation

### Environment Launcher Architecture
Located in `environment-launcher/`:
- `dev-launcher` - Main script with fzf-based container selection interface
- `containers.yaml` - Declarative container definitions with volume mounts and environment variables
- `install.sh` - Setup script that copies files to XDG-compliant locations
- `hammerspoon-setup.lua` - macOS automation integration (Hammerspoon hotkeys)
- Supports multiple container runtimes and pre-configured development environments

### Migration Strategy  
The project implements the "Reddit Method" for achieving zero top-level dotfiles:
1. Creates proper XDG directory structure (`audit_home.sh` provides compliance scoring)
2. Moves dotfiles to appropriate XDG locations with backup creation
3. Creates symlinks for backward compatibility where needed
4. Categorizes files into config/data/cache appropriately with detailed mappings

## File Categories and Migrations

### Configuration Files → `~/.config/`
- `.gitconfig` → `git/config`
- `.zshrc` → `zsh/zshrc`
- `.vimrc` → `vim/vimrc`
- `.tmux.conf` → `tmux/tmux.conf`

### Data Files → `~/.local/share/`
- `.zsh_history` → `zsh/history`
- `.bash_history` → `bash/history`

### Cache Files → `~/.cache/`
- `.zcompdump` → `zsh/compdump`

### Special Cases
- `.ssh/` and `.gnupg/` remain in home directory (security requirements)
- Most other dot-directories get migrated with compatibility symlinks

## Development Workflow

1. **Analysis Phase**: Always run `./audit_home.sh` to understand current state
2. **Planning Phase**: Use dry-run mode to preview changes
3. **Migration Phase**: Apply changes with full migration script
4. **Validation Phase**: Re-run audit script to verify compliance

## Dependencies and Requirements

### Core Dependencies
- **bash** - All migration and setup scripts are bash-based
- **fzf** - Required for dev-launcher interactive menus  
- **yq** - Required for parsing YAML container configurations
- **Docker/Podman** - Required for environment launcher containers

### Platform Support
- **macOS** - Primary development platform, fully supported
- **Linux** - Supported with OS-specific configurations in `new_dotfiles/config/zsh/os/linux.zsh`
- **Windows** - Partial support via WSL/Cygwin

### Installation Commands
All scripts must be executed from project root directory. Key installation sequences:
1. `./audit_home.sh` → `./reddit_method_migrate.sh --dry-run` → `./reddit_method_migrate.sh`
2. `./environment-launcher/install.sh` (requires fzf and yq to be installed first)
3. `./snippets/step-01-install-tools.sh` → `./snippets/step-02-generate-keys.sh`

## Important Constraints

- Never run migration scripts without understanding the current home directory state
- Always create backups before migration (script does this automatically)
- Test in dry-run mode first for any new migration logic
- Respect security-sensitive directories (.ssh, .gnupg) that must remain in home
- Maintain backward compatibility through symlinks where possible
- All scripts assume execution from project root directory

## 🚀 Advanced Features Pipeline

### 🔐 SOPS/age Integration
Break through secrets management intimidation:
- Encrypted secrets in git repository
- 1Password CLI integration for seamless access
- Per-machine and per-context secret deployment

### 🏗️ Environment Launcher Magic  
VM/container orchestration via hotkey:
- Instant development environments
- Language-specific containers
- Project-specific VMs
- One-key environment switching

### 📦 Nix Home Manager Integration
Declarative package and configuration management:
- Version-locked development tools
- Reproducible environments across machines
- Configuration as immutable infrastructure

### 🤖 Bootstrap Script System
New machine automation:
- Single command machine setup
- Hardware-specific configurations
- Automated secret deployment
- Zero-touch environment restoration

## 🎲 Current Status

### ✅ Completed Components
- **Migration Scripts**: `audit_home.sh` and `reddit_method_migrate.sh` fully functional
- **XDG Shell Configuration**: Modular zsh setup with proper XDG compliance
- **Environment Launcher**: Working container launcher with YAML-based configuration
- **Secrets Management Foundation**: Installation scripts for SOPS/age tools

### 🚧 In Development  
- **Bootstrap Script**: Single-command machine setup (planned)
- **Nix Home Manager Integration**: Declarative package management (researched)
- **Multi-machine Sync**: Context-aware configurations (designed)
- **1Password Integration**: Automated secret deployment (planned)

### 📁 Project Structure
```
├── audit_home.sh & reddit_method_migrate.sh    # Working migration tools
├── new_dotfiles/config/zsh/                    # Working modular shell config
├── environment-launcher/                       # Working container launcher
├── snippets/                                   # Working secrets setup scripts  
├── ideas/                                      # Research and planning documents
└── secrets-management/                         # Future implementation area
```

**Phase:** Foundation complete, ready for advanced features
**Safety:** All work committed to git, user's existing dotfiles safe
**Next Decision:** Which advanced feature to tackle first
**Investment:** 7+ hours of research and planning complete

## 🎯 The White Whale Goal

Create the **most advanced personal computing setup possible**:
- Infrastructure that adapts to you, not the other way around
- Environments that appear instantly and work perfectly
- Secrets that deploy securely and seamlessly
- Configuration that's reproducible across any machine
- Zero maintenance through complete automation

*This is the white whale - the perfect setup that every developer dreams of but few achieve.*