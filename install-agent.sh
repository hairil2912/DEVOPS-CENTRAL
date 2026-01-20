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

# Check and install required tools
echo "Checking required tools..."

# Check curl
if ! command -v curl &> /dev/null; then
    echo "Installing curl..."
    if command -v dnf &> /dev/null; then
        dnf install -y curl
    elif command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y curl
    elif command -v yum &> /dev/null; then
        yum install -y curl
    else
        echo -e "${RED}Error: curl is required but cannot be auto-installed${NC}"
        exit 1
    fi
fi

# Check wget (optional, but useful)
if ! command -v wget &> /dev/null; then
    echo "Installing wget..."
    if command -v dnf &> /dev/null; then
        dnf install -y wget
    elif command -v apt-get &> /dev/null; then
        apt-get install -y wget
    elif command -v yum &> /dev/null; then
        yum install -y wget
    fi
fi

AGENT_DIR="/opt/devops-agent"
AGENT_USER="devops-agent"
REPO_URL="https://github.com/hairil2912/DEVOPS-CENTRAL"
BRANCH="master"

# Create user
if ! id "$AGENT_USER" &>/dev/null; then
    useradd -r -s /bin/false $AGENT_USER
    groupadd -r $AGENT_USER 2>/dev/null || true
fi

# Detect if running from curl or local
TEMP_DIR=""
SOURCE_DIR=""

# Check if agent directory exists locally
if [ -d "agent" ]; then
    echo "Using local agent files..."
    SOURCE_DIR="agent"
else
    # Download from GitHub using git clone (faster and more reliable)
    echo "Downloading agent files from GitHub..."
    
    # Check if git is installed
    if ! command -v git &> /dev/null; then
        echo "Installing git..."
        if command -v dnf &> /dev/null; then
            dnf install -y git
        elif command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y git
        elif command -v yum &> /dev/null; then
            yum install -y git
        else
            echo -e "${RED}Error: git is not installed and cannot be auto-installed${NC}"
            echo "Please install git manually: dnf install git (or apt-get install git)"
            exit 1
        fi
    fi
    
    TEMP_DIR=$(mktemp -d)
    cd $TEMP_DIR
    
    # Clone repository (shallow clone, only master branch)
    echo "Cloning repository..."
    if git clone --depth 1 --branch $BRANCH $REPO_URL.git temp-repo 2>/dev/null; then
        if [ -d "temp-repo/agent" ]; then
            SOURCE_DIR="temp-repo/agent"
        else
            echo -e "${RED}Error: Agent directory not found in repository${NC}"
            rm -rf $TEMP_DIR
            exit 1
        fi
    else
        echo -e "${RED}Error: Could not clone repository from GitHub${NC}"
        echo "Please check:"
        echo "1. Repository is public or you have access"
        echo "2. Branch name is correct: $BRANCH"
        echo "3. Internet connection is working"
        echo "4. Git is properly installed"
        rm -rf $TEMP_DIR
        exit 1
    fi
fi

# Install
echo "Installing to $AGENT_DIR..."
mkdir -p $AGENT_DIR
cp -r $SOURCE_DIR/* $AGENT_DIR/ 2>/dev/null || true

# Cleanup temp dir if used
if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    cd /
    rm -rf $TEMP_DIR
fi

# Check Python version and install dependencies
echo "Checking Python version..."
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1,2)
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

PYTHON3_CMD="python3"
PIP3_CMD="pip3"
USE_PY36=false

# Check if Python 3.8+ is available
if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 8 ]); then
    echo "Python 3.6 detected. Attempting to install Python 3.8+..."
    
    if command -v dnf &> /dev/null; then
        # AlmaLinux 8 - install Python 3.8 from appstream
        if dnf module install -y python38 2>/dev/null && dnf install -y python38 python38-pip 2>/dev/null; then
            PYTHON3_CMD="python3.8"
            PIP3_CMD="pip3.8"
            echo "Python 3.8 installed successfully"
        else
            echo -e "${YELLOW}Warning: Python 3.8 installation failed. Using Python 3.6 with compatible packages...${NC}"
            USE_PY36=true
        fi
    elif command -v apt-get &> /dev/null; then
        apt-get update
        if apt-get install -y python3.8 python3.8-pip 2>/dev/null; then
            PYTHON3_CMD="python3.8"
            PIP3_CMD="pip3.8"
            echo "Python 3.8 installed successfully"
        else
            echo -e "${YELLOW}Warning: Python 3.8 installation failed. Using Python 3.6 with compatible packages...${NC}"
            USE_PY36=true
        fi
    else
        echo -e "${YELLOW}Warning: Cannot install Python 3.8. Using Python 3.6 with compatible packages...${NC}"
        USE_PY36=true
    fi
fi

# Install dependencies
if [ "$USE_PY36" = true ]; then
    # Install compatible versions for Python 3.6
    echo "Installing Python 3.6 compatible packages..."
    $PIP3_CMD install --upgrade pip
    if [ -f "$AGENT_DIR/requirements-py36.txt" ]; then
        $PIP3_CMD install -r $AGENT_DIR/requirements-py36.txt
    else
        $PIP3_CMD install "requests>=2.20.0,<2.31.0" "urllib3>=1.26.0,<2.0.0" "pyyaml>=5.0,<6.0" python-dotenv "psutil>=5.7.0,<6.0.0" "cryptography>=3.0.0,<41.0.0" python-json-logger "python-dateutil>=2.7.0,<2.8.2"
    fi
else
    # Upgrade pip first
    echo "Upgrading pip..."
    $PIP3_CMD install --upgrade pip
    
    # Install dependencies
    echo "Installing Python dependencies..."
    if [ -f "$AGENT_DIR/requirements.txt" ]; then
        $PIP3_CMD install -r $AGENT_DIR/requirements.txt
    else
        echo -e "${YELLOW}Warning: requirements.txt not found. Installing basic packages...${NC}"
        $PIP3_CMD install requests pyyaml python-dotenv psutil cryptography python-json-logger python-dateutil
    fi
fi

# Setup config
if [ ! -f "$AGENT_DIR/etc/config.yaml" ]; then
    cp $AGENT_DIR/etc/config.yaml.example $AGENT_DIR/etc/config.yaml
    read -p "Server name: " server_name
    echo ""
    echo "Dashboard URL (bisa pakai IP atau domain, HTTP atau HTTPS):"
    echo "  Contoh: https://dashboard.example.com"
    echo "  Contoh: http://192.168.1.100"
    echo "  Contoh: https://192.168.1.100"
    read -p "Dashboard URL: " dashboard_url
    
    # Auto-detect if HTTP or HTTPS
    if [[ "$dashboard_url" == http://* ]]; then
        verify_ssl="false"
        echo "Detected HTTP - SSL verification disabled"
    elif [[ "$dashboard_url" == https://* ]]; then
        # Check if IP address (simple check)
        if [[ "$dashboard_url" =~ https://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
            verify_ssl="false"
            echo "Detected HTTPS with IP - SSL verification disabled (recommended for IP)"
        else
            verify_ssl="true"
            echo "Detected HTTPS with domain - SSL verification enabled"
        fi
    else
        # No protocol specified, assume HTTP
        dashboard_url="http://$dashboard_url"
        verify_ssl="false"
        echo "No protocol specified, using HTTP"
    fi
    
    # Use the correct Python command
    agent_id=$($PYTHON3_CMD -c "import uuid; print(uuid.uuid4())" 2>/dev/null || cat /proc/sys/kernel/random/uuid)
    sed -i "s/name: \"\"/name: \"$server_name\"/" $AGENT_DIR/etc/config.yaml
    sed -i "s|url: \".*\"|url: \"$dashboard_url\"|" $AGENT_DIR/etc/config.yaml
    sed -i "s|verify_ssl: true|verify_ssl: $verify_ssl|" $AGENT_DIR/etc/config.yaml
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
