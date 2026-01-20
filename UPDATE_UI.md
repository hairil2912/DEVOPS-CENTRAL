# 🔄 Update Dashboard UI Manual

## Masalah
File UI di server hanya 2.4KB (placeholder), padahal file lengkap 39KB sudah ada di repository.

## Solusi 1: Download Langsung dari GitHub (Recommended)

Jika file sudah di-push ke GitHub:

```bash
# Di server dashboard
cd /var/www/devops-dashboard/frontend/dist

# Backup file lama
mv index.html index.html.backup

# Download file lengkap dari GitHub
curl -o index.html https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/dashboard/frontend/dist/index.html

# Verify file size (harus ~39KB)
ls -lh index.html

# Reload Nginx
systemctl reload nginx
```

## Solusi 2: Copy dari Komputer Lokal via SCP

Jika file ada di komputer lokal:

```bash
# Dari komputer lokal (Windows/Linux/Mac)
scp dashboard/frontend/dist/index.html root@192.168.18.106:/var/www/devops-dashboard/frontend/dist/index.html

# Atau jika pakai password
scp dashboard/frontend/dist/index.html root@SERVER_IP:/var/www/devops-dashboard/frontend/dist/
```

## Solusi 3: Re-install (Setelah Push ke GitHub)

1. **Push file ke GitHub** (dari komputer lokal):
   ```bash
   git add dashboard/frontend/dist/index.html
   git commit -m "Add complete dashboard UI"
   git push origin master
   ```

2. **Re-install di server**:
   ```bash
   curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-dashboard.sh | bash
   ```

## Verifikasi

Setelah update, verifikasi file:

```bash
# Cek ukuran file (harus ~39KB, bukan 2.4KB)
ls -lh /var/www/devops-dashboard/frontend/dist/index.html

# Cek apakah ada "servers-grid" (indikator UI lengkap)
grep -q "servers-grid" /var/www/devops-dashboard/frontend/dist/index.html && echo "✓ Full UI" || echo "✗ Still placeholder"

# Test di browser
curl http://localhost:31142 | head -20
```

## Catatan

- File lengkap: ~39KB, 1201 baris
- File placeholder: ~2.4KB, ~60 baris
- Setelah update, clear browser cache (Ctrl+F5)
