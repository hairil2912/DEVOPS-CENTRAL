# 🚀 Quick Installation Guide

DevOps Central dapat diinstall dengan **satu baris command** seperti aaPanel!

## 📦 Install Agent (Client Server)

### Option 1: Dari Git Repository (Setelah di-push ke GitHub)
```bash
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh | bash
```

**Note:** Pastikan file sudah di-push ke GitHub repository terlebih dahulu!

### Option 2: Dari Local Files (Recommended untuk testing)
```bash
# Clone repository dulu
git clone https://github.com/hairil2912/DEVOPS-CENTRAL.git
cd DEVOPS-CENTRAL

# Install agent
bash install-agent.sh
```

### Option 3: Download Manual
```bash
# Download script
wget https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh
chmod +x install-agent.sh
bash install-agent.sh
```

### Option 4: Interactive Installer
```bash
# Dari GitHub (setelah di-push)
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install.sh | bash

# Atau dari local
cd DEVOPS-CENTRAL
bash install.sh
# Pilih option 1 untuk Agent
```

---

## 🎛️ Install Dashboard (Central Server)

### Option 1: Dari Git Repository (Setelah di-push ke GitHub)
```bash
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-dashboard.sh | bash
```

**Note:** Pastikan file sudah di-push ke GitHub repository terlebih dahulu!

### Option 2: Dari Local Files (Recommended untuk testing)
```bash
# Clone repository dulu
git clone https://github.com/hairil2912/DEVOPS-CENTRAL.git
cd DEVOPS-CENTRAL

# Install dashboard
bash install-dashboard.sh
```

### Option 3: Download Manual
```bash
# Download script
wget https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-dashboard.sh
chmod +x install-dashboard.sh
bash install-dashboard.sh
```

### Option 4: Interactive Installer
```bash
# Dari GitHub (setelah di-push)
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install.sh | bash

# Atau dari local
cd DEVOPS-CENTRAL
bash install.sh
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

**Jika file sudah di-push ke GitHub:**
```bash
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh | bash
```

**Atau dari local files:**
```bash
git clone https://github.com/hairil2912/DEVOPS-CENTRAL.git
cd DEVOPS-CENTRAL
bash install-agent.sh
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

**Jika file sudah di-push ke GitHub:**
```bash
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-dashboard.sh | bash
```

**Atau dari local files:**
```bash
git clone https://github.com/hairil2912/DEVOPS-CENTRAL.git
cd DEVOPS-CENTRAL
bash install-dashboard.sh
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

## ⚠️ Important Notes

### Sebelum Menggunakan One-Line Installer dari GitHub

1. **Pastikan file sudah di-push ke GitHub:**
   ```bash
   git add install*.sh quick-install.sh
   git commit -m "Add installation scripts"
   git push origin master
   ```

2. **Verifikasi file bisa diakses:**
   ```bash
   curl -I https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh
   # Harus return HTTP 200
   ```

3. **Jika file belum di-push, gunakan instalasi dari local files (Option 2)**

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
