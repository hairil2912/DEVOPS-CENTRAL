# 🚀 Cara Akses Dashboard UI

## 📍 URL Akses

Setelah instalasi selesai, dashboard akan menampilkan URL akses:

```
🌐 Access Dashboard:
   http://192.168.18.106:31142
```

**Format:** `http://[IP_SERVER]:[PORT]`

---

## 🌐 Cara Akses

### 1. **Dari Browser (Komputer Lain)**

1. Buka browser (Chrome, Firefox, Edge, dll)
2. Masukkan URL yang ditampilkan saat install:
   ```
   http://192.168.18.106:31142
   ```
   *(Ganti dengan IP dan port server Anda)*
3. Tekan **Enter**

### 2. **Dari Server Dashboard (Local)**

```bash
# Test dengan curl
curl http://localhost:31142

# Atau buka di browser server (jika ada GUI)
# http://localhost:31142
```

---

## 🔍 Jika Lupa URL/Port

### Cek Port yang Digunakan

```bash
# Cek port yang tersimpan
cat /var/www/devops-dashboard/.dashboard_port

# Atau cek dari Nginx config
grep "listen" /etc/nginx/conf.d/devops-dashboard.conf
```

### Cek IP Server

```bash
# Cek IP lokal server
ip addr show | grep "inet " | grep -v 127.0.0.1

# Atau
hostname -I

# Atau
ip route get 8.8.8.8 | awk '{print $7}'
```

---

## 📊 Tampilan Dashboard

Dashboard memiliki **5 tab utama**:

### 1. **📊 Overview**
- Stat cards (Total Servers, Online, Offline, Alerts)
- Server grid dengan status real-time
- System health chart
- Auto-refresh setiap 30 detik

### 2. **🖥️ Servers**
- Daftar semua server yang terhubung
- Server cards dengan:
  - Name, IP, Status
  - Real-time metrics (CPU, Memory, Disk)
  - Quick actions (Restart, Metrics, Remove)
- Add server button

### 3. **📈 Metrics**
- CPU Usage Chart (line chart)
- Memory Usage Chart
- Disk Usage Chart
- Filter per server
- Historical data visualization

### 4. **⚡ Commands**
- Command execution history
- Create new command
- Command status tracking
- Service control, system commands, package install

### 5. **⚠️ Alerts**
- Active alerts list
- Alert severity (Critical, Warning, Info)
- Alert details dan timestamps

---

## 🔧 Troubleshooting

### Dashboard Tidak Bisa Diakses

#### 1. Cek Nginx Status
```bash
systemctl status nginx
```

Jika tidak running:
```bash
systemctl start nginx
systemctl enable nginx
```

#### 2. Cek Port Listening
```bash
netstat -tuln | grep 31142
# atau
ss -tuln | grep 31142
```

#### 3. Cek Firewall
```bash
# Cek port yang terbuka
firewall-cmd --list-ports

# Jika port tidak ada, buka manual:
firewall-cmd --permanent --add-port=31142/tcp
firewall-cmd --reload
```

#### 4. Cek Nginx Logs
```bash
# Error log
tail -f /var/log/nginx/error.log

# Access log
tail -f /var/log/nginx/access.log
```

#### 5. Cek File Frontend
```bash
# Pastikan file UI ada
ls -lh /var/www/devops-dashboard/frontend/dist/index.html

# Cek permission
ls -la /var/www/devops-dashboard/frontend/dist/
```

#### 6. Test API
```bash
# Test health endpoint
curl http://localhost:31142/api/v1/health

# Test agents endpoint
curl http://localhost:31142/api/v1/agents
```

---

## 🔄 Refresh Dashboard

Dashboard akan **auto-refresh setiap 30 detik** untuk update data real-time.

Atau klik tombol **🔄 Refresh** di header untuk manual refresh.

---

## 📱 Akses dari Mobile

Dashboard **responsive** dan bisa diakses dari mobile browser:

1. Pastikan mobile device di jaringan yang sama
2. Buka browser mobile
3. Masukkan URL: `http://[IP_SERVER]:[PORT]`
4. Dashboard akan otomatis adjust untuk mobile

---

## 🔐 Security Notes

- **Port Random**: Port di-generate random (10000-65535) untuk keamanan
- **Port Persistence**: Port tersimpan di `/var/www/devops-dashboard/.dashboard_port`
- **Firewall**: Port otomatis dibuka saat install
- **HTTPS**: Untuk production, disarankan setup SSL/HTTPS

---

## 📝 Catatan Penting

1. **IP Address**: Gunakan IP lokal server (bukan localhost) untuk akses dari komputer lain
2. **Port**: Port random untuk keamanan, simpan URL yang ditampilkan saat install
3. **Firewall**: Pastikan firewall sudah terbuka (installer sudah handle ini)
4. **Network**: Pastikan komputer client dan server di jaringan yang sama

---

## 🆘 Masalah Umum

### Error 403 Forbidden
```bash
# Fix permissions
chown -R nginx:nginx /var/www/devops-dashboard
chmod -R 755 /var/www/devops-dashboard
systemctl reload nginx
```

### Error 502 Bad Gateway
```bash
# Cek PHP-FPM
systemctl status php-fpm
systemctl restart php-fpm
```

### Dashboard Kosong/Tidak Load
```bash
# Clear browser cache
# Atau gunakan incognito/private mode

# Cek file frontend
ls -lh /var/www/devops-dashboard/frontend/dist/index.html
```

---

**Setelah install, gunakan URL yang ditampilkan untuk akses dashboard! 🚀**
