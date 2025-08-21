#!/usr/bin/env bash

# Home Directory Audit Script
# Analyzes your current home directory structure against XDG best practices

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Home Directory XDG Compliance Audit${NC}"
echo "========================================"
echo

# Check if XDG environment variables are set
echo -e "${BLUE}📋 XDG Environment Variables:${NC}"
for var in XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME; do
    if [[ -v "$var" ]]; then
        eval "value=\$$var"
        echo -e "  ${GREEN}✓${NC} $var = $value"
    else
        echo -e "  ${RED}✗${NC} $var = (not set)"
        case "$var" in
            XDG_CONFIG_HOME) echo -e "    ${YELLOW}→${NC} Should be: \$HOME/.config" ;;
            XDG_DATA_HOME) echo -e "    ${YELLOW}→${NC} Should be: \$HOME/.local/share" ;;
            XDG_STATE_HOME) echo -e "    ${YELLOW}→${NC} Should be: \$HOME/.local/state" ;;
            XDG_CACHE_HOME) echo -e "    ${YELLOW}→${NC} Should be: \$HOME/.cache" ;;
        esac
    fi
done
echo

# Check for existing XDG directories
echo -e "${BLUE}📁 XDG Directory Structure:${NC}"
xdg_dirs=(
    ".config:Configuration files"
    ".local/share:Application data"
    ".local/state:State files (logs, history)"
    ".local/bin:User binaries"
    ".cache:Cache data"
)

for dir_info in "${xdg_dirs[@]}"; do
    IFS=":" read -r dir desc <<< "$dir_info"
    full_path="$HOME/$dir"
    if [[ -d "$full_path" ]]; then
        size=$(du -sh "$full_path" 2>/dev/null | cut -f1)
        echo -e "  ${GREEN}✓${NC} ~/$dir ($size) - $desc"
    else
        echo -e "  ${RED}✗${NC} ~/$dir - $desc (missing)"
    fi
done
echo

# Analyze top-level dotfiles (the clutter!)
echo -e "${BLUE}🗂️  Top-Level Dotfiles (Potential XDG Violations):${NC}"
dotfile_count=0
potential_configs=()
potential_data=()
potential_cache=()

# Find all top-level dotfiles and directories
while IFS= read -r -d '' item; do
    name=$(basename "$item")
    
    # Skip some expected/system files
    case "$name" in
        .DS_Store|.CFUserTextEncoding|.Trash|.localized) continue ;;
        .bash_sessions|.zsh_sessions) continue ;;
    esac
    
    if [[ -f "$item" ]]; then
        size=$(ls -lah "$item" | awk '{print $5}')
        echo -e "  ${YELLOW}📄${NC} $name ($size)"
        
        # Categorize likely XDG candidates
        case "$name" in
            .*rc|.*profile|.*conf*|.*config*) potential_configs+=("$name") ;;
            .*history|.*log) potential_data+=("$name") ;;
            .*cache*) potential_cache+=("$name") ;;
        esac
        
        ((dotfile_count++))
    elif [[ -d "$item" ]]; then
        size=$(du -sh "$item" 2>/dev/null | cut -f1 || echo "?")
        echo -e "  ${YELLOW}📁${NC} $name/ ($size)"
        
        # Categorize directories
        case "$name" in
            .*) 
                if [[ "$name" != ".config" && "$name" != ".local" && "$name" != ".cache" ]]; then
                    potential_configs+=("$name")
                    ((dotfile_count++))
                fi
                ;;
        esac
    fi
done < <(find "$HOME" -maxdepth 1 -name ".*" -print0)

echo -e "\n${YELLOW}📊 Total top-level dotfiles/dirs: $dotfile_count${NC}"
echo

# Show migration suggestions
if [[ ${#potential_configs[@]} -gt 0 ]]; then
    echo -e "${BLUE}🎯 Suggested Migrations to ~/.config/:${NC}"
    for item in "${potential_configs[@]}"; do
        echo -e "  ${GREEN}→${NC} $item"
    done
    echo
fi

if [[ ${#potential_data[@]} -gt 0 ]]; then
    echo -e "${BLUE}🎯 Suggested Migrations to ~/.local/share/:${NC}"
    for item in "${potential_data[@]}"; do
        echo -e "  ${GREEN}→${NC} $item"
    done
    echo
fi

# Analyze code organization
echo -e "${BLUE}💻 Code Organization Analysis:${NC}"
code_dirs=()
while IFS= read -r -d '' dir; do
    name=$(basename "$dir")
    size=$(du -sh "$dir" 2>/dev/null | cut -f1 || echo "?")
    echo -e "  ${GREEN}📁${NC} $name/ ($size)"
    code_dirs+=("$name")
done < <(find "$HOME" -maxdepth 1 -type d \( -name "*code*" -o -name "*project*" -o -name "*repo*" -o -name "*dev*" \) -print0 2>/dev/null)

if [[ ${#code_dirs[@]} -gt 0 ]]; then
    echo -e "\n${YELLOW}💡 Consider consolidating these into: ~/Documents/coding-projects/${NC}"
    echo -e "   Organized by language: python/, javascript/, rust/, etc."
fi
echo

# Check PATH for .local/bin
echo -e "${BLUE}🛤️  PATH Analysis:${NC}"
if [[ "$PATH" == *"$HOME/.local/bin"* ]]; then
    echo -e "  ${GREEN}✓${NC} ~/.local/bin is in PATH"
else
    echo -e "  ${RED}✗${NC} ~/.local/bin is NOT in PATH"
    echo -e "    ${YELLOW}→${NC} Add to your shell config: export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

if [[ -d "$HOME/.local/bin" ]]; then
    bin_count=$(find "$HOME/.local/bin" -type f -executable 2>/dev/null | wc -l)
    echo -e "  ${GREEN}📦${NC} ~/.local/bin contains $bin_count executables"
else
    echo -e "  ${YELLOW}📦${NC} ~/.local/bin directory doesn't exist yet"
fi
echo

# Final recommendations
echo -e "${BLUE}🎯 Reddit Method Compliance Score:${NC}"

score=0
max_score=10

# XDG dirs exist
[[ -d "$HOME/.config" ]] && ((score++))
[[ -d "$HOME/.local" ]] && ((score++))
[[ -d "$HOME/.cache" ]] && ((score++))

# Environment variables set
[[ -v XDG_CONFIG_HOME ]] && ((score++))
[[ -v XDG_DATA_HOME ]] && ((score++))

# PATH includes .local/bin
[[ "$PATH" == *"$HOME/.local/bin"* ]] && ((score++))

# Low dotfile count (fewer than 10 is good)
[[ $dotfile_count -lt 10 ]] && ((score++))
[[ $dotfile_count -lt 5 ]] && ((score++))

# Bonus points
[[ $dotfile_count -eq 0 ]] && ((score+=2))  # The holy grail!

percentage=$((score * 100 / max_score))

if [[ $percentage -ge 80 ]]; then
    color=$GREEN
    status="Excellent! 🏆"
elif [[ $percentage -ge 60 ]]; then
    color=$YELLOW
    status="Good progress 🎯"
else
    color=$RED
    status="Needs work 🔧"
fi

echo -e "  ${color}$score/$max_score ($percentage%) - $status${NC}"
echo

echo -e "${BLUE}📋 Next Steps:${NC}"
if [[ $dotfile_count -gt 0 ]]; then
    echo -e "  1. Run ${GREEN}./reddit_method_migrate.sh${NC} to implement zero top-level files"
fi
echo -e "  2. Set up XDG environment variables in your shell config"
echo -e "  3. Organize code directories into ~/Documents/coding-projects/"
echo -e "  4. Set up the backup strategy (ignore hidden files except ~/.config and ~/.local)"
echo

echo -e "${GREEN}✨ Audit complete! Ready to transform your home directory? ✨${NC}"