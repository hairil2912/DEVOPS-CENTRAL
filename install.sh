#!/bin/bash
# DevOps Central - One-Line Installer
# Usage: curl -sSL https://raw.githubusercontent.com/your-repo/devops-central/main/install.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║         DevOps Central - Server Management Panel         ║
║                                                           ║
║              One-Line Installation Script                 ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: Please run as root (use sudo)${NC}"
    exit 1
fi

# Detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    elif [ -f /etc/redhat-release ]; then
        OS="rhel"
        VERSION=$(cat /etc/redhat-release | sed 's/.*release \([0-9.]*\).*/\1/')
    else
        echo -e "${RED}Error: Unsupported OS${NC}"
        exit 1
    fi
}

# Installation menu
show_menu() {
    echo -e "${GREEN}Select installation type:${NC}"
    echo ""
    echo "1) Install Agent (Client Server)"
    echo "2) Install Dashboard (Central Server)"
    echo "3) Exit"
    echo ""
    read -p "Enter your choice [1-3]: " choice
    
    case $choice in
        1)
            install_agent
            ;;
        2)
            install_dashboard
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            exit 1
            ;;
    esac
}

# Install Agent
install_agent() {
    echo -e "${GREEN}Installing DevOps Agent...${NC}"
    
    AGENT_DIR="/opt/devops-agent"
    AGENT_USER="devops-agent"
    AGENT_GROUP="devops-agent"
    
    # Create user if not exists
    if ! id "$AGENT_USER" &>/dev/null; then
        echo "Creating user: $AGENT_USER"
        useradd -r -s /bin/false $AGENT_USER
        groupadd -r $AGENT_GROUP 2>/dev/null || true
    fi
    
    # Create directories
    echo "Creating directories..."
    mkdir -p $AGENT_DIR/{bin,etc,lib,var/{run,lib,log},systemd,tests}
    
    # Download agent files (if from git repo)
    if [ -d ".git" ] || [ -d "agent" ]; then
        echo "Copying agent files..."
        if [ -d "agent" ]; then
            cp -r agent/* $AGENT_DIR/
        fi
    else
        echo -e "${YELLOW}Warning: Agent files not found locally${NC}"
        echo "Please ensure agent files are in ./agent/ directory"
        read -p "Continue anyway? (y/n): " continue_install
        if [ "$continue_install" != "y" ]; then
            exit 1
        fi
    fi
    
    # Install Python dependencies
    echo "Installing Python dependencies..."
    if command -v pip3 &> /dev/null; then
        pip3 install -r $AGENT_DIR/requirements.txt
    else
        echo -e "${YELLOW}Warning: pip3 not found. Installing pip3...${NC}"
        detect_os
        if [ "$OS" == "centos" ] || [ "$OS" == "rhel" ] || [ "$OS" == "almalinux" ]; then
            dnf install -y python3-pip
        elif [ "$OS" == "ubuntu" ] || [ "$OS" == "debian" ]; then
            apt-get update && apt-get install -y python3-pip
        fi
        pip3 install -r $AGENT_DIR/requirements.txt
    fi
    
    # Setup configuration
    if [ ! -f "$AGENT_DIR/etc/config.yaml" ]; then
        echo "Setting up configuration..."
        cp $AGENT_DIR/etc/config.yaml.example $AGENT_DIR/etc/config.yaml 2>/dev/null || true
        
        read -p "Enter server name: " server_name
        read -p "Enter dashboard URL: " dashboard_url
        
        # Generate UUID for agent
        agent_id=$(python3 -c "import uuid; print(uuid.uuid4())" 2>/dev/null || echo $(cat /proc/sys/kernel/random/uuid))
        
        # Update config
        sed -i "s/name: \"\"/name: \"$server_name\"/" $AGENT_DIR/etc/config.yaml
        sed -i "s|url: \"https://dashboard.example.com\"|url: \"$dashboard_url\"|" $AGENT_DIR/etc/config.yaml
        sed -i "s/id: \"\"/id: \"$agent_id\"/" $AGENT_DIR/etc/config.yaml
        
        echo -e "${YELLOW}Note: You need to generate agent token from dashboard and save it to $AGENT_DIR/etc/token${NC}"
    fi
    
    # Setup sudo
    echo "Setting up sudo permissions..."
    SUDOERS_FILE="/etc/sudoers.d/devops-agent"
    cat > $SUDOERS_FILE << 'EOF'
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl reload nginx
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl restart php-fpm
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl reload php-fpm
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl restart mariadb
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl status nginx
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl status php-fpm
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl status mariadb
EOF
    chmod 440 $SUDOERS_FILE
    
    # Set permissions
    chown -R $AGENT_USER:$AGENT_GROUP $AGENT_DIR
    chmod 600 $AGENT_DIR/etc/config.yaml 2>/dev/null || true
    chmod +x $AGENT_DIR/bin/devops-agent 2>/dev/null || true
    
    # Install systemd service
    if [ -f "$AGENT_DIR/systemd/devops-agent.service" ]; then
        echo "Installing systemd service..."
        cp $AGENT_DIR/systemd/devops-agent.service /etc/systemd/system/
        systemctl daemon-reload
        systemctl enable devops-agent
        systemctl start devops-agent
    fi
    
    echo -e "${GREEN}Agent installed successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Generate token from dashboard"
    echo "2. Save token to: $AGENT_DIR/etc/token"
    echo "3. Restart agent: systemctl restart devops-agent"
    echo "4. Check status: systemctl status devops-agent"
}

# Install Dashboard
install_dashboard() {
    echo -e "${GREEN}Installing DevOps Dashboard...${NC}"
    
    DASHBOARD_DIR="/var/www/devops-dashboard"
    NGINX_USER="nginx"
    
    # Check if nginx user exists
    if ! id "$NGINX_USER" &>/dev/null; then
        echo -e "${YELLOW}Warning: User $NGINX_USER not found${NC}"
        read -p "Enter web server user (default: nginx): " web_user
        NGINX_USER=${web_user:-nginx}
    fi
    
    # Create directories
    echo "Creating directories..."
    mkdir -p $DASHBOARD_DIR/{backend,frontend,database,nginx,scripts,docs}
    mkdir -p $DASHBOARD_DIR/backend/storage/{logs,cache,backups,sessions}
    
    # Copy files if available
    if [ -d "dashboard" ]; then
        echo "Copying dashboard files..."
        cp -r dashboard/* $DASHBOARD_DIR/
    else
        echo -e "${YELLOW}Warning: Dashboard files not found locally${NC}"
    fi
    
    # Install PHP dependencies
    if command -v composer &> /dev/null; then
        echo "Installing PHP dependencies..."
        cd $DASHBOARD_DIR/backend
        composer install --no-dev --optimize-autoloader 2>/dev/null || echo "Composer install skipped (no composer.json)"
    else
        echo -e "${YELLOW}Composer not found. Installing...${NC}"
        curl -sS https://getcomposer.org/installer | php
        mv composer.phar /usr/local/bin/composer
        chmod +x /usr/local/bin/composer
        cd $DASHBOARD_DIR/backend
        composer install --no-dev --optimize-autoloader 2>/dev/null || true
    fi
    
    # Install Node.js dependencies
    if command -v npm &> /dev/null; then
        echo "Installing frontend dependencies..."
        cd $DASHBOARD_DIR/frontend
        npm install 2>/dev/null || echo "npm install skipped (no package.json)"
        npm run build 2>/dev/null || echo "npm build skipped"
    else
        echo -e "${YELLOW}npm not found. Skipping frontend build${NC}"
    fi
    
    # Setup database
    echo "Setting up database..."
    read -p "MySQL root password: " -s MYSQL_ROOT_PASSWORD
    echo ""
    read -p "Database name (default: devops_dashboard): " db_name
    db_name=${db_name:-devops_dashboard}
    read -p "Database user (default: devops_dashboard): " db_user
    db_user=${db_user:-devops_dashboard}
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
    
    echo -e "${GREEN}Database created!${NC}"
    echo "Database: $db_name"
    echo "User: $db_user"
    echo -e "${YELLOW}Password: $db_pass${NC}"
    echo "Please save this password!"
    
    # Setup .env
    if [ -f "$DASHBOARD_DIR/backend/env.example" ]; then
        cp $DASHBOARD_DIR/backend/env.example $DASHBOARD_DIR/backend/.env
        sed -i "s/DB_DATABASE=devops_dashboard/DB_DATABASE=$db_name/" $DASHBOARD_DIR/backend/.env
        sed -i "s/DB_USERNAME=devops_dashboard/DB_USERNAME=$db_user/" $DASHBOARD_DIR/backend/.env
        sed -i "s/DB_PASSWORD=change_this_password/DB_PASSWORD=$db_pass/" $DASHBOARD_DIR/backend/.env
    fi
    
    # Setup Nginx
    if [ -f "$DASHBOARD_DIR/nginx/devops-dashboard.conf.example" ]; then
        read -p "Enter domain name (e.g., dashboard.example.com): " domain_name
        cp $DASHBOARD_DIR/nginx/devops-dashboard.conf.example /etc/nginx/conf.d/devops-dashboard.conf
        sed -i "s/dashboard.example.com/$domain_name/g" /etc/nginx/conf.d/devops-dashboard.conf
        echo -e "${YELLOW}Nginx config created. Please edit /etc/nginx/conf.d/devops-dashboard.conf and setup SSL${NC}"
    fi
    
    # Set permissions
    chown -R $NGINX_USER:$NGINX_USER $DASHBOARD_DIR
    chmod -R 755 $DASHBOARD_DIR
    chmod -R 775 $DASHBOARD_DIR/backend/storage
    
    echo -e "${GREEN}Dashboard installed successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Edit $DASHBOARD_DIR/backend/.env"
    echo "2. Setup SSL certificate"
    echo "3. Edit /etc/nginx/conf.d/devops-dashboard.conf"
    echo "4. Run: nginx -t && systemctl reload nginx"
    echo "5. Change default admin password!"
}

# Main
detect_os
show_menu

echo ""
echo -e "${GREEN}Installation completed!${NC}"
