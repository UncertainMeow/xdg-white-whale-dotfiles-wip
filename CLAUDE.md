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
- `zshrc` - Main configuration that sources modular components
- `aliases.zsh`, `environment.zsh`, `functions.zsh` - Modular components
- `os/macos.zsh` - OS-specific configurations
- Follows XDG compliance with proper environment variable setup

### Migration Strategy
The project implements the "Reddit Method" for achieving zero top-level dotfiles:
1. Creates proper XDG directory structure
2. Moves dotfiles to appropriate XDG locations
3. Creates symlinks for backward compatibility
4. Categorizes files into config/data/cache appropriately

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

## Important Constraints

- Never run migration scripts without understanding the current home directory state
- Always create backups before migration (script does this automatically)
- Test in dry-run mode first for any new migration logic
- Respect security-sensitive directories (.ssh, .gnupg) that must remain in home
- Maintain backward compatibility through symlinks where possible

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