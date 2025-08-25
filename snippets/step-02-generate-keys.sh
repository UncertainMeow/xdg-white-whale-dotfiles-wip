#!/usr/bin/env bash
# Step 2: Generate Age Keys with Maximum Safety
# This creates your encryption keys with multiple backups

set -euo pipefail

# Enhanced colors
RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
WHITE_ON_RED='\033[1;37;41m'
WHITE_ON_GREEN='\033[1;37;42m'
WHITE_ON_BLUE='\033[1;37;44m'
NC='\033[0m'

# Configuration
AGE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/age"
PRIVATE_KEY="$AGE_DIR/keys.txt"
BACKUP_DIR="$HOME/Desktop/age-key-backup-$(date +%Y%m%d-%H%M%S)"

echo -e "${PURPLE}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║             🔑 Age Key Generation - Step 2              ║"
echo "║                 Your Encryption Identity                ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

# Safety check - make sure tools are installed
echo -e "${BLUE}🔍 Pre-flight safety checks...${NC}"

if ! command -v age > /dev/null 2>&1; then
    echo -e "${WHITE_ON_RED} ❌ ABORT: age not installed ${NC}"
    echo -e "${CYAN}🔧 Run ./step-01-install-tools.sh first${NC}"
    exit 1
fi

echo -e "${GREEN}✅ age is installed${NC}"

# Check if keys already exist
if [[ -f "$PRIVATE_KEY" ]]; then
    echo -e "${YELLOW}⚠️  Private key already exists at $PRIVATE_KEY${NC}"
    echo -e "${CYAN}Current public key:${NC}"
    age-keygen -y "$PRIVATE_KEY"
    echo ""
    read -p "Generate new keys anyway? This will OVERWRITE existing keys! (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}✅ Keeping existing keys. Moving to next step.${NC}"
        echo -e "${CYAN}💡 Next: Run ./step-03-setup-sops.sh${NC}"
        exit 0
    fi
    echo -e "${YELLOW}🚨 Creating backup of existing keys...${NC}"
    mkdir -p "$BACKUP_DIR"
    cp "$PRIVATE_KEY" "$BACKUP_DIR/old-keys.txt"
    echo -e "${GREEN}✅ Backup saved to $BACKUP_DIR${NC}"
fi

# Create age directory
echo -e "${BLUE}📁 Creating age configuration directory...${NC}"
mkdir -p "$AGE_DIR"

# Generate the keys
echo -e "${WHITE_ON_BLUE} 🔑 GENERATING YOUR ENCRYPTION KEYS ${NC}"
echo -e "${CYAN}This creates your personal encryption identity...${NC}\n"

# Generate and capture output
KEY_OUTPUT=$(age-keygen -o "$PRIVATE_KEY" 2>&1)
PUBLIC_KEY=$(echo "$KEY_OUTPUT" | grep "age1" | sed 's/.*age1/age1/')

# Verify generation worked
if [[ ! -f "$PRIVATE_KEY" ]]; then
    echo -e "${WHITE_ON_RED} ❌ KEY GENERATION FAILED ${NC}"
    echo -e "${RED}Private key file was not created${NC}"
    exit 1
fi

if [[ -z "$PUBLIC_KEY" ]]; then
    echo -e "${WHITE_ON_RED} ❌ PUBLIC KEY EXTRACTION FAILED ${NC}"
    echo -e "${RED}Could not extract public key${NC}"
    exit 1
fi

# Set secure permissions
chmod 600 "$PRIVATE_KEY"

# Verify we can derive public key from private key
DERIVED_PUBLIC=$(age-keygen -y "$PRIVATE_KEY")
if [[ "$PUBLIC_KEY" != "$DERIVED_PUBLIC" ]]; then
    echo -e "${WHITE_ON_RED} ❌ KEY VERIFICATION FAILED ${NC}"
    echo -e "${RED}Public key mismatch detected${NC}"
    exit 1
fi

echo -e "${WHITE_ON_GREEN} ✅ KEYS GENERATED SUCCESSFULLY ${NC}\n"

# Display key information
echo -e "${BLUE}🔑 Your Encryption Identity${NC}"
echo "========================="
echo -e "${CYAN}Private Key Location:${NC} $PRIVATE_KEY"
echo -e "${CYAN}Public Key:${NC} $PUBLIC_KEY"
echo -e "${CYAN}Key Permissions:${NC} $(ls -la "$PRIVATE_KEY" | awk '{print $1}')"
echo ""

# Create comprehensive backup
echo -e "${BLUE}💾 Creating backup package for 1Password...${NC}"
mkdir -p "$BACKUP_DIR"

# Create backup information file
cat > "$BACKUP_DIR/KEY_INFO.txt" << EOF
Age Encryption Keys Backup
Generated: $(date)
Computer: $(hostname)
User: $(whoami)

PRIVATE KEY (keep secure):
$(cat "$PRIVATE_KEY")

PUBLIC KEY (safe to share):
$PUBLIC_KEY

RESTORATION INSTRUCTIONS:
1. Copy the private key content to ~/.config/age/keys.txt
2. Set permissions: chmod 600 ~/.config/age/keys.txt
3. Test with: age-keygen -y ~/.config/age/keys.txt

SOPS Configuration:
Add this to .sops.yaml:
keys:
  - &my_key $PUBLIC_KEY

creation_rules:
  - key_groups:
      - age:
          - *my_key
EOF

# Copy private key for backup
cp "$PRIVATE_KEY" "$BACKUP_DIR/"

echo -e "${WHITE_ON_GREEN} 📦 BACKUP CREATED: $BACKUP_DIR ${NC}"
echo ""

# CRITICAL: Test the keys work BEFORE telling user to save to 1Password
echo -e "${WHITE_ON_BLUE} 🧪 TESTING KEYS BEFORE PROCEEDING ${NC}"
echo -e "${CYAN}Testing encryption/decryption to ensure keys work...${NC}"
TEST_FILE=$(mktemp)
TEST_SECRET="test-secret-$(date +%s)"
echo "$TEST_SECRET" > "$TEST_FILE"

# More detailed error reporting for debugging
echo -e "${CYAN}🔍 Debug info:${NC}"
echo -e "  Public key: $PUBLIC_KEY"
echo -e "  Private key file: $PRIVATE_KEY"
echo -e "  Test secret: $TEST_SECRET"
echo ""

# Test encryption
echo -e "${CYAN}Step 1: Testing encryption...${NC}"
if ENCRYPTED=$(age -r "$PUBLIC_KEY" "$TEST_FILE" 2>&1); then
    echo -e "${GREEN}✅ Encryption successful${NC}"
else
    echo -e "${WHITE_ON_RED} ❌ ENCRYPTION FAILED ${NC}"
    echo -e "${RED}Error output: $ENCRYPTED${NC}"
    rm -f "$TEST_FILE"
    echo -e "${RED}🛑 STOPPING - Keys are broken, don't save to 1Password!${NC}"
    exit 1
fi

# Test decryption
echo -e "${CYAN}Step 2: Testing decryption...${NC}"
if DECRYPTED=$(echo "$ENCRYPTED" | age -d -i "$PRIVATE_KEY" 2>&1); then
    echo -e "${GREEN}✅ Decryption successful${NC}"
else
    echo -e "${WHITE_ON_RED} ❌ DECRYPTION FAILED ${NC}"
    echo -e "${RED}Error output: $DECRYPTED${NC}"
    rm -f "$TEST_FILE"
    echo -e "${RED}🛑 STOPPING - Keys are broken, don't save to 1Password!${NC}"
    exit 1
fi

# Test data integrity
echo -e "${CYAN}Step 3: Testing data integrity...${NC}"
if [[ "$DECRYPTED" == "$TEST_SECRET" ]]; then
    echo -e "${GREEN}✅ Data integrity verified${NC}"
    echo -e "${WHITE_ON_GREEN} 🎉 ALL TESTS PASSED - KEYS ARE WORKING ${NC}"
else
    echo -e "${WHITE_ON_RED} ❌ DECRYPTION MISMATCH ${NC}"
    echo -e "${RED}Expected: $TEST_SECRET${NC}"
    echo -e "${RED}Got: $DECRYPTED${NC}"
    rm -f "$TEST_FILE"
    echo -e "${RED}🛑 STOPPING - Data corruption detected!${NC}"
    exit 1
fi

rm -f "$TEST_FILE"

# NOW it's safe to tell them to save to 1Password
echo -e "\n${YELLOW}🏦 NOW SAFE: Save to 1Password${NC}"
echo "================================"
echo -e "${CYAN}Choose your backup method:${NC}"
echo -e "${GREEN}  1) 📋 Clipboard method (RECOMMENDED - more secure)${NC}"
echo -e "${BLUE}  2) 📁 File method (creates file on Desktop)${NC}"
echo ""
read -p "Choose method (1 or 2): " -n 1 -r backup_method
echo -e "\n"

if [[ $backup_method == "1" ]]; then
    # CLIPBOARD METHOD - More secure, no file preview issues
    echo -e "${WHITE_ON_GREEN} 📋 CLIPBOARD METHOD - Enhanced Security ${NC}"
    
    # Create the backup content in memory
    BACKUP_CONTENT="Age Encryption Keys Backup
Generated: $(date)
Computer: $(hostname)
User: $(whoami)

PRIVATE KEY (keep secure):
$(cat "$PRIVATE_KEY")

PUBLIC KEY (safe to share):
$PUBLIC_KEY

RESTORATION INSTRUCTIONS:
1. Copy the private key content to ~/.config/age/keys.txt
2. Set permissions: chmod 600 ~/.config/age/keys.txt
3. Test with: age-keygen -y ~/.config/age/keys.txt

SOPS Configuration:
Add this to .sops.yaml:
keys:
  - &my_key $PUBLIC_KEY

creation_rules:
  - key_groups:
      - age:
          - *my_key"
    
    # Copy to clipboard
    echo "$BACKUP_CONTENT" | pbcopy
    
    echo -e "${GREEN}✅ Backup content copied to clipboard!${NC}"
    echo -e "${CYAN}📋 1Password Instructions:${NC}"
    echo -e "${CYAN}  1. Open 1Password${NC}"
    echo -e "${CYAN}  2. Create new Secure Note titled: 'Age Private Key - Dotfiles Encryption'${NC}"
    echo -e "${CYAN}  3. Click in the notes field and press ⌘+V to paste${NC}"
    echo -e "${CYAN}  4. Save the secure note${NC}"
    echo ""
    echo -e "${YELLOW}💡 No files created on Desktop - everything in clipboard only!${NC}"
    
else
    # ORIGINAL FILE METHOD
    echo -e "${WHITE_ON_BLUE} 📁 FILE METHOD ${NC}"
    echo -e "${YELLOW}⚠️  Files will be created on Desktop (remember to delete after!)${NC}"
    echo -e "${CYAN}📁 File Instructions:${NC}"
    echo -e "${CYAN}  1. Open 1Password${NC}"
    echo -e "${CYAN}  2. Create new Secure Note titled: 'Age Private Key - Dotfiles Encryption'${NC}"
    echo -e "${CYAN}  3. Copy the entire contents of: $BACKUP_DIR/KEY_INFO.txt${NC}"
    echo -e "${CYAN}  4. Save the secure note${NC}"
    echo -e "${CYAN}  5. Delete the backup folder: $BACKUP_DIR${NC}"
fi

echo ""
echo -e "${GREEN}Press ENTER after you've saved to 1Password...${NC}"
read -r

# Final summary
echo -e "\n${WHITE_ON_GREEN} 🎉 STEP 2 COMPLETE: Keys Generated and Tested ${NC}"
echo -e "${GREEN}✨ Your encryption identity is ready!${NC}"
echo -e "${YELLOW}🚨 Don't forget to save the backup to 1Password!${NC}"
echo -e "${CYAN}💡 Next: Run ./step-03-setup-sops.sh${NC}"

# Show next steps
echo -e "\n${BLUE}📋 What We Just Did${NC}"
echo "==================="
echo -e "${GREEN}✅ Generated your personal age key pair${NC}"
echo -e "${GREEN}✅ Secured private key with proper permissions${NC}"
echo -e "${GREEN}✅ Created comprehensive backup package${NC}"
echo -e "${GREEN}✅ Verified encryption/decryption works${NC}"
echo -e "${GREEN}✅ Ready for SOPS configuration${NC}"