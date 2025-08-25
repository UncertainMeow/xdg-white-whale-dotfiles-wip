# 🔑 Crystal Clear Key Management Strategy

## 🎯 The Simple Truth About Keys

You're dealing with **exactly TWO things**:
1. **Private Key** (like your house key - keeps secrets safe, NEVER share)
2. **Public Key** (like your mailing address - safe to share, used to send you encrypted mail)

That's it. No juggling 4 different tokens. Just these two, working together.

## 🏠 Where Keys Live (The Mental Model)

Think of it like your house security:

```
🏠 Your House (Your Computer)
├── 🔐 Private Key (~/.config/age/keys.txt)
│   └── "This unlocks secrets meant for me"
│
📮 Public Mailbox (Git Repository) 
├── 📬 Public Key (.sops.yaml)
│   └── "This is my address for sending me encrypted secrets"
│
🏦 Safety Deposit Box (1Password)
├── 💎 Private Key Backup
│   └── "In case I lose my house key"
```

## 🔐 How Encryption Actually Works

### When You Want to SAVE a Secret:
1. You write a secret in a file
2. SOPS looks up your **public key** (from .sops.yaml)
3. SOPS encrypts the file using that public key
4. The encrypted file goes into git (safe!)

### When You Want to READ a Secret:
1. SOPS finds the encrypted file
2. SOPS looks for your **private key** (~/.config/age/keys.txt)
3. SOPS decrypts the file using that private key
4. You see your secret!

**Key insight:** Public key encrypts, private key decrypts. Always.

## 📋 The Foolproof Key Lifecycle

### Step 1: Generate Keys (ONE TIME ONLY)
```bash
# This creates BOTH keys at once
age-keygen -o ~/.config/age/keys.txt

# What this creates:
# - Private key: saved to ~/.config/age/keys.txt
# - Public key: printed to screen (starts with "age1...")
```

### Step 2: Backup Private Key (IMMEDIATELY)
```bash
# Copy the ENTIRE private key file to 1Password
# Title: "Age Private Key - Dotfiles Encryption"
# Type: Secure Note
# Content: [paste entire file contents]
```

### Step 3: Store Public Key in Config (FOR SHARING)
```yaml
# .sops.yaml - this goes in git
keys:
  - &my_key age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

creation_rules:
  - key_groups:
      - age:
          - *my_key
```

## 🛡️ Safety Checks (Run These BEFORE Any Operation)

### The "Am I Safe?" Checklist
```bash
# 1. Private key exists and is readable
test -f ~/.config/age/keys.txt && echo "✅ Private key exists" || echo "❌ Private key missing"

# 2. Private key has correct permissions
ls -la ~/.config/age/keys.txt | grep -q "^-rw-------" && echo "✅ Permissions correct" || echo "❌ Fix permissions"

# 3. Public key is in SOPS config
grep -q "age1" .sops.yaml && echo "✅ Public key in config" || echo "❌ Add public key to config"

# 4. Can we actually encrypt/decrypt?
echo "test" | age -r $(grep age1 .sops.yaml | cut -d' ' -f3) | age -d -i ~/.config/age/keys.txt
```

## 🚨 Error Recovery Procedures

### "I Lost My Private Key!"
```bash
# STEP 1: Don't panic - check 1Password backup
# STEP 2: Copy private key from 1Password to ~/.config/age/keys.txt
# STEP 3: Fix permissions
chmod 600 ~/.config/age/keys.txt
# STEP 4: Test with existing encrypted file
sops -d secrets/test.env
```

### "I Can't Decrypt Anything!"
```bash
# STEP 1: Verify private key exists
ls -la ~/.config/age/keys.txt

# STEP 2: Check permissions
chmod 600 ~/.config/age/keys.txt

# STEP 3: Verify public key matches
age-keygen -y ~/.config/age/keys.txt  # Shows public key
grep age1 .sops.yaml  # Should match

# STEP 4: Test with simple encryption
echo "test" | age -r $(age-keygen -y ~/.config/age/keys.txt) | age -d -i ~/.config/age/keys.txt
```

### "SOPS Says 'No Key Found'!"
```bash
# This means public/private keys don't match
# STEP 1: Get current public key from private key
age-keygen -y ~/.config/age/keys.txt

# STEP 2: Update .sops.yaml with correct public key
# STEP 3: Re-encrypt any existing files with new key
```

## 📝 Documentation Template for Each Secret

Every time you add a secret, fill this out:

```markdown
## Secret Added: [SECRET_NAME]
**Date:** 2024-XX-XX
**What:** [Brief description]
**File:** [Path to encrypted file]
**Original stored in:** [1Password vault name]
**Public key used:** age1xxx... (first 10 chars)
**Tested decryption:** [Date you verified it works]

### To recover this secret:
1. Ensure private key is at ~/.config/age/keys.txt
2. Run: sops -d [file path]
3. If that fails, restore private key from 1Password and retry
```

## 🎯 The "One Secret at a Time" Rule

**NEVER** encrypt multiple secrets in one session until you've verified the previous one works perfectly.

### The Workflow:
1. ✅ Add ONE secret to a file
2. ✅ Encrypt with SOPS
3. ✅ Immediately test decryption
4. ✅ Document what you did
5. ✅ Only then add the next secret

## 🔍 Validation Script (Run Before Any Changes)

```bash
#!/usr/bin/env bash
# secrets-health-check.sh

echo "🔍 Checking secrets infrastructure health..."

# Check private key
if [[ -f ~/.config/age/keys.txt ]]; then
    echo "✅ Private key exists"
    if [[ $(stat -f "%A" ~/.config/age/keys.txt) == "600" ]]; then
        echo "✅ Private key permissions correct"
    else
        echo "⚠️  Private key permissions need fixing"
        echo "   Run: chmod 600 ~/.config/age/keys.txt"
    fi
else
    echo "❌ Private key missing!"
    echo "   Restore from 1Password backup"
    exit 1
fi

# Check SOPS config
if [[ -f .sops.yaml ]]; then
    echo "✅ SOPS config exists"
    if sops --version > /dev/null 2>&1; then
        echo "✅ SOPS is installed"
    else
        echo "❌ SOPS not installed"
        echo "   Run: brew install sops"
    fi
else
    echo "❌ SOPS config missing"
    echo "   Create .sops.yaml with your public key"
fi

# Test encryption/decryption
echo "🧪 Testing encryption/decryption..."
test_file=$(mktemp)
echo "test-secret-$(date +%s)" > "$test_file"
if age -r $(age-keygen -y ~/.config/age/keys.txt) "$test_file" | age -d -i ~/.config/age/keys.txt > /dev/null 2>&1; then
    echo "✅ Encryption/decryption working"
else
    echo "❌ Encryption/decryption failed"
    echo "   Your keys may not match"
fi
rm -f "$test_file"

echo "🎯 Health check complete!"
```

This approach removes the complexity and fear by making everything **crystal clear** and **well-documented**! 🛡️