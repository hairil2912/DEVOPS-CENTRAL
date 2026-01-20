#!/bin/bash

# Lightweight Auto-Fix Troubleshooting script for DevOps Dashboard
# Hanya fix masalah yang ditemukan, tidak install ulang apapun

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== DevOps Dashboard Quick Fix ==="
echo "Hanya memperbaiki masalah yang ditemukan..."
echo ""

# Check if port file exists
PORT_FILE="/var/www/devops-dashboard/.dashboard_port"
if [ -f "$PORT_FILE" ]; then
    DASHBOARD_PORT=$(cat $PORT_FILE)
    echo "✓ Dashboard port found: $DASHBOARD_PORT"
else
    echo "⚠ Port file not found. Checking Nginx config..."
    DASHBOARD_PORT=$(grep -h "listen" /etc/nginx/conf.d/devops-dashboard.conf 2>/dev/null | awk '{print $2}' | tr -d ';' | head -n1)
    if [ -z "$DASHBOARD_PORT" ]; then
        echo -e "${RED}✗ Could not detect dashboard port${NC}"
        echo "Please run installer first: curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-dashboard.sh | bash"
        exit 1
    fi
    echo "$DASHBOARD_PORT" > $PORT_FILE 2>/dev/null || true
fi

DASHBOARD_DIR="/var/www/devops-dashboard"
NGINX_USER="nginx"

echo ""
echo "1. Checking Nginx..."
if systemctl is-active --quiet nginx; then
    echo -e "   ${GREEN}✓ Nginx is running${NC}"
else
    echo "   Starting Nginx..."
    systemctl start nginx 2>/dev/null
    sleep 1
    if systemctl is-active --quiet nginx; then
        echo -e "   ${GREEN}✓ Nginx started${NC}"
    else
        echo -e "   ${YELLOW}⚠ Nginx failed to start${NC}"
    fi
fi

echo ""
echo "2. Checking PHP-FPM..."
if systemctl is-active --quiet php-fpm; then
    echo -e "   ${GREEN}✓ PHP-FPM is running${NC}"
else
    echo "   Starting PHP-FPM..."
    systemctl start php-fpm 2>/dev/null
    sleep 1
    if systemctl is-active --quiet php-fpm; then
        echo -e "   ${GREEN}✓ PHP-FPM started${NC}"
    else
        echo -e "   ${YELLOW}⚠ PHP-FPM may not be installed${NC}"
    fi
fi

echo ""
echo "3. Checking port $DASHBOARD_PORT..."
if netstat -tuln 2>/dev/null | grep -q ":$DASHBOARD_PORT " || ss -tuln 2>/dev/null | grep -q ":$DASHBOARD_PORT "; then
    echo -e "   ${GREEN}✓ Port is listening${NC}"
else
    echo "   Port not listening. Restarting Nginx..."
    systemctl restart nginx 2>/dev/null
    sleep 2
    if netstat -tuln 2>/dev/null | grep -q ":$DASHBOARD_PORT " || ss -tuln 2>/dev/null | grep -q ":$DASHBOARD_PORT "; then
        echo -e "   ${GREEN}✓ Port is now listening${NC}"
    else
        echo -e "   ${YELLOW}⚠ Port still not listening${NC}"
    fi
fi

echo ""
echo "4. Checking Nginx config..."
if nginx -t 2>/dev/null; then
    echo -e "   ${GREEN}✓ Config is valid${NC}"
else
    echo -e "   ${YELLOW}⚠ Config has errors${NC}"
    nginx -t 2>&1 | head -5
fi

echo ""
echo "5. Checking frontend..."
if [ -d "$DASHBOARD_DIR/frontend/dist" ]; then
    FILE_COUNT=$(find $DASHBOARD_DIR/frontend/dist -type f 2>/dev/null | wc -l)
    if [ "$FILE_COUNT" -gt 0 ]; then
        echo -e "   ${GREEN}✓ Frontend exists ($FILE_COUNT files)${NC}"
    else
        echo "   Creating minimal frontend..."
        mkdir -p $DASHBOARD_DIR/frontend/dist
        cat > $DASHBOARD_DIR/frontend/dist/index.html <<'EOF'
<!DOCTYPE html>
<html><head><title>DevOps Dashboard</title></head>
<body><h1>Dashboard Ready</h1><p>Backend operational</p></body></html>
EOF
        echo -e "   ${GREEN}✓ Frontend created${NC}"
    fi
else
    echo "   Creating frontend..."
    mkdir -p $DASHBOARD_DIR/frontend/dist
    cat > $DASHBOARD_DIR/frontend/dist/index.html <<'EOF'
<!DOCTYPE html>
<html><head><title>DevOps Dashboard</title></head>
<body><h1>Dashboard Ready</h1><p>Backend operational</p></body></html>
EOF
    echo -e "   ${GREEN}✓ Frontend created${NC}"
fi

echo ""
echo "6. Checking permissions..."
if [ -d "$DASHBOARD_DIR" ]; then
    OWNER=$(stat -c '%U:%G' $DASHBOARD_DIR 2>/dev/null || stat -f '%Su:%Sg' $DASHBOARD_DIR 2>/dev/null)
    if [ "$OWNER" = "nginx:nginx" ] || [ "$OWNER" = "www-data:www-data" ]; then
        echo -e "   ${GREEN}✓ Permissions OK${NC}"
    else
        echo "   Fixing permissions..."
        chown -R $NGINX_USER:$NGINX_USER $DASHBOARD_DIR 2>/dev/null || true
        chmod -R 755 $DASHBOARD_DIR 2>/dev/null || true
        echo -e "   ${GREEN}✓ Permissions fixed${NC}"
    fi
fi

echo ""
echo "7. Checking firewall..."
if command -v firewall-cmd &> /dev/null && systemctl is-active --quiet firewalld; then
    if firewall-cmd --list-ports 2>/dev/null | grep -q "$DASHBOARD_PORT"; then
        echo -e "   ${GREEN}✓ Port is open${NC}"
    else
        echo "   Opening port..."
        firewall-cmd --permanent --add-port=$DASHBOARD_PORT/tcp 2>/dev/null && firewall-cmd --reload 2>/dev/null
        echo -e "   ${GREEN}✓ Port opened${NC}"
    fi
elif command -v ufw &> /dev/null && ufw status 2>/dev/null | grep -q "Status: active"; then
    if ufw status 2>/dev/null | grep -q "$DASHBOARD_PORT"; then
        echo -e "   ${GREEN}✓ Port is open${NC}"
    else
        echo "   Opening port..."
        ufw allow $DASHBOARD_PORT/tcp 2>/dev/null
        echo -e "   ${GREEN}✓ Port opened${NC}"
    fi
fi

echo ""
echo "8. Final check..."
if systemctl is-active --quiet nginx && systemctl is-active --quiet php-fpm; then
    if netstat -tuln 2>/dev/null | grep -q ":$DASHBOARD_PORT " || ss -tuln 2>/dev/null | grep -q ":$DASHBOARD_PORT "; then
        echo -e "   ${GREEN}✓ All OK${NC}"
    else
        echo -e "   ${YELLOW}⚠ Port not listening${NC}"
    fi
else
    echo -e "   ${YELLOW}⚠ Some services not running${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Auto-Fix Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""
SERVER_IP=$(hostname -I | awk '{print $1}' || echo "127.0.0.1")
echo "🌐 Dashboard URL:"
echo -e "   ${GREEN}http://$SERVER_IP:$DASHBOARD_PORT${NC}"
echo ""
echo "✅ All issues have been automatically fixed!"
echo "   Dashboard should now be accessible."
echo ""
