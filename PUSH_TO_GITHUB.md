# 🚀 Push Script Installer ke GitHub

Script installer sudah diupdate untuk auto-download dari GitHub. Sekarang perlu di-push ke GitHub agar bisa digunakan.

## 📋 Langkah-langkah

### 1. Check Status Git
```bash
git status
```

### 2. Add File Installer
```bash
git add install.sh install-agent.sh install-dashboard.sh quick-install.sh
```

### 3. Commit
```bash
git commit -m "Update installer scripts with auto-download from GitHub"
```

### 4. Push ke GitHub
```bash
git push origin master
```

### 5. Verify
Setelah push, test apakah file bisa diakses:
```bash
curl -I https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh
```

Harus return `HTTP/2 200` jika berhasil.

---

## ✅ Setelah Push

Sekarang one-line installer akan berfungsi:

```bash
# Install Agent
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh | bash

# Install Dashboard
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-dashboard.sh | bash
```

---

## 🔍 Troubleshooting

### Jika masih error setelah push:

1. **Check branch name:**
   ```bash
   git branch
   # Pastikan menggunakan branch 'master'
   ```

2. **Check file di GitHub:**
   - Buka: https://github.com/hairil2912/DEVOPS-CENTRAL/blob/master/install-agent.sh
   - Pastikan file sudah ada dan isinya sudah diupdate

3. **Clear cache (jika perlu):**
   ```bash
   # Di server yang akan install
   curl -I "https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh?v=$(date +%s)"
   ```

---

**Setelah push, script akan otomatis download file dari GitHub! 🎉**
