# 🚀 Environment Launcher Magic

The Jake@Linux inspired instant development environment system.

## 🎯 What This Does

Hit **⌘+Shift+D** and get a beautiful menu to launch:
- 🐍 Python development containers
- 🟢 Node.js environments 
- 🦀 Rust development setup
- 🧪 Clean testing environments
- 🖥️ Virtual machines (UTM integration)
- 🧹 System management tools

## 📦 Installation

### 1. Install Dependencies
```bash
brew install fzf docker yq
```

### 2. Start Docker Desktop
Make sure Docker Desktop is running.

### 3. Set Up Hammerspoon Hotkey
Add this to your `~/.hammerspoon/init.lua`:
```lua
-- Environment Launcher hotkey (⌘+Shift+D)
hs.hotkey.bind({"cmd", "shift"}, "d", function()
    local script = [[
        tell application "Terminal"
            activate
            do script "~/.local/bin/dev-launcher"
        end tell
    ]]
    hs.osascript.applescript(script)
end)
```

### 4. Reload Hammerspoon
Press **⌘+Space**, type "Hammerspoon", press Enter, then **⌘+R** to reload config.

## 🎮 Usage

### Quick Launch
- **⌘+Shift+D** - Open environment launcher
- Use ↑↓ arrows to navigate
- Press Enter to launch selected environment
- Press Esc to cancel

### Manual Launch
```bash
~/.local/bin/dev-launcher
```

## 🛠️ Configuration

Edit `~/.config/dev-environments/containers.yaml` to:
- Add new container environments
- Modify existing setups
- Change volume mounts
- Add environment variables

### Example Container Definition
```yaml
my-custom-env:
  name: "🔥 My Custom Environment"
  image: "ubuntu:22.04"
  volumes:
    - "${PWD}:/workspace"
    - "${HOME}/.ssh:/home/dev/.ssh:ro"
  environment:
    - "CUSTOM_VAR=value"
  command: "bash"
```

## 🎯 Features

### Container Features
- **Automatic volume mounting** - Your current directory becomes `/workspace`
- **Dotfiles integration** - Your configs are available (read-only)
- **Instant cleanup** - Containers auto-remove when you exit
- **Environment variables** - Custom environment per container

### System Features
- **🧹 Cleanup** - Remove unused containers and images
- **📋 Running** - Show currently active containers
- **⚙️ Config** - Edit container definitions
- **🔄 Refresh** - Update all Docker images

### VM Integration (macOS)
- **UTM support** - Launch VMs via URL scheme
- **Automatic detection** - Finds UTM VMs automatically

## 🎨 Customization

### Change Hotkey
Edit the Hammerspoon config to use different key combinations:
```lua
hs.hotkey.bind({"cmd", "alt"}, "e", function() -- ⌘+⌥+E instead
```

### Use iTerm2 Instead
Replace Terminal with iTerm2 in the AppleScript:
```lua
tell application "iTerm"
    activate
    create window with default profile
    tell current session of current window
        write text "~/.local/bin/dev-launcher"
    end tell
end tell
```

### Custom Container Templates
Create Dockerfiles in `~/.config/dev-environments/templates/` for custom images.

## 🔥 Pro Tips

1. **Current Directory Magic** - Run the launcher from any project directory, and that becomes your workspace
2. **Multi-Terminal** - Launch multiple environments simultaneously
3. **Persistence** - Use `docker commit` to save environment states
4. **Project Integration** - Add `.devcontainer` support for project-specific environments

## 🐋 The Vision

This is just the beginning. Future enhancements:
- 🔐 SOPS/age integration for encrypted secrets
- 📦 Nix Home Manager declarative environments  
- 🤖 Bootstrap scripts for instant machine setup
- 🌐 Multi-machine environment synchronization

*Welcome to the future of development environments!* 🚀