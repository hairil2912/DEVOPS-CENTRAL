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

DASHBOARD_DIR="/var/www/devops-dashboard"
NGINX_USER="nginx"

# Create directories
mkdir -p $DASHBOARD_DIR/{backend,frontend,database,nginx,scripts}
mkdir -p $DASHBOARD_DIR/backend/storage/{logs,cache,backups}

# Copy files
if [ -d "dashboard" ]; then
    cp -r dashboard/* $DASHBOARD_DIR/
else
    echo -e "${RED}Error: Dashboard files not found${NC}"
    exit 1
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
