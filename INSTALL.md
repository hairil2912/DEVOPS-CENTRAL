# ⚡ One-Line Installation - DevOps Central

Install DevOps Central dengan **satu baris command** seperti aaPanel!

---

## 🤖 Install Agent

```bash
curl -sSL https://raw.githubusercontent.com/your-org/devops-central/main/install-agent.sh | bash
```

**Atau jika sudah clone repository:**
```bash
bash install-agent.sh
```

---

## 🎛️ Install Dashboard

```bash
curl -sSL https://raw.githubusercontent.com/your-org/devops-central/main/install-dashboard.sh | bash
```

**Atau jika sudah clone repository:**
```bash
bash install-dashboard.sh
```

---

## 🎯 Interactive Installer

Pilih Agent atau Dashboard secara interaktif:

```bash
curl -sSL https://raw.githubusercontent.com/your-org/devops-central/main/install.sh | bash
```

---

## 📋 What Gets Installed?

### Agent Installation
- ✅ Python 3.8+ dependencies
- ✅ Systemd service (`devops-agent`)
- ✅ User `devops-agent` dengan sudo permissions
- ✅ Configuration files
- ✅ Auto-start service

### Dashboard Installation
- ✅ PHP dependencies (via Composer)
- ✅ Node.js dependencies (via npm)
- ✅ Database schema
- ✅ Configuration files
- ✅ File permissions setup

---

## ⚙️ Requirements

### Agent
- Python 3.8+
- pip3
- sudo access
- Internet connection (untuk download dependencies)

### Dashboard
- PHP 7.3+ dengan PHP-FPM
- Composer
- Node.js 16+ & npm
- MariaDB/MySQL
- Nginx (optional, bisa setup manual)

---

## 🔧 Post-Installation

### Agent
1. Generate token dari dashboard
2. Save token: `echo "your-token" > /opt/devops-agent/etc/token`
3. Restart: `systemctl restart devops-agent`
4. Check: `systemctl status devops-agent`

### Dashboard
1. Edit `.env`: `/var/www/devops-dashboard/backend/.env`
2. Setup Nginx config
3. Setup SSL certificate
4. Reload Nginx: `systemctl reload nginx`
5. Login dan ubah password default

---

## 🆘 Troubleshooting

### Installation fails
```bash
# Check logs
journalctl -xe

# Manual install
bash install.sh
```

### Agent tidak connect
```bash
# Check config
cat /opt/devops-agent/etc/config.yaml

# Check service
systemctl status devops-agent
journalctl -u devops-agent -f
```

### Dashboard error
```bash
# Check permissions
ls -la /var/www/devops-dashboard/backend/storage

# Check database
mysql -u root -p -e "USE devops_dashboard; SHOW TABLES;"
```

---

## 📚 More Documentation

- [Full Installation Guide](INSTALLATION_GUIDE.md)
- [Architecture](ARSITEKTUR_ANALISIS.md)
- [Project Structure](STRUKTUR_PROYEK.md)

---

**That's it! Simple as aaPanel! 🚀**
