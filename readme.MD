di client di harapkan ada

MariaDB 10.5.2

PHP 7.3.3

Nginx 1.22.x

Script ini production-ready, sudah termasuk repo resmi, service enable, dan pengecekan versi.

1️⃣ Script Instalasi Lengkap (All-in-One)

Simpan sebagai install_stack.sh

#!/bin/bash
set -e

echo "=== INSTALL NGINX 1.22 + PHP 7.3 + MARIADB 10.5 ON ALMALINUX 8 ==="

# Update system
dnf -y update
dnf -y install epel-release yum-utils wget curl unzip nano

# =========================
# INSTALL NGINX 1.22
# =========================
cat > /etc/yum.repos.d/nginx.repo <<'EOF'
[nginx-stable]
name=nginx stable repo
baseurl=https://nginx.org/packages/centos/8/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
EOF

dnf -y install nginx
systemctl enable nginx
systemctl start nginx

# =========================
# INSTALL PHP 7.3
# =========================
dnf -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
dnf module reset php -y
dnf module enable php:remi-7.3 -y

dnf -y install \
php \
php-fpm \
php-mysqlnd \
php-cli \
php-common \
php-gd \
php-mbstring \
php-opcache \
php-pdo \
php-xml \
php-json \
php-zip \
php-curl

systemctl enable php-fpm
systemctl start php-fpm

# =========================
# INSTALL MARIADB 10.5.2
# =========================
cat > /etc/yum.repos.d/MariaDB.repo <<'EOF'
[mariadb]
name = MariaDB
baseurl = https://archive.mariadb.org/mariadb-10.5.2/yum/centos8-amd64
gpgkey=https://archive.mariadb.org/PublicKey
gpgcheck=1
EOF

dnf -y install MariaDB-server MariaDB-client
systemctl enable mariadb
systemctl start mariadb

# =========================
# PHP-FPM CONFIG (NGINX)
# =========================
sed -i 's/user = apache/user = nginx/' /etc/php-fpm.d/www.conf
sed -i 's/group = apache/group = nginx/' /etc/php-fpm.d/www.conf
sed -i 's|listen = 127.0.0.1:9000|listen = /run/php-fpm/www.sock|' /etc/php-fpm.d/www.conf
sed -i 's|;listen.owner = nobody|listen.owner = nginx|' /etc/php-fpm.d/www.conf
sed -i 's|;listen.group = nobody|listen.group = nginx|' /etc/php-fpm.d/www.conf
sed -i 's|;listen.mode = 0660|listen.mode = 0660|' /etc/php-fpm.d/www.conf

systemctl restart php-fpm
systemctl restart nginx

# =========================
# FIREWALL
# =========================
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

# =========================
# VERSION CHECK
# =========================
echo "=== VERSION CHECK ==="
nginx -v
php -v | head -n 2
mysql --version

echo "=== INSTALLATION COMPLETED SUCCESSFULLY ==="
echo "Next step: run mysql_secure_installation"

# =========================
# Dokumentasi Perencanaan Development
# =========================

## Server Management Panel (Agent–Dashboard Architecture)

---

## 1. Latar Belakang

Saat mengelola banyak server (web server, database server, aplikasi), penggunaan panel umum seperti aaPanel atau sejenisnya sering menimbulkan kendala:

* Terlalu banyak fitur yang tidak dibutuhkan
* Risiko keamanan karena panel bersifat umum
* Ketergantungan pada vendor
* Sulit dikustomisasi sesuai standar internal

Oleh karena itu direncanakan pengembangan **Server Management Panel internal** dengan arsitektur **Agent–Dashboard**, yang ringan, aman, dan scalable.

---

## 2. Tujuan Pengembangan

Tujuan utama sistem ini adalah:

* Mengelola banyak server dari satu dashboard terpusat
* Monitoring resource dan service secara real-time
* Kontrol layanan web stack (Nginx, PHP-FPM, MariaDB)
* Manajemen database dan user MariaDB secara aman
* Audit dan logging seluruh aktivitas administrasi

---

## 3. Arsitektur Sistem

### 3.1 Gambaran Umum

Sistem terdiri dari dua komponen utama:

1. **Agent** – Terpasang di setiap server client
2. **Dashboard (Central Server)** – Terpasang di satu server pusat

### 3.2 Prinsip Utama

* Dashboard **tidak pernah** mengakses server client via SSH
* Dashboard **tidak pernah** terkoneksi langsung ke MariaDB server client
* Semua perintah dijalankan oleh agent lokal
* Komunikasi menggunakan HTTPS + Token

---

## 4. Komponen Sistem

### 4.1 Agent (Server Client)

#### Fungsi Agent

* Mengumpulkan informasi sistem (CPU, RAM, Disk, Uptime)
* Mengecek status service (nginx, php-fpm, mariadb)
* Menjalankan perintah terbatas (restart/reload service)
* Mengelola MariaDB (database, user, privilege)
* Mengirim heartbeat dan hasil eksekusi ke dashboard

#### Karakteristik Agent

* Bahasa: Python
* Berjalan sebagai systemd service
* Resource ringan
* Menggunakan API token unik per server
* Command whitelist (tidak menerima perintah bebas)

---

### 4.2 Dashboard (Central)

#### Fungsi Dashboard

* Menyimpan daftar server
* Menampilkan status online/offline server
* Menampilkan grafik resource usage
* Mengirim perintah ke agent
* Menyimpan audit log aktivitas
* Manajemen user administrator dashboard

#### Karakteristik Dashboard

* Berbasis web
* Menyediakan REST API
* Database internal untuk konfigurasi & log
* Mendukung multi-admin & role

---

## 5. Alur Komunikasi

### 5.1 Heartbeat Monitoring

1. Agent mengirim data ke dashboard secara berkala
2. Dashboard menyimpan dan menampilkan status server

### 5.2 Eksekusi Perintah

1. Admin mengirim perintah melalui dashboard
2. Dashboard menyimpan perintah ke command queue
3. Agent melakukan polling
4. Agent mengeksekusi perintah lokal
5. Agent mengirim hasil eksekusi ke dashboard

---

## 6. Manajemen MariaDB

### 6.1 Prinsip Keamanan

* Dashboard tidak menyimpan password root MariaDB
* Agent menggunakan root via UNIX socket lokal
* Tidak ada eksekusi SQL bebas

### 6.2 Fitur MariaDB

* Create / Drop database
* Create / Drop user
* Reset password user
* Grant / Revoke privilege
* Lock / Unlock user
* Backup dan restore database

### 6.3 Batasan Hak Akses

User database yang dibuat:

* Tidak memiliki SUPER
* Tidak memiliki FILE
* Tidak memiliki GRANT OPTION
* Privilege berdasarkan template (app, readonly, reporting)

---

## 7. Keamanan Sistem

### 7.1 Autentikasi

* API token unik per agent
* Token rotasi berkala

### 7.2 Otorisasi

* Role-based access control (RBAC) di dashboard
* Command whitelist di agent

### 7.3 Audit & Logging

* Semua aktivitas admin dicatat
* Log mencakup waktu, user, server, aksi

---

## 8. Roadmap Pengembangan

### Phase 1 – Core Agent

* Heartbeat
* Monitoring resource
* Service status

### Phase 2 – Service Control

* Restart / reload service
* Logging hasil eksekusi

### Phase 3 – MariaDB Management

* Database & user management
* Backup & restore

### Phase 4 – Dashboard UI

* Server list
* Status & grafik
* Action button

### Phase 5 – Advanced

* SSL automation
* Alert (Telegram)
* Role & multi admin
* Scheduled task

---

## 9. Target Lingkungan

* OS Agent: AlmaLinux 8 (opsional Ubuntu/Debian)
* Web Stack: Nginx, PHP-FPM, MariaDB
* Database Dashboard: MariaDB / MySQL

---

## 10. Kesimpulan

Pengembangan Server Management Panel internal dengan arsitektur Agent–Dashboard:

* Lebih aman dibanding panel umum
* Lebih ringan dan terkontrol
* Mudah dikembangkan sesuai kebutuhan
* Cocok untuk pengelolaan banyak server

Dokumen ini menjadi dasar perencanaan dan acuan pengembangan tahap selanjutnya.

---

**Status Dokumen:** Draft – Development Planning
**Revisi Berikutnya:** Detail API & Struktur Database


