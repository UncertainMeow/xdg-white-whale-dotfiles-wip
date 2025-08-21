# Linux Fundamentals: The Knowledge You Need After 2 Years

## 🗂️ Linux File System Hierarchy Standard (FHS)

### System Directories (You Don't Touch These)
- **`/bin`** - Essential system binaries (ls, cat, cp) - used by all users
- **`/usr/bin`** - Non-essential system binaries - most programs live here
- **`/usr/local/bin`** - Locally compiled/installed programs (stuff YOU install)
- **`/sbin`** - System administration binaries (root only)
- **`/etc`** - System-wide configuration files
- **`/var`** - Variable data (logs, databases, mail)
- **`/tmp`** - Temporary files (cleared on reboot)
- **`/home`** - User home directories

### Your Home Directory (`~`)
This is YOUR kingdom. Everything here belongs to you.

## 🛤️ What "On My PATH" Actually Means

**PATH is a list of directories where the shell looks for executables.**

When you type `git`, the shell searches these directories in order:
```bash
echo $PATH
# Typically shows something like:
# /usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/Users/kellen/.local/bin
```

**The Search Order Matters:**
- First match wins
- `/usr/local/bin` usually comes first (your custom installs override system ones)
- `~/.local/bin` is where YOU put personal scripts/binaries

**Adding to PATH:**
```bash
# In your shell config (.zshrc):
export PATH="$HOME/.local/bin:$PATH"
# This puts your personal bin directory FIRST in the search order
```

## ⚙️ XDG Base Directory Specification

**The Problem XDG Solves:**
Before XDG, every app dumped config files wherever it wanted:
```
~/.vimrc
~/.bashrc  
~/.gitconfig
~/.ssh/
~/.mozilla/
~/.aws/
# ... chaos
```

**The XDG Solution:**
```bash
# These environment variables define standard locations:
export XDG_CONFIG_HOME="$HOME/.config"     # App configurations
export XDG_DATA_HOME="$HOME/.local/share"  # App data files
export XDG_STATE_HOME="$HOME/.local/state" # App state (logs, history)
export XDG_CACHE_HOME="$HOME/.cache"       # Temporary/cache data
```

**Real-World XDG Layout:**
```
~/.config/
├── git/config          # Instead of ~/.gitconfig
├── zsh/zshrc          # Instead of ~/.zshrc
├── nvim/init.lua      # Instead of ~/.vimrc
└── tmux/tmux.conf     # Instead of ~/.tmux.conf

~/.local/share/
├── applications/      # Custom .desktop files
├── fonts/            # Personal fonts
└── nvim/site/        # Vim plugins/data

~/.local/state/
├── zsh/history       # Shell history
└── less/history      # Less search history

~/.cache/
├── pip/              # Python package cache
└── npm/              # Node package cache
```

## 🐚 Anatomy of a Shell Configuration (.zshrc)

### Essential Sections Every .zshrc Should Have:

**1. Environment Variables**
```bash
# XDG compliance
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# PATH management
export PATH="$HOME/.local/bin:$PATH"

# App-specific configs
export EDITOR="nvim"
export BROWSER="firefox"
```

**2. Aliases**
```bash
# Safety first
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Convenience
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
```

**3. Functions**
```bash
# Custom functions for complex operations
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Project navigation
proj() {
    cd "$XDG_DOCUMENTS_DIR/coding-projects/$1"
}
```

**4. Shell Options & Features**
```bash
# History settings
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_VERIFY
setopt SHARE_HISTORY

# Auto-completion
autoload -Uz compinit && compinit
```

**5. Plugin/Framework Loading**
```bash
# Oh My Zsh, Prezto, or custom plugin loading
# This usually goes at the end
```

## 🧱 The Modular Approach ("Bread's Method")

Instead of one massive `.zshrc`, create:

```
~/.config/zsh/
├── zshrc              # Main file that sources others
├── environment.zsh    # Environment variables
├── aliases.zsh        # All aliases
├── functions.zsh      # Custom functions
├── history.zsh        # History configuration
├── completion.zsh     # Auto-completion setup
├── plugins.zsh        # Plugin loading
└── local.zsh          # Machine-specific settings
```

**Main `zshrc` becomes:**
```bash
#!/usr/bin/env zsh

# Source all configuration modules
for config in "$XDG_CONFIG_HOME/zsh"/{environment,aliases,functions,history,completion,plugins,local}.zsh; do
    [[ -f "$config" ]] && source "$config"
done
```

**Benefits:**
- Easy to edit specific functionality
- Can version control modules separately  
- Easy to share some modules but keep others private
- Different modules for different operating systems
- Easy to disable problematic modules

## 🎯 Key Takeaways for Your Setup

1. **PATH:** Add `~/.local/bin` to your PATH for personal scripts
2. **XDG:** Move configs to `~/.config/` to clean up your home directory  
3. **Modular configs:** Split large config files into logical modules
4. **Version control:** Track your dotfiles with Git
5. **Symlinks:** When apps can't find moved configs, symlink from old location to new

This foundation will make everything else we build make perfect sense!