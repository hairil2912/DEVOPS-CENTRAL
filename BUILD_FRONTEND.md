# 🎨 Build Frontend Dashboard

## 📝 Status Saat Ini

Tampilan yang Anda lihat sekarang adalah **placeholder HTML** yang dibuat otomatis untuk memastikan dashboard bisa diakses.

Frontend yang sebenarnya ada di `dashboard/frontend/src/` dan perlu di-build untuk mendapatkan tampilan lengkap.

---

## 🚀 Cara Build Frontend

### 1. Masuk ke Directory Frontend

```bash
cd /var/www/devops-dashboard/frontend
```

### 2. Install Dependencies

```bash
npm install
```

Ini akan install semua dependencies yang diperlukan (mungkin butuh 2-3 menit).

### 3. Build Frontend

```bash
npm run build
```

Ini akan build frontend dan menghasilkan file di `frontend/dist/`.

### 4. Reload Nginx

```bash
systemctl reload nginx
```

### 5. Akses Dashboard Lagi

Buka browser dan akses:
```
http://192.168.18.106:37968
```

Sekarang akan tampil frontend yang lengkap dengan:
- ✅ Login page
- ✅ Dashboard dengan charts
- ✅ Server management
- ✅ Agent management
- ✅ Dan fitur lainnya

---

## ⚡ Quick Build (One Command)

```bash
cd /var/www/devops-dashboard/frontend && npm install && npm run build && systemctl reload nginx
```

---

## 🔍 Check Build Status

```bash
# Check apakah dist folder sudah ada dan berisi file
ls -la /var/www/devops-dashboard/frontend/dist/

# Check ukuran file (jika sudah di-build, akan ada banyak file)
du -sh /var/www/devops-dashboard/frontend/dist/
```

---

## ⚠️ Troubleshooting

### npm install gagal

```bash
# Install Node.js jika belum ada
dnf install -y nodejs npm

# Atau update Node.js
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
dnf install -y nodejs npm
```

### npm run build error

1. Check Node.js version (minimal Node 14+):
   ```bash
   node --version
   ```

2. Clear cache dan rebuild:
   ```bash
   rm -rf node_modules package-lock.json
   npm install
   npm run build
   ```

### Build sukses tapi masih tampil placeholder

1. Check apakah file sudah ada:
   ```bash
   ls -la /var/www/devops-dashboard/frontend/dist/
   ```

2. Clear browser cache atau gunakan incognito mode

3. Reload Nginx:
   ```bash
   systemctl reload nginx
   ```

---

## 📌 Catatan

- **Placeholder HTML** sudah cukup untuk:
  - ✅ Backend API berfungsi
  - ✅ Agent bisa connect
  - ✅ Testing API

- **Full Frontend** diperlukan untuk:
  - ✅ UI lengkap
  - ✅ Management dashboard
  - ✅ Visualisasi data
  - ✅ User interface yang lebih baik

---

**Setelah build, dashboard akan memiliki tampilan lengkap dengan semua fitur! 🎉**
