#!/bin/bash
# Install script untuk DevOps Dashboard

set -e

DASHBOARD_DIR="/var/www/devops-dashboard"
NGINX_USER="nginx"
DB_NAME="devops_dashboard"
DB_USER="devops_dashboard"

echo "=== Installing DevOps Dashboard ==="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

# Create directories
echo "Creating directories..."
mkdir -p $DASHBOARD_DIR/{backend,frontend,database,nginx,scripts,docs}
mkdir -p $DASHBOARD_DIR/backend/storage/{logs,cache,backups,sessions}

# Set permissions
echo "Setting permissions..."
chown -R $NGINX_USER:$NGINX_USER $DASHBOARD_DIR
chmod -R 755 $DASHBOARD_DIR
chmod -R 775 $DASHBOARD_DIR/backend/storage

# Install backend dependencies (PHP)
if command -v composer &> /dev/null; then
    echo "Installing PHP dependencies..."
    cd $DASHBOARD_DIR/backend
    composer install --no-dev --optimize-autoloader
else
    echo "Warning: Composer not found. Please install PHP dependencies manually."
fi

# Install frontend dependencies (Node.js)
if command -v npm &> /dev/null; then
    echo "Installing frontend dependencies..."
    cd $DASHBOARD_DIR/frontend
    npm install
    npm run build
else
    echo "Warning: npm not found. Please install frontend dependencies manually."
fi

# Setup database
echo "Setting up database..."
read -p "MySQL root password: " -s MYSQL_ROOT_PASSWORD
echo ""

mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$(openssl rand -base64 32)';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

mysql -u root -p$MYSQL_ROOT_PASSWORD $DB_NAME < $DASHBOARD_DIR/database/schema/full_schema.sql

echo "Database setup complete!"
echo "Database user: $DB_USER"
echo "Please save the generated password securely."

# Copy nginx config
echo "Setting up Nginx..."
if [ -f "$DASHBOARD_DIR/nginx/devops-dashboard.conf.example" ]; then
    cp $DASHBOARD_DIR/nginx/devops-dashboard.conf.example /etc/nginx/conf.d/devops-dashboard.conf
    echo "Nginx config copied. Please edit /etc/nginx/conf.d/devops-dashboard.conf"
fi

# Setup .env file
if [ -f "$DASHBOARD_DIR/backend/.env.example" ]; then
    cp $DASHBOARD_DIR/backend/.env.example $DASHBOARD_DIR/backend/.env
    echo ".env file created. Please edit $DASHBOARD_DIR/backend/.env"
fi

echo ""
echo "=== Installation Complete ==="
echo "Next steps:"
echo "1. Edit $DASHBOARD_DIR/backend/.env"
echo "2. Edit /etc/nginx/conf.d/devops-dashboard.conf"
echo "3. Setup SSL certificates"
echo "4. Run: systemctl reload nginx"
echo "5. Change default admin password!"
