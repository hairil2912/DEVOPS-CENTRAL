#!/bin/bash
# DevOps Central - Dashboard One-Line Installer
# Usage: curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-dashboard.sh | bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Installing DevOps Dashboard...${NC}"

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

DASHBOARD_DIR="/var/www/devops-dashboard"
NGINX_USER="nginx"
REPO_URL="https://github.com/hairil2912/DEVOPS-CENTRAL"
BRANCH="master"

# Create directories
mkdir -p $DASHBOARD_DIR/{backend,frontend,database,nginx,scripts}
mkdir -p $DASHBOARD_DIR/backend/storage/{logs,cache,backups}

# Detect if running from curl or local
TEMP_DIR=""
SOURCE_DIR=""

# Check if dashboard directory exists locally
if [ -d "dashboard" ]; then
    echo "Using local dashboard files..."
    SOURCE_DIR="dashboard"
else
    # Download from GitHub using git clone
    echo "Downloading dashboard files from GitHub..."
    
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
        if [ -d "temp-repo/dashboard" ]; then
            SOURCE_DIR="temp-repo/dashboard"
        else
            echo -e "${RED}Error: Dashboard directory not found in repository${NC}"
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

# Copy files
cp -r $SOURCE_DIR/* $DASHBOARD_DIR/

# Cleanup temp dir if used
if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    cd /
    rm -rf $TEMP_DIR
fi

# Install PHP dependencies
if command -v composer &> /dev/null; then
    cd $DASHBOARD_DIR/backend
    composer install --no-dev --optimize-autoloader 2>/dev/null || true
else
    echo "Installing Composer..."
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    cd $DASHBOARD_DIR/backend
    composer install --no-dev --optimize-autoloader 2>/dev/null || true
fi

# Install Node.js dependencies
if command -v npm &> /dev/null; then
    cd $DASHBOARD_DIR/frontend
    npm install 2>/dev/null || true
    npm run build 2>/dev/null || true
fi

# Database setup
read -p "MySQL root password: " -s MYSQL_ROOT_PASSWORD
echo ""
db_name="devops_dashboard"
db_user="devops_dashboard"
db_pass=$(openssl rand -base64 32)

mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE DATABASE IF NOT EXISTS $db_name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$db_user'@'localhost' IDENTIFIED BY '$db_pass';
GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost';
FLUSH PRIVILEGES;
EOF

if [ -f "$DASHBOARD_DIR/database/schema/full_schema.sql" ]; then
    mysql -u root -p$MYSQL_ROOT_PASSWORD $db_name < $DASHBOARD_DIR/database/schema/full_schema.sql
fi

echo -e "${GREEN}Database: $db_name${NC}"
echo -e "${YELLOW}Password: $db_pass${NC}"

# Setup .env
if [ -f "$DASHBOARD_DIR/backend/env.example" ]; then
    cp $DASHBOARD_DIR/backend/env.example $DASHBOARD_DIR/backend/.env
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$db_pass/" $DASHBOARD_DIR/backend/.env
fi

# Permissions
chown -R $NGINX_USER:$NGINX_USER $DASHBOARD_DIR
chmod -R 775 $DASHBOARD_DIR/backend/storage

echo -e "${GREEN}Dashboard installed!${NC}"
echo "Next: Setup Nginx and SSL"
