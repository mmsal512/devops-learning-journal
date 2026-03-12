#!/bin/bash
# ============================================================
#  Infra Full Stack — Server Info Collector
#  Purpose: Collect server details to design the portfolio project
#  Author: Mohammed Alefari
#  Usage: bash collect-server-info.sh
#  Note: Run on your target server
# ============================================================

set -euo pipefail

# ===================== Colors =====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ===================== Output File =====================
REPORT_FILE="$HOME/server-info-report-$(date +%Y%m%d-%H%M%S).txt"
REPORT_JSON="$HOME/server-info-$(date +%Y%m%d-%H%M%S).json"

# ===================== Helper Functions =====================
separator() {
    echo "═══════════════════════════════════════════════════════════════" | tee -a "$REPORT_FILE"
}

header() {
    echo "" | tee -a "$REPORT_FILE"
    separator
    echo -e "  ${CYAN}${BOLD}$1${NC}" | tee -a "$REPORT_FILE"
    separator
}

info() {
    echo -e "  ${GREEN}▸${NC} ${BOLD}$1:${NC} $2" | tee -a "$REPORT_FILE"
}

warn() {
    echo -e "  ${YELLOW}⚠${NC} $1" | tee -a "$REPORT_FILE"
}

cmd_check() {
    if command -v "$1" &>/dev/null; then
        echo "installed ($(command -v "$1"))"
    else
        echo "NOT installed"
    fi
}

safe_run() {
    # Run a command safely, return output or "N/A"
    local result
    result=$("$@" 2>/dev/null) || result="N/A"
    echo "$result"
}

# ===================== Start =====================
echo "" > "$REPORT_FILE"

echo -e "${CYAN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     Infra Full Stack — Server Info Collector              ║"
echo "║     Collecting data to build your portfolio project       ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# ============================================================
# SECTION 1: SYSTEM INFO
# ============================================================
header "1. SYSTEM INFORMATION"

info "Hostname" "$(hostname)"
info "OS" "$(safe_run cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
info "Kernel" "$(uname -r)"
info "Architecture" "$(uname -m)"
info "Uptime" "$(uptime -p 2>/dev/null || uptime)"
info "Current User" "$(whoami)"
info "Home Directory" "$HOME"
info "Shell" "$SHELL"
info "Timezone" "$(timedatectl show --property=Timezone --value 2>/dev/null || cat /etc/timezone 2>/dev/null || echo 'N/A')"
info "Date" "$(date '+%Y-%m-%d %H:%M:%S %Z')"
info "Locale" "$(locale 2>/dev/null | head -1 || echo 'N/A')"

# ============================================================
# SECTION 2: HARDWARE & RESOURCES
# ============================================================
header "2. HARDWARE & RESOURCES"

# CPU
CPU_MODEL=$(grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | xargs || echo "N/A")
CPU_CORES=$(nproc 2>/dev/null || echo "N/A")
info "CPU Model" "$CPU_MODEL"
info "CPU Cores" "$CPU_CORES"

# RAM
RAM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
RAM_USED=$(free -h | awk '/^Mem:/ {print $3}')
RAM_FREE=$(free -h | awk '/^Mem:/ {print $4}')
RAM_AVAILABLE=$(free -h | awk '/^Mem:/ {print $7}')
RAM_PERCENT=$(free | awk '/^Mem:/ {printf "%.1f", $3/$2 * 100}')
info "RAM Total" "$RAM_TOTAL"
info "RAM Used" "$RAM_USED ($RAM_PERCENT%)"
info "RAM Available" "$RAM_AVAILABLE"

# Swap
SWAP_TOTAL=$(free -h | awk '/^Swap:/ {print $2}')
SWAP_USED=$(free -h | awk '/^Swap:/ {print $3}')
info "Swap Total" "$SWAP_TOTAL"
info "Swap Used" "$SWAP_USED"
info "Swappiness" "$(cat /proc/sys/vm/swappiness 2>/dev/null || echo 'N/A')"

# Disk
echo "" | tee -a "$REPORT_FILE"
echo -e "  ${BOLD}Disk Usage:${NC}" | tee -a "$REPORT_FILE"
df -h / /home /tmp 2>/dev/null | tee -a "$REPORT_FILE"

DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_AVAIL=$(df -h / | awk 'NR==2 {print $4}')
DISK_PERCENT=$(df / | awk 'NR==2 {print $5}')
info "Root Disk Total" "$DISK_TOTAL"
info "Root Disk Used" "$DISK_USED ($DISK_PERCENT)"
info "Root Disk Available" "$DISK_AVAIL"

# Load Average
info "Load Average" "$(cat /proc/loadavg | awk '{print $1, $2, $3}')"

# ============================================================
# SECTION 3: NETWORK CONFIGURATION
# ============================================================
header "3. NETWORK CONFIGURATION"

# Public IP
PUBLIC_IP=$(curl -sf --max-time 5 https://api.ipify.org 2>/dev/null || \
            curl -sf --max-time 5 https://ifconfig.me 2>/dev/null || \
            echo "Could not detect")
info "Public IP" "$PUBLIC_IP"

# All IPs
echo "" | tee -a "$REPORT_FILE"
echo -e "  ${BOLD}All Network Interfaces:${NC}" | tee -a "$REPORT_FILE"
ip -4 addr show 2>/dev/null | grep -E "inet " | awk '{print "    " $NF ": " $2}' | tee -a "$REPORT_FILE"

# Tailscale
echo "" | tee -a "$REPORT_FILE"
echo -e "  ${BOLD}Tailscale Status:${NC}" | tee -a "$REPORT_FILE"
if command -v tailscale &>/dev/null; then
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "N/A")
    TAILSCALE_STATUS=$(tailscale status 2>/dev/null | head -5 || echo "N/A")
    info "Tailscale IP" "$TAILSCALE_IP"
    echo "    $TAILSCALE_STATUS" | tee -a "$REPORT_FILE"
elif docker ps --format '{{.Names}}' 2>/dev/null | grep -q tailscale; then
    TAILSCALE_IP=$(docker exec tailscale tailscale ip -4 2>/dev/null || echo "Running in container")
    info "Tailscale (Docker)" "$TAILSCALE_IP"
else
    warn "Tailscale not found"
fi

# DNS
echo "" | tee -a "$REPORT_FILE"
info "DNS Servers" "$(grep nameserver /etc/resolv.conf 2>/dev/null | awk '{print $2}' | tr '\n' ', ' || echo 'N/A')"

# Open Ports (listening)
echo "" | tee -a "$REPORT_FILE"
echo -e "  ${BOLD}Listening Ports:${NC}" | tee -a "$REPORT_FILE"
ss -tlnp 2>/dev/null | grep LISTEN | awk '{print "    " $4 " → " $6}' | head -30 | tee -a "$REPORT_FILE"

# ============================================================
# SECTION 4: SSH CONFIGURATION
# ============================================================
header "4. SSH CONFIGURATION"

if [ -f /etc/ssh/sshd_config ]; then
    SSH_PORT=$(grep -E "^Port " /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' || echo "22 (default)")
    SSH_ROOT_LOGIN=$(grep -E "^PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' || echo "N/A")
    SSH_PASSWORD_AUTH=$(grep -E "^PasswordAuthentication" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' || echo "N/A")
    SSH_PUBKEY_AUTH=$(grep -E "^PubkeyAuthentication" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' || echo "N/A")
    SSH_ALLOWED_USERS=$(grep -E "^AllowUsers" /etc/ssh/sshd_config 2>/dev/null | cut -d' ' -f2- || echo "N/A")
    SSH_MAX_AUTH=$(grep -E "^MaxAuthTries" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' || echo "N/A")

    info "SSH Port" "$SSH_PORT"
    info "Root Login" "$SSH_ROOT_LOGIN"
    info "Password Auth" "$SSH_PASSWORD_AUTH"
    info "PubKey Auth" "$SSH_PUBKEY_AUTH"
    info "Allowed Users" "$SSH_ALLOWED_USERS"
    info "Max Auth Tries" "$SSH_MAX_AUTH"
else
    warn "Cannot read sshd_config (need sudo)"
    echo -e "  ${YELLOW}Trying with sudo...${NC}" | tee -a "$REPORT_FILE"
    SSH_PORT=$(sudo grep -E "^Port " /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' || echo "Could not read")
    SSH_ROOT_LOGIN=$(sudo grep -E "^PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' || echo "N/A")
    SSH_PASSWORD_AUTH=$(sudo grep -E "^PasswordAuthentication" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' || echo "N/A")
    SSH_PUBKEY_AUTH=$(sudo grep -E "^PubkeyAuthentication" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' || echo "N/A")
    SSH_ALLOWED_USERS=$(sudo grep -E "^AllowUsers" /etc/ssh/sshd_config 2>/dev/null | cut -d' ' -f2- || echo "N/A")

    info "SSH Port" "$SSH_PORT"
    info "Root Login" "$SSH_ROOT_LOGIN"
    info "Password Auth" "$SSH_PASSWORD_AUTH"
    info "PubKey Auth" "$SSH_PUBKEY_AUTH"
    info "Allowed Users" "$SSH_ALLOWED_USERS"
fi

# SSH Keys
echo "" | tee -a "$REPORT_FILE"
echo -e "  ${BOLD}SSH Keys on server:${NC}" | tee -a "$REPORT_FILE"
if [ -d "$HOME/.ssh" ]; then
    ls -la "$HOME/.ssh/" 2>/dev/null | grep -E "\.(pub|pem)" | awk '{print "    " $NF " (" $5 " bytes)"}' | tee -a "$REPORT_FILE"
    AUTHORIZED_KEYS_COUNT=$(wc -l < "$HOME/.ssh/authorized_keys" 2>/dev/null || echo "0")
    info "Authorized Keys" "$AUTHORIZED_KEYS_COUNT key(s)"
else
    warn "No .ssh directory found for current user"
fi

# ============================================================
# SECTION 5: FIREWALL (UFW)
# ============================================================
header "5. FIREWALL STATUS"

if command -v ufw &>/dev/null; then
    UFW_STATUS=$(sudo ufw status 2>/dev/null || echo "Cannot check - need sudo")
    echo "  $UFW_STATUS" | head -20 | tee -a "$REPORT_FILE"

    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${BOLD}UFW Rules:${NC}" | tee -a "$REPORT_FILE"
    sudo ufw status numbered 2>/dev/null | tee -a "$REPORT_FILE" || warn "Need sudo for UFW rules"
else
    warn "UFW is not installed"
fi

# iptables summary
echo "" | tee -a "$REPORT_FILE"
echo -e "  ${BOLD}iptables summary (INPUT chain):${NC}" | tee -a "$REPORT_FILE"
sudo iptables -L INPUT -n --line-numbers 2>/dev/null | head -15 | tee -a "$REPORT_FILE" || warn "Need sudo for iptables"

# ============================================================
# SECTION 6: DOCKER
# ============================================================
header "6. DOCKER ENVIRONMENT"

if command -v docker &>/dev/null; then
    DOCKER_VERSION=$(docker --version 2>/dev/null || echo "N/A")
    DOCKER_COMPOSE_VERSION=$(docker compose version 2>/dev/null || docker-compose --version 2>/dev/null || echo "N/A")
    DOCKER_IMAGES=$(docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" 2>/dev/null | tail -n +2 | wc -l)
    DOCKER_CONTAINERS_RUNNING=$(docker ps -q 2>/dev/null | wc -l)
    DOCKER_CONTAINERS_ALL=$(docker ps -aq 2>/dev/null | wc -l)
    DOCKER_VOLUMES=$(docker volume ls -q 2>/dev/null | wc -l)
    DOCKER_NETWORKS=$(docker network ls -q 2>/dev/null | wc -l)

    info "Docker Version" "$DOCKER_VERSION"
    info "Compose Version" "$DOCKER_COMPOSE_VERSION"
    info "Running Containers" "$DOCKER_CONTAINERS_RUNNING"
    info "Total Containers" "$DOCKER_CONTAINERS_ALL"
    info "Images" "$DOCKER_IMAGES"
    info "Volumes" "$DOCKER_VOLUMES"
    info "Networks" "$DOCKER_NETWORKS"

    # Docker Disk Usage
    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${BOLD}Docker Disk Usage:${NC}" | tee -a "$REPORT_FILE"
    docker system df 2>/dev/null | tee -a "$REPORT_FILE"

    # Running Containers Details
    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${BOLD}Running Containers (Name → Image → Status → Memory):${NC}" | tee -a "$REPORT_FILE"
    docker stats --no-stream --format "    {{.Name}}: {{.MemUsage}} (CPU: {{.CPUPerc}})" 2>/dev/null | sort | tee -a "$REPORT_FILE"

    # Container List
    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${BOLD}All Containers:${NC}" | tee -a "$REPORT_FILE"
    docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null | tee -a "$REPORT_FILE"

    # Docker Networks
    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${BOLD}Docker Networks:${NC}" | tee -a "$REPORT_FILE"
    docker network ls --format "    {{.Name}} ({{.Driver}})" 2>/dev/null | tee -a "$REPORT_FILE"

    # Docker Compose Projects
    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${BOLD}Docker Compose files found:${NC}" | tee -a "$REPORT_FILE"
    find /home /root /opt -name "docker-compose.yml" -o -name "docker-compose.yaml" -o -name "compose.yml" -o -name "compose.yaml" 2>/dev/null | while read f; do
        echo "    $f" | tee -a "$REPORT_FILE"
    done

    # Docker daemon config
    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${BOLD}Docker Daemon Config:${NC}" | tee -a "$REPORT_FILE"
    if [ -f /etc/docker/daemon.json ]; then
        cat /etc/docker/daemon.json 2>/dev/null | tee -a "$REPORT_FILE"
    else
        echo "    No custom daemon.json" | tee -a "$REPORT_FILE"
    fi
else
    warn "Docker is NOT installed"
fi

# ============================================================
# SECTION 7: KUBERNETES (K3s)
# ============================================================
header "7. KUBERNETES (K3s)"

if command -v kubectl &>/dev/null || command -v k3s &>/dev/null; then
    K3S_VERSION=$(k3s --version 2>/dev/null | head -1 || echo "N/A")
    info "K3s Version" "$K3S_VERSION"

    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${BOLD}Nodes:${NC}" | tee -a "$REPORT_FILE"
    kubectl get nodes -o wide 2>/dev/null | tee -a "$REPORT_FILE" || \
    sudo k3s kubectl get nodes -o wide 2>/dev/null | tee -a "$REPORT_FILE" || \
    warn "Cannot access kubectl"

    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${BOLD}Namespaces:${NC}" | tee -a "$REPORT_FILE"
    kubectl get namespaces 2>/dev/null | tee -a "$REPORT_FILE" || \
    sudo k3s kubectl get namespaces 2>/dev/null | tee -a "$REPORT_FILE" || true

    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${BOLD}All Pods (all namespaces):${NC}" | tee -a "$REPORT_FILE"
    kubectl get pods -A -o wide 2>/dev/null | tee -a "$REPORT_FILE" || \
    sudo k3s kubectl get pods -A -o wide 2>/dev/null | tee -a "$REPORT_FILE" || true

    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${BOLD}All Services (all namespaces):${NC}" | tee -a "$REPORT_FILE"
    kubectl get svc -A 2>/dev/null | tee -a "$REPORT_FILE" || \
    sudo k3s kubectl get svc -A 2>/dev/null | tee -a "$REPORT_FILE" || true

    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${BOLD}K3s Disabled Components:${NC}" | tee -a "$REPORT_FILE"
    if [ -f /etc/systemd/system/k3s.service ]; then
        grep -E "disable|no-deploy" /etc/systemd/system/k3s.service 2>/dev/null | tee -a "$REPORT_FILE" || echo "    Default config" | tee -a "$REPORT_FILE"
    fi
    cat /etc/rancher/k3s/config.yaml 2>/dev/null | tee -a "$REPORT_FILE" || \
    sudo cat /etc/rancher/k3s/config.yaml 2>/dev/null | tee -a "$REPORT_FILE" || \
    echo "    No custom config.yaml" | tee -a "$REPORT_FILE"

    # Helm
    echo "" | tee -a "$REPORT_FILE"
    if command -v helm &>/dev/null; then
        info "Helm Version" "$(helm version --short 2>/dev/null || echo 'N/A')"
        echo -e "  ${BOLD}Helm Releases:${NC}" | tee -a "$REPORT_FILE"
        helm list -A 2>/dev/null | tee -a "$REPORT_FILE" || true
    else
        warn "Helm is not installed"
    fi
else
    warn "K3s / kubectl is NOT installed"
fi

# ============================================================
# SECTION 8: SECURITY TOOLS
# ============================================================
header "8. SECURITY TOOLS"

info "CrowdSec" "$(cmd_check crowdsec)"
info "Fail2Ban" "$(cmd_check fail2ban-client)"
info "ClamAV" "$(cmd_check clamscan)"
info "AppArmor" "$(cmd_check apparmor_status)"
info "rkhunter" "$(cmd_check rkhunter)"
info "Lynis" "$(cmd_check lynis)"

# CrowdSec details
if command -v cscli &>/dev/null; then
    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${BOLD}CrowdSec Bouncers:${NC}" | tee -a "$REPORT_FILE"
    sudo cscli bouncers list 2>/dev/null | tee -a "$REPORT_FILE" || true
    echo -e "  ${BOLD}CrowdSec Collections:${NC}" | tee -a "$REPORT_FILE"
    sudo cscli collections list 2>/dev/null | head -20 | tee -a "$REPORT_FILE" || true
fi

# Fail2Ban details
if command -v fail2ban-client &>/dev/null; then
    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${BOLD}Fail2Ban Jails:${NC}" | tee -a "$REPORT_FILE"
    sudo fail2ban-client status 2>/dev/null | tee -a "$REPORT_FILE" || true
fi

# ============================================================
# SECTION 9: INSTALLED TOOLS & VERSIONS
# ============================================================
header "9. INSTALLED DEVOPS TOOLS"

info "Git" "$(git --version 2>/dev/null || echo 'NOT installed')"
info "Ansible" "$(ansible --version 2>/dev/null | head -1 || echo 'NOT installed')"
info "Terraform" "$(terraform --version 2>/dev/null | head -1 || echo 'NOT installed')"
info "Python3" "$(python3 --version 2>/dev/null || echo 'NOT installed')"
info "pip3" "$(pip3 --version 2>/dev/null | awk '{print $1, $2}' || echo 'NOT installed')"
info "Node.js" "$(node --version 2>/dev/null || echo 'NOT installed')"
info "npm" "$(npm --version 2>/dev/null || echo 'NOT installed')"
info "curl" "$(curl --version 2>/dev/null | head -1 || echo 'NOT installed')"
info "wget" "$(wget --version 2>/dev/null | head -1 || echo 'NOT installed')"
info "jq" "$(jq --version 2>/dev/null || echo 'NOT installed')"
info "htop" "$(cmd_check htop)"
info "tmux" "$(cmd_check tmux)"
info "rclone" "$(rclone --version 2>/dev/null | head -1 || echo 'NOT installed')"
info "restic" "$(restic version 2>/dev/null || echo 'NOT installed')"

# ============================================================
# SECTION 10: CLOUDFLARE TUNNEL
# ============================================================
header "10. CLOUDFLARE TUNNEL"

if docker ps --format '{{.Names}}' 2>/dev/null | grep -q cloudflare; then
    info "Cloudflare Tunnel" "Running in Docker"
    CF_CONTAINER=$(docker ps --format '{{.Names}}' 2>/dev/null | grep cloudflare | head -1)
    info "Container Name" "$CF_CONTAINER"
    info "Container Status" "$(docker inspect --format='{{.State.Status}}' "$CF_CONTAINER" 2>/dev/null || echo 'N/A')"
    info "Container Uptime" "$(docker inspect --format='{{.State.StartedAt}}' "$CF_CONTAINER" 2>/dev/null || echo 'N/A')"
else
    warn "Cloudflare tunnel container not found"
fi

# ============================================================
# SECTION 11: TRAEFIK CONFIGURATION
# ============================================================
header "11. TRAEFIK REVERSE PROXY"

if docker ps --format '{{.Names}}' 2>/dev/null | grep -q traefik; then
    info "Traefik" "Running in Docker"

    # Traefik labels/routes
    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${BOLD}Traefik Routes (from container labels):${NC}" | tee -a "$REPORT_FILE"
    docker inspect $(docker ps -q) 2>/dev/null | \
        jq -r '.[] | select(.Config.Labels["traefik.enable"] == "true") |
        "    \(.Name | ltrimstr("/")): \(.Config.Labels["traefik.http.routers." + (.Name | ltrimstr("/")) + ".rule"] // "custom-rule")"' 2>/dev/null | \
        sort | tee -a "$REPORT_FILE" || \
    docker ps --format '{{.Names}}' 2>/dev/null | while read name; do
        RULE=$(docker inspect "$name" 2>/dev/null | grep -o 'Host(`[^`]*`)' | head -1)
        if [ -n "$RULE" ]; then
            echo "    $name → $RULE" | tee -a "$REPORT_FILE"
        fi
    done

    # Dynamic config
    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${BOLD}Traefik Dynamic Config:${NC}" | tee -a "$REPORT_FILE"
    TRAEFIK_DYNAMIC=$(find /home /root /opt -path "*/traefik_dynamic/*" -name "*.yml" -o -name "*.yaml" -o -name "*.toml" 2>/dev/null)
    if [ -n "$TRAEFIK_DYNAMIC" ]; then
        echo "$TRAEFIK_DYNAMIC" | while read f; do
            echo "    File: $f" | tee -a "$REPORT_FILE"
            cat "$f" 2>/dev/null | sed 's/^/      /' | tee -a "$REPORT_FILE"
        done
    else
        echo "    No dynamic config files found" | tee -a "$REPORT_FILE"
    fi
else
    warn "Traefik container not found"
fi

# ============================================================
# SECTION 12: DOMAIN & SSL
# ============================================================
header "12. DOMAIN & SSL"

# Try to find domain from env files
echo -e "  ${BOLD}Domain Names Found:${NC}" | tee -a "$REPORT_FILE"
find /home /root /opt -name ".env" -not -path "*/node_modules/*" 2>/dev/null | while read envfile; do
    DOMAIN=$(grep -E "^DOMAIN_NAME=" "$envfile" 2>/dev/null | cut -d'=' -f2 | tr -d '"' | tr -d "'")
    if [ -n "$DOMAIN" ]; then
        echo "    $envfile → DOMAIN_NAME=$DOMAIN" | tee -a "$REPORT_FILE"
    fi
done

# SSL certs
echo "" | tee -a "$REPORT_FILE"
echo -e "  ${BOLD}SSL Certificates:${NC}" | tee -a "$REPORT_FILE"
if [ -d /etc/letsencrypt/live ]; then
    ls /etc/letsencrypt/live/ 2>/dev/null | while read domain; do
        EXPIRY=$(openssl x509 -enddate -noout -in "/etc/letsencrypt/live/$domain/fullchain.pem" 2>/dev/null | cut -d= -f2)
        echo "    $domain → Expires: ${EXPIRY:-N/A}" | tee -a "$REPORT_FILE"
    done
else
    echo "    SSL managed by Cloudflare (no local certs)" | tee -a "$REPORT_FILE"
fi

# ============================================================
# SECTION 13: CRON JOBS & SCHEDULED TASKS
# ============================================================
header "13. CRON JOBS & SCHEDULED TASKS"

echo -e "  ${BOLD}Current User Crontab:${NC}" | tee -a "$REPORT_FILE"
crontab -l 2>/dev/null | tee -a "$REPORT_FILE" || echo "    No crontab" | tee -a "$REPORT_FILE"

echo "" | tee -a "$REPORT_FILE"
echo -e "  ${BOLD}Root Crontab:${NC}" | tee -a "$REPORT_FILE"
sudo crontab -l 2>/dev/null | tee -a "$REPORT_FILE" || echo "    Cannot access (need sudo)" | tee -a "$REPORT_FILE"

echo "" | tee -a "$REPORT_FILE"
echo -e "  ${BOLD}Systemd Timers:${NC}" | tee -a "$REPORT_FILE"
systemctl list-timers --no-pager 2>/dev/null | head -15 | tee -a "$REPORT_FILE"

# ============================================================
# SECTION 14: DOCKER COMPOSE ENV VARIABLES (SANITIZED)
# ============================================================
header "14. DOCKER COMPOSE ENV (SANITIZED — NO SECRETS)"

find /home /root /opt -name ".env" -not -path "*/node_modules/*" 2>/dev/null | while read envfile; do
    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${BOLD}File: $envfile${NC}" | tee -a "$REPORT_FILE"
    # Show variable NAMES only, mask values of sensitive keys
    cat "$envfile" 2>/dev/null | grep -v "^#" | grep -v "^$" | while read line; do
        KEY=$(echo "$line" | cut -d'=' -f1)
        # Mask sensitive values
        if echo "$KEY" | grep -qiE "password|secret|token|key|auth|api_key|tunnel"; then
            echo "    $KEY=********" | tee -a "$REPORT_FILE"
        else
            echo "    $line" | tee -a "$REPORT_FILE"
        fi
    done
done

# ============================================================
# SECTION 15: AVAILABLE RESOURCES FOR NEW PROJECT
# ============================================================
header "15. RESOURCE ASSESSMENT FOR NEW PROJECT"

echo -e "  ${BOLD}Can this server handle the infra-full-stack project?${NC}" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

# RAM Assessment
RAM_AVAIL_MB=$(free -m | awk '/^Mem:/ {print $7}')
if [ "$RAM_AVAIL_MB" -gt 2048 ]; then
    echo -e "  ${GREEN}✔${NC} RAM: ${RAM_AVAIL_MB}MB available — Enough for lightweight K8s workloads" | tee -a "$REPORT_FILE"
elif [ "$RAM_AVAIL_MB" -gt 1024 ]; then
    echo -e "  ${YELLOW}⚠${NC} RAM: ${RAM_AVAIL_MB}MB available — Tight, recommend separate server" | tee -a "$REPORT_FILE"
else
    echo -e "  ${RED}✘${NC} RAM: ${RAM_AVAIL_MB}MB available — NOT enough, need separate server" | tee -a "$REPORT_FILE"
fi

# Disk Assessment
DISK_AVAIL_GB=$(df / | awk 'NR==2 {print int($4/1024/1024)}')
if [ "$DISK_AVAIL_GB" -gt 30 ]; then
    echo -e "  ${GREEN}✔${NC} Disk: ${DISK_AVAIL_GB}GB available — Sufficient" | tee -a "$REPORT_FILE"
elif [ "$DISK_AVAIL_GB" -gt 15 ]; then
    echo -e "  ${YELLOW}⚠${NC} Disk: ${DISK_AVAIL_GB}GB available — Getting tight" | tee -a "$REPORT_FILE"
else
    echo -e "  ${RED}✘${NC} Disk: ${DISK_AVAIL_GB}GB available — Low, cleanup needed" | tee -a "$REPORT_FILE"
fi

# CPU Assessment
CPU_LOAD=$(awk '{printf "%.0f", $1 * 100}' /proc/loadavg)
CPU_THRESHOLD=$((CPU_CORES * 70))
if [ "$CPU_LOAD" -lt "$CPU_THRESHOLD" ]; then
    echo -e "  ${GREEN}✔${NC} CPU: Load is manageable" | tee -a "$REPORT_FILE"
else
    echo -e "  ${YELLOW}⚠${NC} CPU: High load detected" | tee -a "$REPORT_FILE"
fi

echo "" | tee -a "$REPORT_FILE"

# Recommendation
echo -e "  ${BOLD}${CYAN}═══ RECOMMENDATION ═══${NC}" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

if [ "$RAM_AVAIL_MB" -lt 1500 ]; then
    echo -e "  ${YELLOW}OPTION A (Recommended):${NC}" | tee -a "$REPORT_FILE"
    echo "    Use a SEPARATE cheap cloud server" | tee -a "$REPORT_FILE"
    echo "    This keeps your production apps safe and isolated" | tee -a "$REPORT_FILE"
    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${YELLOW}OPTION B (Free):${NC}" | tee -a "$REPORT_FILE"
    echo "    Use a dedicated K3s NAMESPACE on this server" | tee -a "$REPORT_FILE"
    echo "    Lightweight Flask app + minimal monitoring" | tee -a "$REPORT_FILE"
    echo "    Risk: May affect existing apps if resources spike" | tee -a "$REPORT_FILE"
    echo "" | tee -a "$REPORT_FILE"
    echo -e "  ${YELLOW}OPTION C (Local):${NC}" | tee -a "$REPORT_FILE"
    echo "    Use Minikube or Kind on your local machine" | tee -a "$REPORT_FILE"
    echo "    Free but no public access for demo" | tee -a "$REPORT_FILE"
else
    echo -e "  ${GREEN}You have enough resources to run on this server${NC}" | tee -a "$REPORT_FILE"
    echo "    Using a dedicated K3s namespace is recommended" | tee -a "$REPORT_FILE"
fi

# ============================================================
# SECTION 16: GENERATE JSON SUMMARY
# ============================================================
header "16. GENERATING JSON SUMMARY"

cat > "$REPORT_JSON" << JSONEOF
{
  "collection_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "system": {
    "hostname": "$(hostname)",
    "os": "$(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2)",
    "kernel": "$(uname -r)",
    "arch": "$(uname -m)",
    "timezone": "$(timedatectl show --property=Timezone --value 2>/dev/null || echo 'N/A')",
    "uptime": "$(uptime -p 2>/dev/null || echo 'N/A')"
  },
  "hardware": {
    "cpu_model": "$CPU_MODEL",
    "cpu_cores": $CPU_CORES,
    "ram_total_mb": $(free -m | awk '/^Mem:/ {print $2}'),
    "ram_used_mb": $(free -m | awk '/^Mem:/ {print $3}'),
    "ram_available_mb": $RAM_AVAIL_MB,
    "swap_total_mb": $(free -m | awk '/^Swap:/ {print $2}'),
    "disk_total_gb": $(df / | awk 'NR==2 {print int($2/1024/1024)}'),
    "disk_used_gb": $(df / | awk 'NR==2 {print int($3/1024/1024)}'),
    "disk_available_gb": $DISK_AVAIL_GB
  },
  "network": {
    "public_ip": "$PUBLIC_IP",
    "tailscale_ip": "${TAILSCALE_IP:-N/A}",
    "ssh_port": "${SSH_PORT:-N/A}"
  },
  "ssh": {
    "port": "${SSH_PORT:-22}",
    "root_login": "${SSH_ROOT_LOGIN:-N/A}",
    "password_auth": "${SSH_PASSWORD_AUTH:-N/A}",
    "pubkey_auth": "${SSH_PUBKEY_AUTH:-N/A}",
    "allowed_users": "${SSH_ALLOWED_USERS:-N/A}"
  },
  "docker": {
    "version": "$(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',' || echo 'N/A')",
    "running_containers": ${DOCKER_CONTAINERS_RUNNING:-0},
    "total_containers": ${DOCKER_CONTAINERS_ALL:-0},
    "images": ${DOCKER_IMAGES:-0},
    "containers": [
$(docker ps --format '"      {\"name\": \"{{.Names}}\", \"image\": \"{{.Image}}\", \"status\": \"{{.Status}}\"}"' 2>/dev/null | paste -sd ',' | sed 's/^/      /' || echo '      ')
    ]
  },
  "kubernetes": {
    "k3s_installed": $(command -v k3s &>/dev/null && echo "true" || echo "false"),
    "k3s_version": "$(k3s --version 2>/dev/null | awk '{print $3}' || echo 'N/A')"
  },
  "security": {
    "ufw": "$(sudo ufw status 2>/dev/null | head -1 || echo 'N/A')",
    "crowdsec": "$(cmd_check crowdsec)",
    "fail2ban": "$(cmd_check fail2ban-client)",
    "clamav": "$(cmd_check clamscan)"
  },
  "tools": {
    "git": "$(git --version 2>/dev/null | awk '{print $3}' || echo 'N/A')",
    "ansible": "$(ansible --version 2>/dev/null | head -1 | awk '{print $NF}' | tr -d '[]' || echo 'N/A')",
    "terraform": "$(terraform --version 2>/dev/null | head -1 | awk '{print $2}' || echo 'N/A')",
    "helm": "$(helm version --short 2>/dev/null || echo 'N/A')",
    "python3": "$(python3 --version 2>/dev/null | awk '{print $2}' || echo 'N/A')"
  },
  "recommendation": {
    "can_run_on_same_server": $([ "$RAM_AVAIL_MB" -gt 2048 ] && echo "true" || echo "false"),
    "ram_available_mb": $RAM_AVAIL_MB,
    "disk_available_gb": $DISK_AVAIL_GB,
    "suggested_option": "$([ "$RAM_AVAIL_MB" -gt 2048 ] && echo 'same_server_namespace' || echo 'separate_cloud_server')"
  }
}
JSONEOF

info "JSON report saved" "$REPORT_JSON"

# ============================================================
# FINAL SUMMARY
# ============================================================
echo "" | tee -a "$REPORT_FILE"
echo -e "${CYAN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║     ✅ Collection Complete!                                ║"
echo "║                                                           ║"
echo "╠═══════════════════════════════════════════════════════════╣"
echo "║                                                           ║"
echo "║  📄 Full Report: $REPORT_FILE"
echo "║  📊 JSON Report: $REPORT_JSON"
echo "║                                                           ║"
echo "║  📋 Next Steps:                                           ║"
echo "║     1. Review the report above                            ║"
echo "║     2. Share the JSON file                                ║"
echo "║     3. We'll customize the infra-full-stack project       ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo "" | tee -a "$REPORT_FILE"
echo "To view the report again:" | tee -a "$REPORT_FILE"
echo "  cat $REPORT_FILE" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"
echo "To share the JSON:" | tee -a "$REPORT_FILE"
echo "  cat $REPORT_JSON" | tee -a "$REPORT_FILE"
