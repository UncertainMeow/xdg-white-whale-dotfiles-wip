# Modern Secrets Management Strategy

## The Three-Tier Approach

### Tier 1: 1Password (Your Current Setup)
- Human passwords, API keys, certificates
- Shared team secrets
- Browser integration
- Mobile access

### Tier 2: Age/SOPS (The Missing Piece)  
- **Configuration secrets** in git repos
- **Environment-specific values** 
- **Machine-specific configurations**
- **Encrypted dotfiles sections**

### Tier 3: Ansible Vault (Future)
- **Infrastructure secrets**
- **Deployment configurations** 
- **Server management**

## How They Work Together

```
1Password ─────┐
               ├─── Age Key ────── SOPS ────── Git Repo
Ansible Vault ─┘                              (encrypted)
```

## Practical Setup

### 1. Age Key Generation
```bash
# Generate age key pair
age-keygen -o ~/.config/age/keys.txt

# Store public key in 1Password
# Store private key securely on each machine
```

### 2. SOPS Configuration
```yaml
# .sops.yaml in your dotfiles repo
keys:
  - &kellen_personal age1xxxxxx...  # Your personal key
  - &work_laptop age1yyyyyy...     # Work machine key
  - &home_desktop age1zzzzzz...    # Home machine key

creation_rules:
  - path_regex: secrets/personal/.*
    key_groups:
      - age:
          - *kellen_personal
          
  - path_regex: secrets/work/.*  
    key_groups:
      - age:
          - *kellen_personal
          - *work_laptop
```

### 3. Encrypted Secrets Structure
```
dotfiles/
├── secrets/
│   ├── personal/
│   │   ├── api_keys.env      # SOPS encrypted
│   │   └── ssh_config.enc    # SOPS encrypted
│   ├── work/
│   │   ├── corporate.env     # SOPS encrypted  
│   │   └── vpn_config.enc    # SOPS encrypted
│   └── machines/
│       ├── work-laptop.env   # Machine-specific
│       └── home-desktop.env  # Machine-specific
```

### 4. Integration with Your Configs
```bash
# In your zsh environment.zsh
if [[ -f "$XDG_CONFIG_HOME/secrets/personal/api_keys.env" ]]; then
    # Decrypt and source
    sops -d "$XDG_CONFIG_HOME/secrets/personal/api_keys.env" | source /dev/stdin
fi
```

## Benefits Over 1Password Alone

1. **Version controlled** secrets (encrypted)
2. **Machine-specific** configurations  
3. **Scriptable** access
4. **Gitops** workflow for secrets
5. **Granular sharing** (work vs personal keys)

## Migration Strategy

1. **Keep 1Password** for everything it's good at
2. **Move config secrets** to SOPS (API keys in configs, etc.)
3. **Use age keys** generated and stored in 1Password
4. **Encrypt sensitive dotfile sections**

This gives you the best of both worlds!