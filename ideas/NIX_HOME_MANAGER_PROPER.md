# Nix Home Manager - The Real Deal

## What Home Manager Actually Is

**Home Manager is NOT NixOS.** It's a user-space configuration system that:

- Runs on **any OS** (macOS, Ubuntu, Fedora, etc.)
- Manages **your user environment** only (no root required)
- Uses **declarative configuration** (describe what you want, not how to get it)
- Provides **atomic updates** with rollback
- Gives you **reproducible environments** across machines

Think: "Homebrew but better" meets "Infrastructure as Code for your dotfiles"

## Why It's Perfect for Your Journey

### 1. Declarative Everything
Instead of running install commands, you declare what you want:

```nix
{ config, pkgs, ... }: {
  # Package management
  home.packages = with pkgs; [
    # Modern CLI tools (your current favorites)
    ripgrep
    fd
    bat
    eza
    fzf
    tmux
    starship
    
    # Development tools
    git
    neovim
    docker
    kubectl
    
    # Languages
    nodejs
    python3
    rustc
    cargo
  ];

  # Git configuration (replaces .gitconfig)
  programs.git = {
    enable = true;
    userName = "Kellen";
    userEmail = "your@email.com";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
  };

  # Zsh configuration (works WITH your modular approach)
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    
    # Your existing configs still work!
    initExtra = ''
      # Source your existing modular configs
      source ~/.config/zsh/functions.zsh
      source ~/.config/zsh/aliases.zsh
      source ~/.config/zsh/os/macos.zsh
    '';
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    
    extraConfig = ''
      # Your custom tmux config here
      set -g mouse on
      set -g base-index 1
    '';
  };
}
```

### 2. Multi-Machine Magic
```nix
{ config, pkgs, lib, ... }: 

let
  # Machine detection
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  
  # Machine-specific packages
  darwinPackages = with pkgs; [ 
    # macOS-specific tools
  ];
  
  linuxPackages = with pkgs; [ 
    # Linux-specific tools
  ];

in {
  home.packages = with pkgs; [
    # Common packages for all machines
    git ripgrep fd bat
  ] ++ lib.optionals isDarwin darwinPackages
    ++ lib.optionals isLinux linuxPackages;

  # Different configs per OS
  programs.zsh.shellAliases = {
    # Common aliases
    ll = "eza -la";
    g = "git";
  } // lib.optionalAttrs isDarwin {
    # macOS-only aliases  
    pbcopy = "pbcopy";
  } // lib.optionalAttrs isLinux {
    # Linux-only aliases
    pbcopy = "xclip -selection clipboard";
  };
}
```

### 3. Integration with Your Current Setup

**The brilliant part:** Home Manager doesn't replace your modular dotfiles - it **enhances** them!

```nix
# You keep your existing structure:
~/.config/zsh/
├── functions.zsh
├── aliases.zsh  
├── os/macos.zsh
└── machines/hostname.zsh

# Home Manager handles:
- Package installation
- Service management  
- Basic app configs
- Environment variables

# Your configs handle:
- Custom functions
- Machine-specific tweaks
- Secrets management
- Project shortcuts
```

## Installation Process (macOS)

### 1. Install Nix Package Manager
```bash
# Official installer
curl -L https://nixos.org/nix/install | sh

# Or use Determinate Nix Installer (better for macOS)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. Install Home Manager
```bash
# Add the Home Manager channel
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

# Install Home Manager
nix-shell '<home-manager>' -A install
```

### 3. Create Your Configuration
```bash
# Edit your config
$EDITOR ~/.config/nixpkgs/home.nix

# Apply changes
home-manager switch
```

## Best Practices for Your Use Case

### 1. Start Small, Build Up
```nix
# Week 1: Just packages
{ config, pkgs, ... }: {
  home.packages = with pkgs; [ git ripgrep fd ];
}

# Week 2: Add basic configs  
{ config, pkgs, ... }: {
  home.packages = with pkgs; [ git ripgrep fd ];
  programs.git.enable = true;
}

# Week 3: Integration with existing dotfiles
{ config, pkgs, ... }: {
  home.packages = with pkgs; [ git ripgrep fd ];
  programs.git.enable = true;
  programs.zsh = {
    enable = true;
    initExtra = "source ~/.config/zsh/zshrc";
  };
}
```

### 2. Keep Secrets Out of Nix
```nix
# DON'T put secrets in home.nix
programs.git = {
  userName = "Kellen";  # ✅ Fine
  userEmail = "public@example.com";  # ✅ Fine
  # signing.key = "ABC123...";  # ❌ Never!
};

# Instead, source them from your existing secret management
programs.zsh.initExtra = ''
  # Load secrets from SOPS/age/1Password
  source ~/.config/secrets/$(hostname).env
'';
```

### 3. Machine-Specific Configs
```nix
# ~/.config/nixpkgs/machines/work-laptop.nix
{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    kubectl
    docker
    terraform
  ];
  
  programs.zsh.shellAliases = {
    k = "kubectl";
    tf = "terraform";
  };
}

# ~/.config/nixpkgs/home.nix
{ config, pkgs, ... }: 

let
  hostname = builtins.readFile /etc/hostname;
  machineConfig = ./machines + "/${hostname}.nix";
in {
  imports = [ machineConfig ];
  
  # Common config for all machines
  home.packages = with pkgs; [ git ripgrep ];
}
```

## Rollback Superpowers

```bash
# Broke something? Instant rollback
home-manager switch --rollback

# See all generations
home-manager generations

# Switch to specific generation  
/nix/store/xxx-home-manager-generation/activate
```

## Integration Strategy with Your XDG Journey

### Phase 1: Package Management Only
- Use Home Manager just for installing packages
- Keep all your existing XDG configs
- Gradually move simple configs to Home Manager

### Phase 2: Basic Program Configs
- Move git, tmux, zsh basic setup to Home Manager
- Keep advanced configs (functions, aliases) in your files
- Use Home Manager's `extraConfig` to source your files

### Phase 3: Full Integration
- Most configs in Home Manager
- Machine-specific overrides in separate files
- Secrets still managed with your SOPS/age strategy

## Why This Beats Your Current Homebrew Setup

```bash
# Current way:
brew install ripgrep fd bat eza  # Hope they're available
brew install tmux neovim git     # Hope versions are compatible
# Edit configs manually
# Hope everything works together

# Home Manager way:
home-manager switch              # Atomic installation
# Everything guaranteed to work together
# Instant rollback if problems
# Same result on every machine
```

The beauty is you can start using it **tonight** for just package management, then gradually adopt more features as you learn.

Ready to try the installation? 🚀