#!/bin/bash
# DevOps Central - Agent One-Line Installer
# Usage: curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh | bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Installing DevOps Agent...${NC}"

# Check root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: Please run as root (use sudo)${NC}"
    exit 1
fi

AGENT_DIR="/opt/devops-agent"
AGENT_USER="devops-agent"

# Create user
if ! id "$AGENT_USER" &>/dev/null; then
    useradd -r -s /bin/false $AGENT_USER
    groupadd -r $AGENT_USER 2>/dev/null || true
fi

# Download and extract (if from URL)
if [ -z "$1" ]; then
    # Assume files are in current directory
    if [ ! -d "agent" ]; then
        echo -e "${RED}Error: Agent files not found. Please run from project directory or provide URL${NC}"
        exit 1
    fi
    SOURCE_DIR="agent"
else
    # Download from URL
    echo "Downloading agent files..."
    TEMP_DIR=$(mktemp -d)
    curl -sSL "$1" | tar -xz -C $TEMP_DIR
    SOURCE_DIR="$TEMP_DIR/agent"
fi

# Install
mkdir -p $AGENT_DIR
cp -r $SOURCE_DIR/* $AGENT_DIR/ 2>/dev/null || true

# Install dependencies
if command -v pip3 &> /dev/null; then
    pip3 install -r $AGENT_DIR/requirements.txt
else
    echo "Installing pip3..."
    if command -v dnf &> /dev/null; then
        dnf install -y python3-pip
    elif command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y python3-pip
    fi
    pip3 install -r $AGENT_DIR/requirements.txt
fi

# Setup config
if [ ! -f "$AGENT_DIR/etc/config.yaml" ]; then
    cp $AGENT_DIR/etc/config.yaml.example $AGENT_DIR/etc/config.yaml
    read -p "Server name: " server_name
    read -p "Dashboard URL: " dashboard_url
    agent_id=$(python3 -c "import uuid; print(uuid.uuid4())" 2>/dev/null || cat /proc/sys/kernel/random/uuid)
    sed -i "s/name: \"\"/name: \"$server_name\"/" $AGENT_DIR/etc/config.yaml
    sed -i "s|url: \".*\"|url: \"$dashboard_url\"|" $AGENT_DIR/etc/config.yaml
    sed -i "s/id: \"\"/id: \"$agent_id\"/" $AGENT_DIR/etc/config.yaml
fi

# Setup sudo
cat > /etc/sudoers.d/devops-agent << 'EOF'
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl reload nginx
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl restart php-fpm
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl reload php-fpm
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl restart mariadb
EOF
chmod 440 /etc/sudoers.d/devops-agent

# Permissions
chown -R $AGENT_USER:$AGENT_USER $AGENT_DIR
chmod 600 $AGENT_DIR/etc/config.yaml 2>/dev/null || true
chmod +x $AGENT_DIR/bin/devops-agent 2>/dev/null || true

# Systemd
if [ -f "$AGENT_DIR/systemd/devops-agent.service" ]; then
    cp $AGENT_DIR/systemd/devops-agent.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable devops-agent
    systemctl start devops-agent
fi

echo -e "${GREEN}Agent installed!${NC}"
echo "Next: Generate token from dashboard and save to $AGENT_DIR/etc/token"
