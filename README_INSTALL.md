# 🚀 Quick Installation Guide

DevOps Central dapat diinstall dengan **satu baris command** seperti aaPanel!

## 📦 Install Agent (Client Server)

### Option 1: Dari Git Repository
```bash
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh | bash
```

### Option 2: Dari Local Files
```bash
# Clone repository dulu
git clone https://github.com/hairil2912/DEVOPS-CENTRAL.git
cd devops-central

# Install agent
bash install-agent.sh
```

### Option 3: Interactive Installer
```bash
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install.sh | bash
# Pilih option 1 untuk Agent
```

---

## 🎛️ Install Dashboard (Central Server)

### Option 1: Dari Git Repository
```bash
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-dashboard.sh | bash
```

### Option 2: Dari Local Files
```bash
# Clone repository dulu
git clone https://github.com/hairil2912/DEVOPS-CENTRAL.git
cd devops-central

# Install dashboard
bash install-dashboard.sh
```

### Option 3: Interactive Installer
```bash
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install.sh | bash
# Pilih option 2 untuk Dashboard
```

---

## 📋 Prerequisites

### Untuk Agent
- Python 3.8+
- pip3
- sudo access

### Untuk Dashboard
- PHP 7.3+ dengan PHP-FPM
- Composer
- Node.js 16+ & npm
- MariaDB/MySQL
- Nginx

---

## ⚡ Quick Start

### 1. Install Agent di Client Server
```bash
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh | bash
```

**Yang akan dilakukan:**
- ✅ Install Python dependencies
- ✅ Create user `devops-agent`
- ✅ Setup systemd service
- ✅ Configure sudo permissions
- ✅ Setup configuration file

**Setelah install:**
1. Generate token dari dashboard
2. Simpan token ke `/opt/devops-agent/etc/token`
3. Restart: `systemctl restart devops-agent`

---

### 2. Install Dashboard di Central Server
```bash
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-dashboard.sh | bash
```

**Yang akan dilakukan:**
- ✅ Install PHP dependencies (Composer)
- ✅ Install Node.js dependencies (npm)
- ✅ Create database & user
- ✅ Import database schema
- ✅ Setup configuration files
- ✅ Set file permissions

**Setelah install:**
1. Edit `/var/www/devops-dashboard/backend/.env`
2. Setup Nginx configuration
3. Setup SSL certificate
4. Reload Nginx: `systemctl reload nginx`
5. Login dan ubah password default

---

## 🔧 Manual Installation

Jika ingin install manual step-by-step, lihat [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md)

---

## 📝 Post-Installation

### Agent
```bash
# Check status
systemctl status devops-agent

# View logs
journalctl -u devops-agent -f

# Restart
systemctl restart devops-agent
```

### Dashboard
```bash
# Check Nginx
nginx -t
systemctl status nginx

# View logs
tail -f /var/www/devops-dashboard/backend/storage/logs/app.log
tail -f /var/log/nginx/devops-dashboard-error.log
```

---

## 🆘 Troubleshooting

### Agent tidak connect
```bash
# Check config
cat /opt/devops-agent/etc/config.yaml

# Check token
cat /opt/devops-agent/etc/token

# Test connection
curl -v https://your-dashboard.com/api/v1/health
```

### Dashboard error
```bash
# Check permissions
ls -la /var/www/devops-dashboard/backend/storage

# Check database
mysql -u root -p -e "USE devops_dashboard; SHOW TABLES;"

# Check PHP
php -v
php-fpm -v
```

---

## 🔒 Security Notes

1. **Ubah default password** setelah install dashboard
2. **Setup SSL** untuk production
3. **Firewall** - hanya buka port yang diperlukan
4. **Token security** - jangan expose agent token
5. **File permissions** - pastikan sesuai dengan dokumentasi

---

## 📚 Documentation

- [Full Installation Guide](INSTALLATION_GUIDE.md)
- [Architecture Analysis](ARSITEKTUR_ANALISIS.md)
- [Project Structure](STRUKTUR_PROYEK.md)
- [Agent README](agent/README.md)
- [Dashboard README](dashboard/README.md)

---

**Happy Installing! 🎉**
