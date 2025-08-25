#!/usr/bin/env bash
# Step 1: Install SOPS and Age Tools
# This is the first step in our bulletproof secrets setup

set -euo pipefail

# Enhanced colors for maximum visibility
RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
WHITE_ON_RED='\033[1;37;41m'
WHITE_ON_GREEN='\033[1;37;42m'
NC='\033[0m'

echo -e "${PURPLE}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║            🔐 SOPS/age Installation - Step 1            ║"
echo "║                  Safety First Approach                  ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

echo -e "${BLUE}📦 Installing secrets management tools...${NC}\n"

# Function for enhanced status reporting
install_check() {
    local tool="$1"
    local install_cmd="$2"
    
    if command -v "$tool" > /dev/null 2>&1; then
        local version=$($tool --version 2>&1 | head -1)
        echo -e "${GREEN}✅ $tool is already installed: $version${NC}"
        return 0
    else
        echo -e "${YELLOW}📦 Installing $tool...${NC}"
        if eval "$install_cmd"; then
            if command -v "$tool" > /dev/null 2>&1; then
                local version=$($tool --version 2>&1 | head -1)
                echo -e "${WHITE_ON_GREEN} ✅ SUCCESS: $tool installed - $version ${NC}"
                return 0
            else
                echo -e "${WHITE_ON_RED} ❌ INSTALL FAILED: $tool not found after installation ${NC}"
                return 1
            fi
        else
            echo -e "${WHITE_ON_RED} ❌ INSTALL FAILED: Error running $install_cmd ${NC}"
            return 1
        fi
    fi
}

# Install age (encryption tool)
echo -e "${CYAN}🔧 Installing age (encryption tool)...${NC}"
install_check "age" "brew install age"

echo ""

# Install sops (secrets management)
echo -e "${CYAN}🔧 Installing sops (secrets manager)...${NC}"
install_check "sops" "brew install sops"

echo ""

# Install yq (YAML processor - needed for our scripts)
echo -e "${CYAN}🔧 Installing yq (YAML processor)...${NC}"
install_check "yq" "brew install yq"

echo -e "\n${BLUE}🧪 Running post-installation verification...${NC}"

# Verify all tools work
VERIFICATION_PASSED=true

echo -e "${CYAN}Testing age...${NC}"
if age --version > /dev/null 2>&1; then
    echo -e "${GREEN}✅ age is working${NC}"
else
    echo -e "${WHITE_ON_RED} ❌ age verification failed ${NC}"
    VERIFICATION_PASSED=false
fi

echo -e "${CYAN}Testing sops...${NC}"
if sops --version > /dev/null 2>&1; then
    echo -e "${GREEN}✅ sops is working${NC}"
else
    echo -e "${WHITE_ON_RED} ❌ sops verification failed ${NC}"
    VERIFICATION_PASSED=false
fi

echo -e "${CYAN}Testing yq...${NC}"
if yq --version > /dev/null 2>&1; then
    echo -e "${GREEN}✅ yq is working${NC}"
else
    echo -e "${WHITE_ON_RED} ❌ yq verification failed ${NC}"
    VERIFICATION_PASSED=false
fi

# Final status
echo -e "\n${BLUE}📋 Installation Summary${NC}"
echo "======================="

if [[ "$VERIFICATION_PASSED" == "true" ]]; then
    echo -e "${WHITE_ON_GREEN} 🎉 ALL TOOLS INSTALLED SUCCESSFULLY ${NC}"
    echo -e "${GREEN}✨ You're ready for Step 2: Generate Keys${NC}"
    echo -e "${CYAN}💡 Next: Run ./step-02-generate-keys.sh${NC}"
else
    echo -e "${WHITE_ON_RED} 🚨 INSTALLATION ISSUES DETECTED ${NC}"
    echo -e "${RED}❌ Some tools failed verification${NC}"
    echo -e "${CYAN}🔧 Try running this script again or install manually${NC}"
    exit 1
fi