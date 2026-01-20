# Panduan Instalasi DevOps Central

## 📋 Prerequisites

### Untuk Agent (Client Server)
- AlmaLinux 8 / Ubuntu 20.04+ / Debian 11+
- Python 3.8+
- MariaDB 10.5.2+
- Nginx 1.22.x
- PHP 7.3.3+
- User dengan sudo access

### Untuk Dashboard (Central Server)
- AlmaLinux 8 / Ubuntu 20.04+ / Debian 11+
- Nginx 1.22.x
- PHP 7.3.3+ dengan PHP-FPM
- MariaDB 10.5.2+ / MySQL 8.0+
- Composer (untuk PHP dependencies)
- Node.js 16+ & npm (untuk frontend)
- SSL Certificate (Let's Encrypt recommended)

---

## 🤖 Instalasi Agent

### Step 1: Copy Files ke Server

```bash
# Via SCP
scp -r agent/ root@client-server:/opt/devops-agent

# Atau via Git
cd /opt
git clone <repo-url> devops-agent
cd devops-agent
```

### Step 2: Install Python Dependencies

```bash
cd /opt/devops-agent
pip3 install -r requirements.txt

# Atau menggunakan virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Step 3: Buat User untuk Agent

```bash
useradd -r -s /bin/false devops-agent
groupadd -r devops-agent
```

### Step 4: Setup Konfigurasi

```bash
# Copy template config
cp etc/config.yaml.example etc/config.yaml

# Edit konfigurasi
nano etc/config.yaml
```

Edit nilai berikut:
- `agent.name`: Nama server
- `dashboard.url`: URL dashboard central
- `dashboard.token`: Token dari dashboard (akan di-generate di dashboard)

### Step 5: Setup Sudo untuk Agent

```bash
# Edit sudoers
visudo

# Tambahkan baris berikut:
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl reload nginx
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl restart php-fpm
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl reload php-fpm
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl restart mariadb
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl status nginx
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl status php-fpm
devops-agent ALL=(ALL) NOPASSWD: /bin/systemctl status mariadb
```

### Step 6: Set Permissions

```bash
chown -R devops-agent:devops-agent /opt/devops-agent
chmod 600 etc/config.yaml
chmod +x bin/devops-agent
```

### Step 7: Install Systemd Service

```bash
cp systemd/devops-agent.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable devops-agent
systemctl start devops-agent
```

### Step 8: Verify Installation

```bash
# Check service status
systemctl status devops-agent

# Check logs
journalctl -u devops-agent -f
tail -f /opt/devops-agent/var/log/agent.log
```

---

## 🎛️ Instalasi Dashboard

### Step 1: Copy Files ke Server

```bash
# Via SCP
scp -r dashboard/ root@dashboard-server:/var/www/devops-dashboard

# Atau via Git
cd /var/www
git clone <repo-url> devops-dashboard
cd devops-dashboard
```

### Step 2: Install Backend Dependencies

```bash
cd /var/www/devops-dashboard/backend

# Install Composer jika belum ada
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Install PHP dependencies
composer install --no-dev --optimize-autoloader
```

### Step 3: Setup Database

```bash
# Login ke MySQL sebagai root
mysql -u root -p

# Buat database dan user
CREATE DATABASE devops_dashboard CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'devops_dashboard'@'localhost' IDENTIFIED BY 'strong_password_here';
GRANT ALL PRIVILEGES ON devops_dashboard.* TO 'devops_dashboard'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Import schema
mysql -u root -p devops_dashboard < database/schema/full_schema.sql
```

### Step 4: Configure Backend

```bash
cd /var/www/devops-dashboard/backend

# Copy env template
cp env.example .env

# Edit .env
nano .env
```

Edit nilai penting:
- `DB_DATABASE`: devops_dashboard
- `DB_USERNAME`: devops_dashboard
- `DB_PASSWORD`: password yang dibuat di step 3
- `APP_URL`: https://dashboard.example.com
- `APP_KEY`: Generate dengan `php artisan key:generate` (jika Laravel)

### Step 5: Install Frontend Dependencies

```bash
cd /var/www/devops-dashboard/frontend

# Install Node.js dependencies
npm install

# Build production
npm run build
```

### Step 6: Setup Nginx

```bash
# Copy nginx config
cp nginx/devops-dashboard.conf.example /etc/nginx/conf.d/devops-dashboard.conf

# Edit config
nano /etc/nginx/conf.d/devops-dashboard.conf
```

Edit:
- `server_name`: dashboard.example.com
- `ssl_certificate`: path ke SSL certificate
- `ssl_certificate_key`: path ke SSL key

### Step 7: Setup SSL (Let's Encrypt)

```bash
# Install certbot
dnf install certbot python3-certbot-nginx

# Generate certificate
certbot --nginx -d dashboard.example.com

# Auto-renewal
certbot renew --dry-run
```

### Step 8: Set Permissions

```bash
chown -R nginx:nginx /var/www/devops-dashboard
chmod -R 755 /var/www/devops-dashboard
chmod -R 775 /var/www/devops-dashboard/backend/storage
```

### Step 9: Test & Reload Nginx

```bash
# Test nginx config
nginx -t

# Reload nginx
systemctl reload nginx
```

### Step 10: Generate Agent Token

```bash
# Login ke dashboard
# Atau via CLI (jika ada)
php artisan agent:generate-token <server-name>
```

---

## ✅ Verifikasi Instalasi

### Agent
1. Check service: `systemctl status devops-agent`
2. Check logs: `journalctl -u devops-agent -f`
3. Check heartbeat di dashboard

### Dashboard
1. Akses https://dashboard.example.com
2. Login dengan default admin (ubah password!)
3. Tambahkan server baru
4. Generate token untuk agent
5. Verify agent muncul di dashboard

---

## 🔧 Troubleshooting

### Agent tidak connect ke Dashboard
- Check firewall: `firewall-cmd --list-all`
- Check network: `ping dashboard.example.com`
- Check SSL: `curl -v https://dashboard.example.com/api/v1/health`
- Check token: `cat /opt/devops-agent/etc/token`

### Dashboard tidak menerima heartbeat
- Check database connection
- Check API endpoint: `curl https://dashboard.example.com/api/v1/heartbeat`
- Check logs: `tail -f /var/www/devops-dashboard/backend/storage/logs/app.log`

### Service tidak start
- Check permissions: `ls -la /opt/devops-agent`
- Check user: `id devops-agent`
- Check systemd: `systemctl status devops-agent`
- Check logs: `journalctl -u devops-agent`

---

## 📝 Next Steps

1. **Ubah default password admin**
2. **Setup backup database**
3. **Configure alerting** (Telegram/Email)
4. **Setup monitoring** untuk dashboard sendiri
5. **Review security** settings
6. **Document custom configurations**

---

## 🔒 Security Checklist

- [ ] SSL certificate installed & valid
- [ ] Default admin password changed
- [ ] Database password strong
- [ ] Firewall configured
- [ ] Agent token encrypted
- [ ] File permissions correct
- [ ] Sudo access limited
- [ ] Log rotation configured
- [ ] Backup strategy in place
