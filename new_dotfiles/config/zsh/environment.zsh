#!/usr/bin/env zsh

# Environment Variables and XDG Configuration

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# User documents directory (for coding projects)
export XDG_DOCUMENTS_DIR="$HOME/Documents"

# PATH Management
# Add user binaries directory first (highest priority)
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# Language-specific binary directories
[[ -d "$HOME/.local/share/cargo/bin" ]] && export PATH="$HOME/.local/share/cargo/bin:$PATH"  # Rust
[[ -d "$HOME/.local/share/go/bin" ]] && export PATH="$HOME/.local/share/go/bin:$PATH"      # Go
[[ -d "$HOME/.local/share/npm/bin" ]] && export PATH="$HOME/.local/share/npm/bin:$PATH"    # Node.js

# Application Configuration
export EDITOR="nvim"
export VISUAL="$EDITOR"
export PAGER="less"
export BROWSER="firefox"

# XDG-compliant application configurations
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export HISTFILE="$XDG_STATE_HOME/zsh/history"

# Language-specific XDG compliance
export CARGO_HOME="$XDG_DATA_HOME/cargo"           # Rust
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"         # Rust
export GOPATH="$XDG_DATA_HOME/go"                  # Go
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"  # Node.js
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"             # Node.js
export PYTHON_EGG_CACHE="$XDG_CACHE_HOME/python-eggs"     # Python
export PYLINTHOME="$XDG_CACHE_HOME/pylint"                # Python

# Docker XDG compliance
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"

# AWS CLI XDG compliance
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"

# Kubectl XDG compliance
export KUBECONFIG="$XDG_CONFIG_HOME/kube/config"

# GPG XDG compliance (if using modern GPG)
export GNUPGHOME="$XDG_DATA_HOME/gnupg"

# Development Environment
export DEVELOPMENT_DIR="$XDG_DOCUMENTS_DIR/coding-projects"

# Locale settings
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Security: don't log certain commands to history
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help:history:clear"

# Make applications respect XDG directories
# Create necessary directories
mkdir -p "$XDG_STATE_HOME/less" \
         "$XDG_STATE_HOME/zsh" \
         "$XDG_CACHE_HOME/zsh" \
         "$XDG_CONFIG_HOME/npm" \
         "$XDG_CONFIG_HOME/docker" \
         "$XDG_CONFIG_HOME/aws" \
         "$XDG_CONFIG_HOME/kube" \
         "$XDG_DATA_HOME/cargo" \
         "$XDG_DATA_HOME/rustup" \
         "$XDG_DATA_HOME/go" \
         "$XDG_DATA_HOME/gnupg" \
         "$DEVELOPMENT_DIR" 2>/dev/null

# Set appropriate permissions for security-sensitive directories
[[ -d "$XDG_DATA_HOME/gnupg" ]] && chmod 700 "$XDG_DATA_HOME/gnupg"
[[ -d "$XDG_CONFIG_HOME/aws" ]] && chmod 700 "$XDG_CONFIG_HOME/aws"