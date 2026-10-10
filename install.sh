#!/usr/bin/env bash
# ==============================================================================
# TigerHost Panel - Automated Installation Script (v3.2.0)
# Repository: https://github.com/are35941-oss/TigerHost
# Compatible with: Ubuntu 20.04/22.04/24.04, Debian 11/12, AlmaLinux/Rocky 9
# ==============================================================================

set -e

# Terminal Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ASCII Banner
print_banner() {
    clear
    echo -e "${YELLOW}"
    cat << "EOF"
  _____ _                 _    _           _     
 |_   _(_) __ _  ___ _ __| |  | | ___  ___| |_   
   | | | |/ _` |/ _ \ '__| |__| |/ _ \/ __| __|  
   | | | | (_| |  __/ |  |  __  | (_) \__ \ |_   
   |_| |_|\__, |\___|_|  |_|  |_|\___/|___/\__|  
          |___/                                  
    >> Next-Gen Minecraft Server Control Panel <<
    >> Official: github.com/are35941-oss/TigerHost <<
EOF
    echo -e "${NC}"
    echo -e "${CYAN}====================================================================${NC}"
    echo -e "${BOLD}   TigerHost Panel & Daemon Automated Linux Installer v3.2.0${NC}"
    echo -e "${CYAN}====================================================================${NC}
"
}

# Root check
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}[ERROR] This script must be run as root (or with sudo).${NC}"
        echo -e "Please run: ${YELLOW}sudo bash $0${NC}"
        exit 1
    fi
}

# Detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    else
        echo -e "${RED}[ERROR] Unsupported Linux distribution. /etc/os-release not found.${NC}"
        exit 1
    fi
    echo -e "${GREEN}[✓] Detected OS:${NC} $NAME $VERSION_ID"
}

# Install Prerequisites
install_dependencies() {
    echo -e "
${BLUE}[1/6] Updating system and installing base dependencies...${NC}"
    if [[ "$OS" == "ubuntu" ]] || [[ "$OS" == "debian" ]]; then
        apt-get update -y
        apt-get install -y curl wget git unzip tar certbot nginx ufw jq ca-certificates gnupg lsb-release
    elif [[ "$OS" == "almalinux" ]] || [[ "$OS" == "rocky" ]] || [[ "$OS" == "centos" ]]; then
        dnf -y update
        dnf -y install curl wget git unzip tar epel-release jq nginx certbot
    fi
    echo -e "${GREEN}[✓] System packages installed.${NC}"
}

# Install Docker & Docker Compose
install_docker() {
    echo -e "
${BLUE}[2/6] Checking and installing Docker Engine & Daemon...${NC}"
    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}[*] Installing official Docker Engine...${NC}"
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
        systemctl enable --now docker
    else
        echo -e "${GREEN}[✓] Docker already installed: $(docker --version)${NC}"
    fi

    # Install Docker Compose Plugin if missing
    if ! docker compose version &> /dev/null; then
        echo -e "${YELLOW}[*] Installing Docker Compose plugin...${NC}"
        apt-get install -y docker-compose-plugin 2>/dev/null || dnf install -y docker-compose-plugin 2>/dev/null || true
    fi
    echo -e "${GREEN}[✓] Docker container engine is active.${NC}"
}

# Install Node.js LTS
install_nodejs() {
    echo -e "
${BLUE}[3/6] Setting up Node.js 22 LTS Runtime...${NC}"
    if ! command -v node &> /dev/null || [[ $(node -v | cut -d'v' -f2 | cut -d'.' -f1) -lt 20 ]]; then
        curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
        apt-get install -y nodejs || dnf install -y nodejs
    fi
    echo -e "${GREEN}[✓] Node.js version: $(node -v), NPM version: $(npm -v)${NC}"
}

# Clone and setup TigerHost Panel
setup_tigerhost() {
    echo -e "
${BLUE}[4/6] Cloning TigerHost Panel from GitHub...${NC}"
    INSTALL_DIR="/var/www/tigerhost"
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"

    if [ -d ".git" ]; then
        echo -e "${YELLOW}[*] Existing TigerHost installation found, pulling updates...${NC}"
        git pull origin main
    else
        git clone https://github.com/are35941-oss/TigerHost.git .
    fi

    echo -e "${BLUE}[*] Installing npm dependencies & compiling frontend...${NC}"
    npm install --production=false
    npm run build

    # Generate Secure Environment variables
    echo -e "${BLUE}[*] Generating secure secrets & configuration...${NC}"
    APP_KEY=$(head -c 32 /dev/urandom | base64)
    JWT_SECRET=$(head -c 32 /dev/urandom | base64)

    cat > .env << ENVEOF
# TigerHost Panel Configuration
NODE_ENV=production
PORT=3000
APP_URL=http://localhost:3000
APP_SECRET=${APP_KEY}
JWT_SECRET=${JWT_SECRET}

# Database
DB_TYPE=sqlite
DB_FILE=/var/www/tigerhost/data/tigerhost.db

# Docker Engine Daemon
DOCKER_SOCKET=/var/run/docker.sock
DEFAULT_JAVA_VERSION=21
CRACKED_MODE_DEFAULT=true

# Public Tunnel Support
PLAYIT_ENABLED=true
ENVEOF

    mkdir -p /var/www/tigerhost/data
    mkdir -p /var/lib/tigerhost/volumes
    chmod -R 755 /var/www/tigerhost
    echo -e "${GREEN}[✓] TigerHost Panel successfully prepared.${NC}"
}

# Setup Systemd Service
setup_systemd() {
    echo -e "
${BLUE}[5/6] Registering TigerHost systemd services...${NC}"
    
    cat > /etc/systemd/system/tigerhost.service << SERVICEEOF
[Unit]
Description=TigerHost Minecraft Server Hosting Panel
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=root
WorkingDirectory=/var/www/tigerhost
ExecStart=/usr/bin/npm start
Restart=always
RestartSec=5
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
SERVICEEOF

    systemctl daemon-reload
    systemctl enable tigerhost.service
    systemctl restart tigerhost.service
    echo -e "${GREEN}[✓] TigerHost service started and enabled on boot.${NC}"
}

# Setup Firewall & Reverse Proxy
setup_network() {
    echo -e "
${BLUE}[6/6] Configuring firewall & ports...${NC}"
    if command -v ufw &> /dev/null; then
        ufw allow 80/tcp
        ufw allow 443/tcp
        ufw allow 3000/tcp
        ufw allow 25565:25600/tcp
        ufw allow 25565:25600/udp
        ufw allow 19132/udp
        echo -e "${GREEN}[✓] Firewall rules configured (Port 3000 Web, 25565-25600 Game, 19132 Bedrock).${NC}"
    fi
}

# Final Output
print_completion() {
    IP_ADDR=$(curl -s https://api.ipify.org || hostname -I | awk '{print $1}')
    echo -e "
${GREEN}====================================================================${NC}"
    echo -e "${BOLD}${GREEN}   🎉 CONGRATULATIONS! TIGERHOST PANEL IS INSTALLED & RUNNING!${NC}"
    echo -e "${GREEN}====================================================================${NC}
"
    echo -e "Access your TigerHost Panel at:"
    echo -e "  ${BOLD}${CYAN}http://${IP_ADDR}:3000${NC} or ${BOLD}${CYAN}http://localhost:3000${NC}
"
    echo -e "Default Admin Credentials:"
    echo -e "  Username: ${BOLD}admin${NC}"
    echo -e "  Password: ${BOLD}tigeradmin123${NC} (Please change upon initial login!)
"
    echo -e "Useful Commands:"
    echo -e "  - View Logs:    ${YELLOW}journalctl -u tigerhost -f${NC}"
    echo -e "  - Restart:      ${YELLOW}systemctl restart tigerhost${NC}"
    echo -e "  - Check Status: ${YELLOW}systemctl status tigerhost${NC}"
    echo -e "  - Add Playit:   ${YELLOW}curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/playit.gpg${NC}
"
    echo -e "${PURPLE}Powered by TigerHost Engine - https://github.com/are35941-oss/TigerHost${NC}
"
}

main() {
    print_banner
    check_root
    detect_os
    install_dependencies
    install_docker
    install_nodejs
    setup_tigerhost
    setup_systemd
    setup_network
    print_completion
}

main
