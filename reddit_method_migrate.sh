#!/usr/bin/env bash

# Reddit Method Migration Script
# Implements the "zero top-level files" approach from the Reddit comment

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BACKUP_DIR="$HOME/dotfiles_migration_backup_$(date +%Y%m%d_%H%M%S)"
DRY_RUN=${1:-false}

if [[ "$DRY_RUN" == "--dry-run" ]]; then
    DRY_RUN=true
    echo -e "${YELLOW}🔍 DRY RUN MODE - No changes will be made${NC}"
else
    DRY_RUN=false
    echo -e "${BLUE}🚀 LIVE MODE - Changes will be applied${NC}"
fi

echo -e "${BLUE}📦 Reddit Method Migration Script${NC}"
echo "=================================="
echo

# Create XDG directories if they don't exist
create_xdg_structure() {
    echo -e "${BLUE}📁 Creating XDG directory structure...${NC}"
    
    local dirs=(
        ".config"
        ".local/share"
        ".local/state" 
        ".local/bin"
        ".cache"
    )
    
    for dir in "${dirs[@]}"; do
        full_path="$HOME/$dir"
        if [[ ! -d "$full_path" ]]; then
            if [[ "$DRY_RUN" == "false" ]]; then
                mkdir -p "$full_path"
            fi
            echo -e "  ${GREEN}✓${NC} Created ~/$dir"
        else
            echo -e "  ${YELLOW}→${NC} ~/$dir already exists"
        fi
    done
    echo
}

# Create backup directory
create_backup() {
    echo -e "${BLUE}💾 Creating backup directory...${NC}"
    if [[ "$DRY_RUN" == "false" ]]; then
        mkdir -p "$BACKUP_DIR"
    fi
    echo -e "  ${GREEN}✓${NC} Backup location: $BACKUP_DIR"
    echo
}

# Migration mappings: dotfile -> XDG location
declare -A CONFIG_MIGRATIONS=(
    [".gitconfig"]="git/config"
    [".zshrc"]="zsh/zshrc"
    [".bashrc"]="bash/bashrc"
    [".vimrc"]="vim/vimrc"
    [".tmux.conf"]="tmux/tmux.conf"
    [".p10k.zsh"]="zsh/p10k.zsh"
    [".fzf.zsh"]="zsh/fzf.zsh"
    [".fzf.bash"]="bash/fzf.bash"
)

declare -A DATA_MIGRATIONS=(
    [".zsh_history"]="zsh/history"
    [".bash_history"]="bash/history"
    [".lesshst"]="less/history"
)

declare -A CACHE_MIGRATIONS=(
    [".zcompdump"]="zsh/compdump"
)

# Directory migrations (these need special handling)
declare -A DIR_MIGRATIONS=(
    [".ssh"]="KEEP_IN_HOME"  # SSH is special, keep in home
    [".gnupg"]="KEEP_IN_HOME"  # GPG is special, keep in home
    [".aws"]="config/aws"
    [".docker"]="config/docker"
    [".kube"]="config/kube"
    [".gem"]="local/share/gem"
    [".npm"]="cache/npm"
    [".cargo"]="local/share/cargo"
)

# Migrate configuration files
migrate_configs() {
    echo -e "${BLUE}⚙️  Migrating configuration files to ~/.config/...${NC}"
    
    for dotfile in "${!CONFIG_MIGRATIONS[@]}"; do
        src_path="$HOME/$dotfile"
        dest_rel="${CONFIG_MIGRATIONS[$dotfile]}"
        dest_path="$HOME/.config/$dest_rel"
        dest_dir=$(dirname "$dest_path")
        
        if [[ -f "$src_path" ]]; then
            echo -e "  ${GREEN}→${NC} $dotfile → .config/$dest_rel"
            
            if [[ "$DRY_RUN" == "false" ]]; then
                # Create backup
                cp "$src_path" "$BACKUP_DIR/"
                
                # Create destination directory
                mkdir -p "$dest_dir"
                
                # Move file
                mv "$src_path" "$dest_path"
                
                # Create symlink for compatibility
                ln -sf "$dest_path" "$src_path"
                echo -e "    ${YELLOW}↪${NC} Created symlink for compatibility"
            fi
        else
            echo -e "  ${YELLOW}⚠${NC}  $dotfile not found, skipping"
        fi
    done
    echo
}

# Migrate data files  
migrate_data() {
    echo -e "${BLUE}💾 Migrating data files to ~/.local/share/...${NC}"
    
    for dotfile in "${!DATA_MIGRATIONS[@]}"; do
        src_path="$HOME/$dotfile"
        dest_rel="${DATA_MIGRATIONS[$dotfile]}"
        dest_path="$HOME/.local/share/$dest_rel" 
        dest_dir=$(dirname "$dest_path")
        
        if [[ -f "$src_path" ]]; then
            echo -e "  ${GREEN}→${NC} $dotfile → .local/share/$dest_rel"
            
            if [[ "$DRY_RUN" == "false" ]]; then
                cp "$src_path" "$BACKUP_DIR/"
                mkdir -p "$dest_dir"
                mv "$src_path" "$dest_path"
                ln -sf "$dest_path" "$src_path"
                echo -e "    ${YELLOW}↪${NC} Created symlink for compatibility"
            fi
        fi
    done
    echo
}

# Migrate cache files
migrate_cache() {
    echo -e "${BLUE}🗄️  Migrating cache files to ~/.cache/...${NC}"
    
    for dotfile in "${!CACHE_MIGRATIONS[@]}"; do
        src_path="$HOME/$dotfile"
        dest_rel="${CACHE_MIGRATIONS[$dotfile]}"
        dest_path="$HOME/.cache/$dest_rel"
        dest_dir=$(dirname "$dest_path")
        
        if [[ -f "$src_path" ]]; then
            echo -e "  ${GREEN}→${NC} $dotfile → .cache/$dest_rel"
            
            if [[ "$DRY_RUN" == "false" ]]; then
                mkdir -p "$dest_dir"
                mv "$src_path" "$dest_path"
                # No symlink for cache files - they can be regenerated
            fi
        fi
    done
    echo
}

# Migrate directories
migrate_directories() {
    echo -e "${BLUE}📁 Migrating application directories...${NC}"
    
    for dotdir in "${!DIR_MIGRATIONS[@]}"; do
        src_path="$HOME/$dotdir"
        dest_rel="${DIR_MIGRATIONS[$dotdir]}"
        
        if [[ -d "$src_path" ]]; then
            if [[ "$dest_rel" == "KEEP_IN_HOME" ]]; then
                echo -e "  ${YELLOW}⚠${NC}  $dotdir - keeping in home directory (special case)"
                continue
            fi
            
            dest_path="$HOME/.$dest_rel"
            dest_dir=$(dirname "$dest_path")
            
            echo -e "  ${GREEN}→${NC} $dotdir → .$dest_rel"
            
            if [[ "$DRY_RUN" == "false" ]]; then
                # Create backup
                cp -r "$src_path" "$BACKUP_DIR/"
                
                # Create destination directory
                mkdir -p "$dest_dir"
                
                # Move directory
                mv "$src_path" "$dest_path"
                
                # Create symlink for compatibility
                ln -sf "$dest_path" "$src_path"
                echo -e "    ${YELLOW}↪${NC} Created symlink for compatibility"
            fi
        fi
    done
    echo
}

# Set up XDG environment variables
setup_xdg_environment() {
    echo -e "${BLUE}🌍 Setting up XDG environment variables...${NC}"
    
    local xdg_config="# XDG Base Directory Specification
export XDG_CONFIG_HOME=\"\$HOME/.config\"
export XDG_DATA_HOME=\"\$HOME/.local/share\"
export XDG_STATE_HOME=\"\$HOME/.local/state\"
export XDG_CACHE_HOME=\"\$HOME/.cache\"

# Add user binaries to PATH
export PATH=\"\$HOME/.local/bin:\$PATH\"
"
    
    # Determine which shell config file to update
    local shell_config=""
    if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == *"zsh" ]]; then
        shell_config="$HOME/.config/zsh/environment.zsh"
        echo -e "  ${GREEN}→${NC} Adding XDG variables to zsh config"
    elif [[ -n "${BASH_VERSION:-}" ]] || [[ "$SHELL" == *"bash" ]]; then
        shell_config="$HOME/.config/bash/environment.bash"  
        echo -e "  ${GREEN}→${NC} Adding XDG variables to bash config"
    fi
    
    if [[ -n "$shell_config" ]] && [[ "$DRY_RUN" == "false" ]]; then
        mkdir -p "$(dirname "$shell_config")"
        echo "$xdg_config" > "$shell_config"
        echo -e "    ${YELLOW}💡${NC} Remember to source this in your main shell config!"
    fi
    echo
}

# Create the modular shell config structure (Bread method)
setup_modular_config() {
    echo -e "${BLUE}🧱 Setting up modular shell configuration...${NC}"
    
    local config_dir=""
    local main_config=""
    
    if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == *"zsh" ]]; then
        config_dir="$HOME/.config/zsh"
        main_config="$config_dir/zshrc"
    elif [[ -n "${BASH_VERSION:-}" ]] || [[ "$SHELL" == *"bash" ]]; then
        config_dir="$HOME/.config/bash"
        main_config="$config_dir/bashrc"
    else
        echo -e "  ${YELLOW}⚠${NC}  Unknown shell, skipping modular setup"
        return
    fi
    
    if [[ "$DRY_RUN" == "false" ]]; then
        mkdir -p "$config_dir"
        
        # Create modular files
        local modules=(
            "environment"
            "aliases"
            "functions"
            "history"
            "completion"
            "prompt"
        )
        
        for module in "${modules[@]}"; do
            local module_file="$config_dir/${module}.zsh"
            if [[ ! -f "$module_file" ]]; then
                touch "$module_file"
                echo -e "  ${GREEN}✓${NC} Created $module.zsh"
            fi
        done
        
        # Create main config that sources modules
        local main_content="#!/usr/bin/env zsh
# Modular ZSH Configuration
# This file sources all configuration modules

# Source all configuration modules
for config_file in \"$config_dir\"/{environment,aliases,functions,history,completion,prompt}.zsh; do
    [[ -f \"\$config_file\" ]] && source \"\$config_file\"
done

# Source machine-specific configuration if it exists
[[ -f \"$config_dir/local.zsh\" ]] && source \"$config_dir/local.zsh\"
"
        
        echo "$main_content" > "$main_config"
        echo -e "  ${GREEN}✓${NC} Created modular shell configuration"
    fi
    echo
}

# Organize coding projects
organize_coding_projects() {
    echo -e "${BLUE}💻 Organizing coding projects...${NC}"
    
    local projects_dir="$HOME/Documents/coding-projects"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        mkdir -p "$projects_dir"
    fi
    
    # Look for existing code directories
    local code_dirs=()
    while IFS= read -r -d '' dir; do
        code_dirs+=("$(basename "$dir")")
    done < <(find "$HOME" -maxdepth 1 -type d \( -name "*code*" -o -name "*project*" -o -name "*repo*" -o -name "*dev*" \) -print0 2>/dev/null)
    
    if [[ ${#code_dirs[@]} -gt 0 ]]; then
        echo -e "  ${YELLOW}💡${NC} Found code directories to organize:"
        for dir in "${code_dirs[@]}"; do
            echo -e "    → $dir"
        done
        echo -e "  ${GREEN}🎯${NC} Consider moving these to: ~/Documents/coding-projects/"
        echo -e "       Then organize by language: python/, javascript/, rust/, etc."
    else
        echo -e "  ${YELLOW}ℹ${NC}  No obvious code directories found"
    fi
    echo
}

# Show post-migration instructions
show_instructions() {
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${GREEN}🎉 Migration plan complete!${NC}"
    else
        echo -e "${GREEN}🎉 Migration complete!${NC}"
    fi
    echo
    echo -e "${BLUE}📋 Next Steps:${NC}"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        echo -e "  1. ${YELLOW}Restart your shell${NC} or run: source ~/.config/zsh/zshrc"
        echo -e "  2. ${YELLOW}Test all applications${NC} to ensure symlinks work"
        echo -e "  3. ${YELLOW}Update shell config${NC} to source from ~/.config/"
        echo -e "  4. ${YELLOW}Set up backup strategy${NC} (ignore hidden files except .config and .local)"
        echo
        echo -e "${GREEN}💾 Backup created at:${NC} $BACKUP_DIR"
        echo -e "${GREEN}🔄 Rollback command:${NC} ./rollback.sh $BACKUP_DIR"
    else
        echo -e "  1. ${YELLOW}Review the planned changes above${NC}"
        echo -e "  2. ${YELLOW}Run without --dry-run${NC} to apply changes"
        echo -e "  3. ${YELLOW}Make sure you have backups${NC} of important files"
    fi
    echo
}

# Main execution
main() {
    echo -e "${BLUE}Starting Reddit Method migration...${NC}"
    echo
    
    create_backup
    create_xdg_structure
    migrate_configs
    migrate_data  
    migrate_cache
    migrate_directories
    setup_xdg_environment
    setup_modular_config
    organize_coding_projects
    show_instructions
}

# Run main function
main "$@"