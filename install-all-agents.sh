#!/bin/bash
# Install agent ke banyak server sekaligus
# Usage: Edit SERVERS array below, then run: bash install-all-agents.sh

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Edit list server di sini
SERVERS=(
    "192.168.1.10"
    "192.168.1.11"
    "192.168.1.12"
    # Tambahkan IP server lain di sini
)

INSTALL_SCRIPT="https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh"

echo -e "${GREEN}Installing DevOps Agent to multiple servers...${NC}"
echo ""

for server in "${SERVERS[@]}"; do
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${GREEN}Installing on: $server${NC}"
    echo -e "${YELLOW}========================================${NC}"
    
    # Check if server is reachable
    if ping -c 1 -W 2 $server &>/dev/null; then
        # Install via SSH
        ssh -o StrictHostKeyChecking=no root@$server "curl -sSL $INSTALL_SCRIPT | bash" || {
            echo -e "${RED}Failed to install on $server${NC}"
            continue
        }
        echo -e "${GREEN}✓ Successfully installed on $server${NC}"
    else
        echo -e "${RED}✗ Cannot reach $server${NC}"
    fi
    echo ""
done

echo -e "${GREEN}Installation completed!${NC}"
