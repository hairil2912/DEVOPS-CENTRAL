#!/bin/bash
# DevOps Central - Quick Install (Auto-detect)
# Usage: curl -sSL https://raw.githubusercontent.com/your-repo/devops-central/main/quick-install.sh | bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════╗
║   DevOps Central - Quick Installer        ║
╚═══════════════════════════════════════════╝
EOF
echo -e "${NC}"

[ "$EUID" -ne 0 ] && { echo "Please run as root"; exit 1; }

# Auto-detect: Agent or Dashboard?
if [ -d "/var/www/devops-dashboard" ] || [ -d "dashboard" ]; then
    echo -e "${GREEN}Detected: Installing Dashboard${NC}"
    bash install-dashboard.sh
elif [ -d "/opt/devops-agent" ] || [ -d "agent" ]; then
    echo -e "${GREEN}Detected: Installing Agent${NC}"
    bash install-agent.sh
else
    echo -e "${YELLOW}No detection. Running interactive installer...${NC}"
    bash install.sh
fi
