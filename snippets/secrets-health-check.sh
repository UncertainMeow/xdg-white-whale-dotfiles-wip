#!/usr/bin/env bash
# Secrets Infrastructure Health Check
# Run this before ANY secrets operations to ensure everything is working

set -euo pipefail

# Colors for output - Enhanced for visibility
RED='\033[1;31m'           # Bold red for failures
GREEN='\033[0;32m'         # Green for success  
YELLOW='\033[1;33m'        # Bold yellow for warnings
BLUE='\033[0;34m'          # Blue for info
PURPLE='\033[1;35m'        # Bold purple for emphasis
CYAN='\033[1;36m'          # Bold cyan for commands
WHITE_ON_RED='\033[1;37;41m'  # White text on red background - CRITICAL
BLINK='\033[5m'            # Blinking text for serious issues
NC='\033[0m'               # No color

echo -e "${BLUE}🔍 Secrets Infrastructure Health Check${NC}"
echo "======================================"

# Track overall health
HEALTH_SCORE=0
MAX_SCORE=0

# Function to report check results with enhanced visual feedback
check_result() {
    local description="$1"
    local status="$2"
    local fix_hint="$3"
    
    MAX_SCORE=$((MAX_SCORE + 1))
    
    if [[ "$status" == "pass" ]]; then
        echo -e "${GREEN}✅ $description${NC}"
        HEALTH_SCORE=$((HEALTH_SCORE + 1))
    elif [[ "$status" == "warn" ]]; then
        echo -e "${YELLOW}⚠️  $description${NC}"
        echo -e "   ${CYAN}💡 Fix: $fix_hint${NC}"
    else
        # FAILURE - Make it REALLY obvious
        echo -e "${WHITE_ON_RED} ❌ FAIL: $description ${NC}"
        echo -e "   ${RED}🔧 REQUIRED FIX: ${CYAN}$fix_hint${NC}"
        echo -e "   ${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    fi
}

# Check 1: Age installed
if command -v age > /dev/null 2>&1; then
    check_result "Age is installed ($(age --version 2>&1 | head -1))" "pass" ""
else
    check_result "Age is installed" "fail" "Run: brew install age"
fi

# Check 2: SOPS installed  
if command -v sops > /dev/null 2>&1; then
    check_result "SOPS is installed ($(sops --version 2>&1 | head -1))" "pass" ""
else
    check_result "SOPS is installed" "fail" "Run: brew install sops"
fi

# Check 3: Age directory exists
AGE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/age"
if [[ -d "$AGE_DIR" ]]; then
    check_result "Age config directory exists" "pass" ""
else
    check_result "Age config directory exists" "fail" "Run: mkdir -p $AGE_DIR"
fi

# Check 4: Private key exists
PRIVATE_KEY="$AGE_DIR/keys.txt"
if [[ -f "$PRIVATE_KEY" ]]; then
    check_result "Private key file exists" "pass" ""
    
    # Check 5: Private key permissions
    if [[ $(stat -f "%A" "$PRIVATE_KEY" 2>/dev/null || stat -c "%a" "$PRIVATE_KEY" 2>/dev/null) == "600" ]]; then
        check_result "Private key has correct permissions (600)" "pass" ""
    else
        check_result "Private key has correct permissions" "fail" "Run: chmod 600 $PRIVATE_KEY"
    fi
    
    # Check 6: Private key is readable
    if [[ -r "$PRIVATE_KEY" ]]; then
        check_result "Private key is readable" "pass" ""
    else
        check_result "Private key is readable" "fail" "Check file permissions and ownership"
    fi
    
    # Check 7: Can derive public key
    if PUBLIC_KEY=$(age-keygen -y "$PRIVATE_KEY" 2>/dev/null); then
        check_result "Can derive public key from private key" "pass" ""
        echo -e "   ${BLUE}Public key: ${PUBLIC_KEY}${NC}"
    else
        check_result "Can derive public key from private key" "fail" "Private key may be corrupted"
    fi
    
else
    check_result "Private key file exists" "fail" "Generate with: age-keygen -o $PRIVATE_KEY"
    PUBLIC_KEY=""
fi

# Check 8: SOPS config exists
if [[ -f ".sops.yaml" ]]; then
    check_result "SOPS config file exists" "pass" ""
    
    # Check 9: SOPS config syntax
    if sops --config .sops.yaml --version > /dev/null 2>&1; then
        check_result "SOPS config syntax is valid" "pass" ""
    else
        check_result "SOPS config syntax is valid" "fail" "Check .sops.yaml for syntax errors"
    fi
    
    # Check 10: Public key in SOPS config
    if [[ -n "$PUBLIC_KEY" ]] && grep -q "$PUBLIC_KEY" .sops.yaml; then
        check_result "Public key is in SOPS config" "pass" ""
    elif [[ -n "$PUBLIC_KEY" ]]; then
        check_result "Public key is in SOPS config" "fail" "Add $PUBLIC_KEY to .sops.yaml"
    else
        check_result "Public key is in SOPS config" "fail" "Generate keys first, then add public key to .sops.yaml"
    fi
    
else
    check_result "SOPS config file exists" "fail" "Create .sops.yaml with your public key"
fi

# Check 11: Test encryption/decryption (only if we have keys)
if [[ -f "$PRIVATE_KEY" && -n "$PUBLIC_KEY" ]]; then
    echo -e "\n${BLUE}🧪 Testing encryption/decryption...${NC}"
    
    # Create temporary test file
    TEST_FILE=$(mktemp)
    TEST_SECRET="test-secret-$(date +%s)"
    echo "$TEST_SECRET" > "$TEST_FILE"
    
    # Test encryption
    if ENCRYPTED=$(age -r "$PUBLIC_KEY" "$TEST_FILE" 2>/dev/null); then
        check_result "Can encrypt with public key" "pass" ""
        
        # Test decryption
        if DECRYPTED=$(echo "$ENCRYPTED" | age -d -i "$PRIVATE_KEY" 2>/dev/null); then
            if [[ "$DECRYPTED" == "$TEST_SECRET" ]]; then
                check_result "Can decrypt with private key" "pass" ""
                check_result "Encryption/decryption round-trip works" "pass" ""
            else
                check_result "Encryption/decryption round-trip works" "fail" "Data corruption in encryption/decryption"
            fi
        else
            check_result "Can decrypt with private key" "fail" "Private key may not match public key"
        fi
    else
        check_result "Can encrypt with public key" "fail" "Public key may be invalid"
    fi
    
    # Cleanup
    rm -f "$TEST_FILE"
fi

# Final health report
echo -e "\n${BLUE}📊 Health Summary${NC}"
echo "=================="
echo -e "Health Score: ${HEALTH_SCORE}/${MAX_SCORE}"

if [[ $HEALTH_SCORE -eq $MAX_SCORE ]]; then
    echo -e "${GREEN}🎉 ALL SYSTEMS GO! Your secrets infrastructure is healthy.${NC}"
    echo -e "${GREEN}✨ You're ready to proceed with confidence!${NC}"
    exit 0
elif [[ $HEALTH_SCORE -gt $((MAX_SCORE * 2 / 3)) ]]; then
    echo -e "${YELLOW}⚠️  MOSTLY HEALTHY - Please address the warnings above before proceeding.${NC}"
    echo -e "${CYAN}💡 Fix the yellow warnings and run this script again.${NC}"
    exit 1
else
    echo -e "${WHITE_ON_RED} 🚨 CRITICAL ISSUES FOUND ${NC}"
    echo -e "${RED}❌ Your secrets infrastructure has serious problems.${NC}"
    echo -e "${RED}🛑 DO NOT PROCEED until all red failures are fixed.${NC}"
    echo -e "${CYAN}🔧 Fix the issues above and run this script again.${NC}"
    exit 2
fi