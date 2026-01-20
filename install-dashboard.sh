#!/bin/bash
# DevOps Central - Dashboard One-Line Installer
# Usage: curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-dashboard.sh | bash

set -e
# Allow some commands to fail without stopping script
set +e  # Temporarily disable exit on error for MariaDB install

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

# Check and install PHP, Nginx, MariaDB if not installed
echo "Checking web stack..."

# Check PHP
if ! command -v php &> /dev/null; then
    echo "PHP not found. Installing PHP 7.3..."
    if command -v dnf &> /dev/null; then
        dnf install -y https://rpms.remirepo.net/enterprise/remi-release-8.rpm
        dnf module reset php -y
        dnf module enable php:remi-7.3 -y
        dnf install -y php php-fpm php-mysqlnd php-cli php-common php-gd php-mbstring php-opcache php-pdo php-xml php-json php-zip php-curl
        systemctl enable php-fpm
        systemctl start php-fpm
    elif command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y php7.3 php7.3-fpm php7.3-mysql php7.3-cli php7.3-common php7.3-gd php7.3-mbstring php7.3-xml php7.3-curl php7.3-zip
        systemctl enable php7.3-fpm
        systemctl start php7.3-fpm
    fi
else
    echo "PHP already installed: $(php -v | head -n 1)"
fi

# Check Nginx
if ! command -v nginx &> /dev/null; then
    echo "Nginx not found. Installing Nginx..."
    if command -v dnf &> /dev/null; then
        cat > /etc/yum.repos.d/nginx.repo <<'EOF'
[nginx-stable]
name=nginx stable repo
baseurl=https://nginx.org/packages/centos/8/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
EOF
        dnf install -y nginx
        systemctl enable nginx
        systemctl start nginx
    elif command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y nginx
        systemctl enable nginx
        systemctl start nginx
    fi
else
    echo "Nginx already installed: $(nginx -v 2>&1)"
fi

# Check MariaDB/MySQL
if ! command -v mysql &> /dev/null && ! command -v mariadb &> /dev/null; then
    echo "MariaDB/MySQL not found. Installing MariaDB 10.5.5..."
    if command -v dnf &> /dev/null; then
        # Install MariaDB 10.5.5 from official repository
        echo "Setting up MariaDB 10.5.5 repository..."
        cat > /etc/yum.repos.d/MariaDB.repo <<'EOF'
[mariadb]
name = MariaDB
baseurl = https://archive.mariadb.org/mariadb-10.5.5/yum/centos8-amd64
gpgkey=https://archive.mariadb.org/PublicKey
gpgcheck=1
EOF
        # Try install with uppercase (official repo)
        echo "Installing MariaDB 10.5.5..."
        if dnf install -y MariaDB-server MariaDB-client 2>/dev/null; then
            echo "MariaDB 10.5.5 installed from official repository"
        else
            # Fallback to default repo if official repo fails
            echo -e "${YELLOW}Official MariaDB repo failed. Trying default repository...${NC}"
            rm -f /etc/yum.repos.d/MariaDB.repo
            if dnf install -y mariadb-server mariadb; then
                echo "MariaDB installed from default repository (version may differ)"
            else
                echo -e "${YELLOW}Warning: MariaDB installation failed. Continuing anyway...${NC}"
                echo "You can install MariaDB manually later"
            fi
        fi
        systemctl enable mariadb
        systemctl start mariadb
    elif command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y mariadb-server mariadb-client
        systemctl enable mariadb
        systemctl start mariadb
    fi
else
    echo "MariaDB/MySQL already installed: $(mysql --version 2>/dev/null || mariadb --version 2>/dev/null)"
fi

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
    echo "Downloading dashboard files from GitHub (this may take 1-2 minutes)..."
    echo "Please wait..."
    if git clone --depth 1 --branch $BRANCH --single-branch --quiet --progress $REPO_URL.git temp-repo 2>&1; then
        echo "✓ Files downloaded successfully"
    else
        echo -e "${YELLOW}Retrying download...${NC}"
        git clone --depth 1 --branch $BRANCH --single-branch --quiet $REPO_URL.git temp-repo
    fi
    
    if [ -d "temp-repo" ]; then
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
    echo "Composer already installed"
    cd $DASHBOARD_DIR/backend
    if [ -f "composer.json" ]; then
        echo "Installing PHP dependencies (this may take a moment)..."
        composer install --no-dev --optimize-autoloader --no-interaction --quiet 2>/dev/null || echo "Composer install skipped (no dependencies)"
    else
        echo "No composer.json found, skipping PHP dependencies"
    fi
else
    echo "Installing Composer (downloading ~2MB, please wait)..."
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php --quiet --install-dir=/tmp
    mv /tmp/composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
    rm -f composer-setup.php
    echo "✓ Composer installed"
    
    cd $DASHBOARD_DIR/backend
    if [ -f "composer.json" ]; then
        echo "Installing PHP dependencies (this may take a moment)..."
        composer install --no-dev --optimize-autoloader --no-interaction --quiet 2>/dev/null || echo "Composer install skipped"
    else
        echo "No composer.json found, skipping PHP dependencies"
    fi
fi

# Install Node.js dependencies
if command -v npm &> /dev/null; then
    cd $DASHBOARD_DIR/frontend
    if [ -f "package.json" ]; then
        echo "Installing Node.js dependencies (this may take 2-3 minutes)..."
        npm install --silent --no-progress 2>/dev/null || echo "npm install skipped"
        echo "Building frontend..."
        npm run build --silent 2>/dev/null || echo "npm build skipped"
    else
        echo "No package.json found, skipping frontend build"
    fi
else
    echo -e "${YELLOW}npm not found. Skipping frontend build.${NC}"
    echo "Install Node.js manually if needed: dnf install -y nodejs npm"
fi

# Database setup - Auto setup tanpa input manual
echo ""
echo "=== Database Setup (Auto) ==="

db_name="devops_dashboard"
db_user="devops_dashboard"
db_pass=$(openssl rand -base64 32)

# Auto-detect MySQL connection method
echo "Detecting MySQL connection..."
MYSQL_CMD=""
MYSQL_CONNECTED=false

# Try 1: Connect without password (fresh install)
echo "Trying connection without password..."
if mysql -u root -e "SELECT 1;" 2>/dev/null; then
    MYSQL_CMD="mysql -u root"
    MYSQL_CONNECTED=true
    echo "✓ Connected without password (fresh install)"
# Try 2: Check if mysql_secure_installation was run (check for password)
elif mysql -u root -e "SELECT 1;" 2>&1 | grep -q "Access denied"; then
    echo "MySQL has password set. Attempting auto-setup..."
    # For fresh MariaDB install, sometimes we can still access via socket
    if mysql -u root --socket=/var/lib/mysql/mysql.sock -e "SELECT 1;" 2>/dev/null; then
        MYSQL_CMD="mysql -u root --socket=/var/lib/mysql/mysql.sock"
        MYSQL_CONNECTED=true
        echo "✓ Connected via socket"
    else
        echo -e "${YELLOW}MySQL password required. Setting up database manually...${NC}"
        echo "Please run these commands manually:"
        echo ""
        echo "mysql -u root -p <<EOF"
        echo "CREATE DATABASE IF NOT EXISTS $db_name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
        echo "CREATE USER IF NOT EXISTS '$db_user'@'localhost' IDENTIFIED BY '$db_pass';"
        echo "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost';"
        echo "FLUSH PRIVILEGES;"
        echo "EOF"
        echo ""
        echo "mysql -u root -p $db_name < $DASHBOARD_DIR/database/schema/full_schema.sql"
        echo ""
        echo -e "${YELLOW}Database password: $db_pass${NC}"
        MYSQL_CONNECTED=false
    fi
fi

# Setup database if connected
if [ "$MYSQL_CONNECTED" = true ]; then
    echo "Creating database and user..."
    $MYSQL_CMD <<EOF
CREATE DATABASE IF NOT EXISTS $db_name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$db_user'@'localhost' IDENTIFIED BY '$db_pass';
GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost';
FLUSH PRIVILEGES;
EOF

    if [ $? -eq 0 ]; then
        echo "✓ Database and user created"
        
        # Import schema
        if [ -f "$DASHBOARD_DIR/database/schema/full_schema.sql" ]; then
            echo "Importing database schema..."
            $MYSQL_CMD $db_name < $DASHBOARD_DIR/database/schema/full_schema.sql
            if [ $? -eq 0 ]; then
                echo "✓ Database schema imported"
            else
                echo -e "${YELLOW}Warning: Schema import failed, but continuing...${NC}"
            fi
        else
            echo -e "${YELLOW}Warning: Schema file not found${NC}"
        fi
        
        echo ""
        echo -e "${GREEN}Database Setup Complete!${NC}"
        echo "Database: $db_name"
        echo "User: $db_user"
        echo -e "${YELLOW}Password: $db_pass${NC}"
        echo -e "${RED}⚠️  IMPORTANT: Save this password!${NC}"
    else
        echo -e "${RED}Error creating database${NC}"
        MYSQL_CONNECTED=false
    fi
fi

# If database setup failed, save info for manual setup
if [ "$MYSQL_CONNECTED" = false ]; then
    echo ""
    echo -e "${YELLOW}Database setup will be done manually.${NC}"
    echo "Database info saved to: $DASHBOARD_DIR/database_setup_info.txt"
    cat > $DASHBOARD_DIR/database_setup_info.txt <<EOF
Database Setup Information
==========================
Database Name: $db_name
Database User: $db_user
Database Password: $db_pass

To setup manually, run:
mysql -u root -p <<SQL
CREATE DATABASE IF NOT EXISTS $db_name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$db_user'@'localhost' IDENTIFIED BY '$db_pass';
GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost';
FLUSH PRIVILEGES;
SQL

mysql -u root -p $db_name < $DASHBOARD_DIR/database/schema/full_schema.sql
EOF
    echo -e "${YELLOW}Password saved to: $DASHBOARD_DIR/database_setup_info.txt${NC}"
fi

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
