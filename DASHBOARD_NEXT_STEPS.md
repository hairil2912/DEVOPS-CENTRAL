# ✅ Dashboard Installed - Next Steps

## 🎉 Instalasi Berhasil!

Dashboard sudah terinstall. Sekarang perlu setup database dan konfigurasi.

---

## ⚠️ Error Password MySQL

Jika muncul error:
```
ERROR 1045 (28000): Access denied for user 'root'@'localhost'
```

**Solusi:**

### Opsi 1: Set Password MySQL Root (Jika Belum Ada)

```bash
# Set password untuk root
mysqladmin -u root password 'your_new_password'

# Atau jika sudah ada password tapi lupa
mysql_secure_installation
```

### Opsi 2: Setup Database Manual

```bash
# Login ke MySQL
mysql -u root -p

# Atau jika belum ada password
mysql -u root

# Di dalam MySQL, jalankan:
CREATE DATABASE IF NOT EXISTS devops_dashboard CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'devops_dashboard'@'localhost' IDENTIFIED BY 'strong_password_here';
GRANT ALL PRIVILEGES ON devops_dashboard.* TO 'devops_dashboard'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Import schema
mysql -u root -p devops_dashboard < /var/www/devops-dashboard/database/schema/full_schema.sql
```

---

## 📋 Langkah Selanjutnya

### 1. Setup Database (Jika Belum)

```bash
# Set MySQL root password jika belum ada
mysql_secure_installation

# Atau set password manual
mysqladmin -u root password 'your_password'
```

### 2. Setup Database Dashboard

```bash
# Login ke MySQL
mysql -u root -p

# Buat database dan user
CREATE DATABASE devops_dashboard CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'devops_dashboard'@'localhost' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON devops_dashboard.* TO 'devops_dashboard'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Import schema
mysql -u root -p devops_dashboard < /var/www/devops-dashboard/database/schema/full_schema.sql
```

### 3. Configure .env File

```bash
# Edit .env file
nano /var/www/devops-dashboard/backend/.env
```

Update:
- `DB_DATABASE=devops_dashboard`
- `DB_USERNAME=devops_dashboard`
- `DB_PASSWORD=your_password_here`
- `APP_URL=http://your-dashboard-ip` atau domain

### 4. Setup Nginx

```bash
# Copy nginx config
cp /var/www/devops-dashboard/nginx/devops-dashboard.conf.example /etc/nginx/conf.d/devops-dashboard.conf

# Edit config
nano /etc/nginx/conf.d/devops-dashboard.conf
```

Update:
- `server_name` dengan IP atau domain
- SSL certificate paths (jika pakai HTTPS)

### 5. Test Nginx Config

```bash
# Test config
nginx -t

# Reload nginx
systemctl reload nginx
```

### 6. Setup PHP-FPM (Jika Belum)

```bash
# Check PHP-FPM config
nano /etc/php-fpm.d/www.conf

# Pastikan:
# user = nginx
# group = nginx
# listen = /run/php-fpm/www.sock

# Restart PHP-FPM
systemctl restart php-fpm
```

### 7. Set Permissions

```bash
chown -R nginx:nginx /var/www/devops-dashboard
chmod -R 755 /var/www/devops-dashboard
chmod -R 775 /var/www/devops-dashboard/backend/storage
```

### 8. Test Dashboard

```bash
# Test via browser atau curl
curl http://your-dashboard-ip

# Atau buka di browser
# http://your-dashboard-ip
```

---

## 🔧 Troubleshooting

### Database Connection Error

```bash
# Check MySQL service
systemctl status mariadb

# Check MySQL users
mysql -u root -p -e "SELECT User, Host FROM mysql.user;"

# Test connection
mysql -u devops_dashboard -p devops_dashboard
```

### Nginx Error

```bash
# Check nginx error log
tail -f /var/log/nginx/error.log

# Check nginx config
nginx -t

# Check PHP-FPM
systemctl status php-fpm
tail -f /var/log/php-fpm/error.log
```

### Permission Error

```bash
# Fix permissions
chown -R nginx:nginx /var/www/devops-dashboard
chmod -R 755 /var/www/devops-dashboard
chmod -R 775 /var/www/devops-dashboard/backend/storage
```

---

## ✅ Checklist

- [ ] MySQL root password sudah di-set
- [ ] Database `devops_dashboard` sudah dibuat
- [ ] User `devops_dashboard` sudah dibuat
- [ ] Schema sudah di-import
- [ ] `.env` file sudah dikonfigurasi
- [ ] Nginx config sudah di-setup
- [ ] PHP-FPM sudah dikonfigurasi
- [ ] File permissions sudah benar
- [ ] Dashboard bisa diakses via browser

---

## 📝 Quick Commands

```bash
# Check services
systemctl status mariadb
systemctl status nginx
systemctl status php-fpm

# Check logs
tail -f /var/log/nginx/error.log
tail -f /var/www/devops-dashboard/backend/storage/logs/app.log

# Restart services
systemctl restart mariadb
systemctl restart nginx
systemctl restart php-fpm
```

---

**Setelah semua checklist selesai, dashboard siap digunakan! 🚀**
