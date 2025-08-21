# Installation Guide

## 🚀 Quick Start

1. **Audit your current setup:**
   ```bash
   ./audit_home.sh
   ```

2. **Test the migration (safe):**
   ```bash
   ./reddit_method_migrate.sh --dry-run
   ```

3. **Apply the migration:**
   ```bash
   ./reddit_method_migrate.sh
   ```

4. **Install the new dotfiles:**
   ```bash
   ./install_new_dotfiles.sh
   ```

## 📋 What Gets Changed

### Before (Current Chaos)
```
~/
├── .zshrc
├── .gitconfig
├── .tmux.conf
├── .p10k.zsh
├── code/
├── repos/
├── Documents/
└── [many other scattered dotfiles]
```

### After (XDG Bliss)
```
~/
├── .config/
│   ├── zsh/zshrc
│   ├── git/config
│   └── tmux/tmux.conf
├── .local/
│   ├── bin/
│   ├── share/
│   └── state/
├── Documents/
│   └── coding-projects/
│       ├── python/
│       ├── javascript/
│       └── rust/
└── [ZERO top-level dotfiles!]
```

## ⚙️ Manual Steps

If you want to do this manually:

### 1. Set up XDG environment
Add to your shell config:
```bash
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export PATH="$HOME/.local/bin:$PATH"
```

### 2. Copy the new configuration
```bash
cp -r new_dotfiles/config/* ~/.config/
```

### 3. Update your shell
```bash
echo 'source ~/.config/zsh/zshrc' >> ~/.zshrc
```

### 4. Restart your shell
```bash
exec zsh
```

## 🔧 Customization

### Add Machine-Specific Config
```bash
# Create machine-specific config
$EDITOR ~/.config/zsh/machines/$(hostname).zsh

# Add your customizations:
alias myproject='cd ~/Documents/coding-projects/my-special-project'
export API_KEY='your-secret-key'
```

### Add Secrets
```bash
# Create secrets file (not in git)
$EDITOR ~/.config/secrets/$(hostname).env

# Add sensitive environment variables:
export DATABASE_URL='postgresql://...'
export API_TOKEN='secret-token'
```

## 🎯 Verification

After installation, verify everything works:

```bash
# Check XDG variables are set
echo $XDG_CONFIG_HOME

# Test custom functions
funcs

# Test project navigation
proj

# Check PATH includes user binaries  
echo $PATH | grep -o "$HOME/.local/bin"
```

## 🔄 Backup Strategy

Only backup these directories:
- `~/.config/` - All your configurations
- `~/.local/` - User data and binaries  
- `~/Documents/coding-projects/` - Your code

Ignore:
- `~/.cache/` - Regeneratable cache
- All other hidden directories

## 🚨 Rollback

If something breaks:
```bash
# The migration script creates a backup
ls ~/dotfiles_migration_backup_*

# Restore from backup
./rollback.sh ~/dotfiles_migration_backup_20240821_123456
```

## 🎨 Advanced Features

### Lego Block Functions
All functions in `functions.zsh` are modular. Want to add your own?

```bash
$EDITOR ~/.config/zsh/functions.zsh

# Add your function:
myfunction() {
    echo "This is my custom function"
}
```

### OS-Specific Customization
```bash
# Edit macOS-specific config
$EDITOR ~/.config/zsh/os/macos.zsh

# Add macOS-only aliases:
alias mac-specific='echo "This only runs on macOS"'
```

### Project Templates
```bash
# Create new Python project
newproj python my-awesome-app

# Create new Rust project  
newproj rust blazing-fast-tool

# Create new JavaScript project
newproj javascript cool-web-app
```

## 🤝 Integration with Existing Tools

### Git
Your `.gitconfig` moves to `~/.config/git/config` automatically.

### SSH
SSH config stays in `~/.ssh/` (it's special).

### VS Code
Add to your VS Code settings:
```json
{
    "terminal.integrated.env.osx": {
        "XDG_CONFIG_HOME": "$HOME/.config"
    }
}
```

## 📊 Benefits You'll Notice

1. **Clean home directory** - No more dotfile chaos
2. **Easy backups** - Just backup `.config` and `.local`  
3. **Machine sync** - Same config across all machines
4. **Modular config** - Easy to maintain and customize
5. **Project organization** - All code organized by language
6. **Fast navigation** - Quick project switching
7. **XDG compliance** - Modern Linux best practices

Welcome to the future of dotfiles! 🚀