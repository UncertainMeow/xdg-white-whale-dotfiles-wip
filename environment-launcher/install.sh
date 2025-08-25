#!/usr/bin/env bash
# Environment Launcher Installation Script

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Installing Environment Launcher Magic...${NC}\n"

# Create directories
echo -e "${YELLOW}📁 Creating directories...${NC}"
mkdir -p ~/.config/dev-environments
mkdir -p ~/.local/bin

# Copy files
echo -e "${YELLOW}📄 Installing configuration files...${NC}"
cp ../new_dotfiles/config/dev-environments/* ~/.config/dev-environments/
cp ../new_dotfiles/local/bin/dev-launcher ~/.local/bin/
chmod +x ~/.local/bin/dev-launcher

# Check dependencies
echo -e "${YELLOW}🔍 Checking dependencies...${NC}"
deps_needed=()

if ! command -v fzf > /dev/null; then
    deps_needed+=(fzf)
fi

if ! command -v yq > /dev/null; then
    deps_needed+=(yq)
fi

if [[ ${#deps_needed[@]} -gt 0 ]]; then
    echo -e "${RED}❌ Missing dependencies: ${deps_needed[*]}${NC}"
    echo -e "${YELLOW}💡 Install with: brew install ${deps_needed[*]}${NC}"
    exit 1
fi

# Test the installation
echo -e "${YELLOW}🧪 Testing installation...${NC}"
if ~/.local/bin/dev-launcher --demo; then
    echo -e "${GREEN}✅ Installation successful!${NC}"
else
    echo -e "${RED}❌ Installation test failed${NC}"
    exit 1
fi

echo -e "\n${GREEN}🎉 Environment Launcher installed successfully!${NC}"
echo -e "${BLUE}📖 Next steps:${NC}"
echo -e "1. Install Docker Desktop if you haven't already"
echo -e "2. Add Hammerspoon hotkey (see README.md)"
echo -e "3. Run: ~/.local/bin/dev-launcher --demo to test"
echo -e "4. Run: ~/.local/bin/dev-launcher when Docker is ready"
echo -e "\n${YELLOW}⌨️ Suggested hotkey: ⌘+Shift+D${NC}"