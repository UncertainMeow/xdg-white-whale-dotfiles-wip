# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the "XDG White Whale Dotfiles" project - a comprehensive home directory transformation system that implements the XDG Base Directory Specification and modern dotfiles management practices. The goal is to transform cluttered home directories into organized, reproducible, XDG-compliant systems with zero top-level dotfiles.

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

## Project Goals

The "white whale" project aims to:
- Achieve zero top-level dotfiles in home directory
- Implement full XDG Base Directory Specification compliance
- Create reproducible, organized development environments
- Enable clean backup strategies (ignore all hidden files except .config and .local)
- Provide modular, maintainable shell configurations