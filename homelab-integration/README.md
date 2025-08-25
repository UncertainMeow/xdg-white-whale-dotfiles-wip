# 🏠 Homelab Integration Guide

*Connecting the white whale dotfiles to real homelab infrastructure*

## Overview

This guide shows how to integrate your XDG dotfiles system with foundational homelab components. The environment launcher already includes homelab-focused containers, but here's how to set up the real infrastructure.

## Essential Homelab Components

### 1. Docker/Podman Setup

#### Docker Installation (macOS/Linux)
```bash
# macOS (via Homebrew)
brew install --cask docker

# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Post-installation
sudo systemctl enable docker
sudo systemctl start docker
```

#### Podman Alternative (Rootless Containers)
```bash
# macOS
brew install podman
podman machine init
podman machine start

# Ubuntu/Debian  
sudo apt install podman
```

#### Docker Compose Integration
Your environment launcher already includes containers. To use them:

```bash
# Navigate to environment launcher
cd environment-launcher

# Install the dev-launcher
./install.sh

# Use the homelab containers
dev-launcher
# Select: 🏠 Homelab Command Center
```

### 2. Tailscale - Secure Networking

#### What Tailscale Solves
- Secure remote access to your homelab
- No complex VPN setup or port forwarding  
- Works through NAT and firewalls
- Each device gets a unique IP in your private network

#### Installation
```bash
# macOS
brew install --cask tailscale

# Ubuntu/Debian
curl -fsSL https://tailscale.com/install.sh | sh

# Start Tailscale
sudo tailscale up
```

#### Integration with Environment Launcher
The homelab container already includes Tailscale. To set up:

```bash
# Use the homelab container
dev-launcher
# Select: 🏠 Homelab Command Center

# Inside the container:
tailscale up --authkey=your-auth-key
tailscale status
```

#### Managing Tailscale in Dotfiles
Add to your shell configuration:

```bash
# In new_dotfiles/config/zsh/functions.zsh
tailscale-status() {
    tailscale status --json | jq -r '.Self.TailscaleIPs[0]'
}

tailscale-ssh() {
    local host="$1"
    ssh "root@${host}.your-tailnet.ts.net"
}
```

### 3. GitLab Setup (Self-Hosted)

#### Why Self-Hosted GitLab?
- Complete control over your code and CI/CD
- Private Docker registry included
- Issue tracking and project management
- Free for personal use

#### Docker Compose GitLab Setup
```yaml
# Create: homelab-services/gitlab/docker-compose.yml
version: '3.8'

services:
  gitlab:
    image: gitlab/gitlab-ee:latest
    container_name: gitlab
    hostname: 'gitlab.yourdomain.com'
    ports:
      - '80:80'
      - '443:443'
      - '22:22'
    volumes:
      - './config:/etc/gitlab'
      - './logs:/var/log/gitlab'  
      - './data:/var/opt/gitlab'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'https://gitlab.yourdomain.com'
        gitlab_rails['gitlab_shell_ssh_port'] = 2222
        # Add more configuration as needed
    restart: unless-stopped
    shm_size: '256m'

  gitlab-runner:
    image: gitlab/gitlab-runner:latest
    container_name: gitlab-runner
    volumes:
      - './runner-config:/etc/gitlab-runner'
      - '/var/run/docker.sock:/var/run/docker.sock'
    restart: unless-stopped
    depends_on:
      - gitlab
```

#### Minimal GitLab Setup Script
```bash
#!/bin/bash
# Create: homelab-services/gitlab/setup-gitlab.sh

set -e

echo "🦊 Setting up GitLab instance..."

# Create directories
mkdir -p config logs data runner-config

# Set permissions
sudo chown -R 998:998 config logs data
sudo chown -R 999:999 runner-config

# Start GitLab
docker-compose up -d

echo "⏳ GitLab is starting up (this takes 5-10 minutes)..."
echo "📍 Access GitLab at: http://localhost"
echo "🔐 Initial root password:"
echo "   docker exec -t gitlab grep 'Password:' /etc/gitlab/initial_root_password"

# Wait for GitLab to be ready
echo "⏳ Waiting for GitLab to be healthy..."
until curl -f http://localhost/-/health > /dev/null 2>&1; do
    echo "   Still starting up..."
    sleep 30
done

echo "✅ GitLab is ready!"
echo "🚀 Next steps:"
echo "   1. Visit http://localhost"
echo "   2. Login with root and the password above"
echo "   3. Change the root password"
echo "   4. Create your first project"
```

#### GitLab Integration with Dotfiles

Add GitLab helpers to your shell functions:

```bash
# In new_dotfiles/config/zsh/functions.zsh

# Clone GitLab project
gitlab-clone() {
    local project="$1"
    local gitlab_host="${GITLAB_HOST:-gitlab.yourdomain.com}"
    git clone "git@${gitlab_host}:${project}.git"
}

# Create GitLab project from current directory
gitlab-init() {
    local project_name="${PWD##*/}"
    local gitlab_host="${GITLAB_HOST:-gitlab.yourdomain.com}"
    
    # Initialize repo if needed
    [[ ! -d .git ]] && git init
    
    echo "🦊 Creating GitLab project: $project_name"
    echo "📍 Add this remote manually in GitLab UI, then:"
    echo "   git remote add origin git@${gitlab_host}:username/${project_name}.git"
    echo "   git push -u origin main"
}
```

## Integration Workflow

### 1. Bootstrap New Machine
```bash
# Your future bootstrap script integration
curl bootstrap.sh | bash

# Which would:
# 1. Install Docker/Podman
# 2. Set up Tailscale
# 3. Connect to your GitLab
# 4. Clone and apply dotfiles
# 5. Launch environment containers
```

### 2. Environment Launcher Integration
The environment launcher already supports:
- **🏠 Homelab Command Center**: Docker, Tailscale, network tools
- **🌐 Reverse Proxy Lab**: Traefik for managing multiple services
- **🔧 Network Troubleshooting**: Full networking toolkit

### 3. Dotfiles CI/CD with GitLab
```yaml
# .gitlab-ci.yml in your dotfiles repo
stages:
  - test
  - deploy

test-migration:
  stage: test
  script:
    - ./audit_home.sh
    - ./reddit_method_migrate.sh --dry-run

deploy-dotfiles:
  stage: deploy
  script:
    - ./reddit_method_migrate.sh
  only:
    - main
  when: manual
```

## Advanced Homelab Patterns

### Traefik + Tailscale + GitLab
```yaml
# Advanced reverse proxy setup
version: '3.8'

services:
  traefik:
    image: traefik:v3.0
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./traefik:/etc/traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik.rule=Host(`traefik.yourdomain.com`)"

  gitlab:
    image: gitlab/gitlab-ee:latest
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.gitlab.rule=Host(`gitlab.yourdomain.com`)"
      - "traefik.http.services.gitlab.loadbalancer.server.port=80"

networks:
  default:
    external: true
    name: traefik-network
```

### Monitoring Integration
```yaml
# Add to your homelab stack
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    labels:
      - "traefik.http.routers.prometheus.rule=Host(`prometheus.yourdomain.com`)"

  grafana:
    image: grafana/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    labels:
      - "traefik.http.routers.grafana.rule=Host(`grafana.yourdomain.com`)"
```

## Troubleshooting Common Issues

### Docker Permission Issues
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Or use rootless containers with Podman
alias docker=podman
```

### Tailscale Not Working
```bash
# Check status
tailscale status

# Regenerate auth key
tailscale up --authkey=new-auth-key

# Check connectivity
tailscale ping other-machine
```

### GitLab Memory Issues
```bash
# GitLab needs at least 4GB RAM
# Check memory usage
docker stats gitlab

# Reduce GitLab memory usage
echo "
gitlab_rails['env'] = { 'MALLOC_CONF' => 'dirty_decay_ms:1000,muzzy_decay_ms:1000' }
unicorn['worker_processes'] = 2
sidekiq['concurrency'] = 5
" >> config/gitlab.rb
```

## Next Steps

1. **Set up your first service** using the environment launcher
2. **Connect via Tailscale** for remote access
3. **Deploy GitLab** for your code and CI/CD
4. **Add monitoring** with Prometheus/Grafana
5. **Automate everything** with your dotfiles system

---
*Integration complete: Your dotfiles now connect to real infrastructure* 🐋