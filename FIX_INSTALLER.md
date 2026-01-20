# 🔧 Fix: Error "Agent files not found"

## Masalah
Script di GitHub masih versi lama, jadi muncul error:
```
Error: Agent files not found. Please run from project directory or provide URL
```

## ✅ Solusi Cepat

### Opsi 1: Push Script ke GitHub (Permanen)

**Di komputer lokal Anda (Windows):**

```bash
cd D:\KLIKDATA\DEVOPS-CENTRAL

# Check status
git status

# Add file installer
git add install.sh install-agent.sh install-dashboard.sh quick-install.sh

# Commit
git commit -m "Update installer scripts with auto-download from GitHub"

# Push ke GitHub
git push origin master
```

**Setelah push, di server langsung jalankan:**
```bash
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh | bash
```

---

### Opsi 2: Install Langsung dari GitHub (Tanpa Push)

**Di server, jalankan ini:**

```bash
# Download dan install langsung
bash <(curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh) || \
git clone --depth 1 https://github.com/hairil2912/DEVOPS-CENTRAL.git /tmp/devops-install && \
cd /tmp/devops-install && bash install-agent.sh
```

---

### Opsi 3: Git Clone Manual (Paling Mudah Saat Ini)

**Di server:**

```bash
# Clone repository
git clone https://github.com/hairil2912/DEVOPS-CENTRAL.git
cd DEVOPS-CENTRAL

# Install agent
bash install-agent.sh
```

**Keuntungan:**
- ✅ Langsung bisa digunakan sekarang
- ✅ Tidak perlu push dulu
- ✅ File lengkap tersedia

---

## 🎯 Rekomendasi

**Untuk sekarang (cepat):**
```bash
# Di server
git clone https://github.com/hairil2912/DEVOPS-CENTRAL.git
cd DEVOPS-CENTRAL
bash install-agent.sh
```

**Untuk masa depan (setelah push):**
```bash
# Di server - langsung tanpa clone
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh | bash
```

---

## 📝 Checklist

- [ ] Push script installer ke GitHub (opsional, untuk one-line installer)
- [ ] Atau gunakan git clone manual di server (bisa langsung sekarang)
- [ ] Setelah push, one-line installer akan berfungsi

---

**Pilih opsi yang paling mudah untuk Anda! 🚀**
