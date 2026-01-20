# 📋 Requirements untuk Installer

## Tools yang Diperlukan

Script installer akan **otomatis install** tools berikut jika belum ada:

### Wajib
- ✅ **curl** - Untuk download script dari GitHub
- ✅ **git** - Untuk clone repository dari GitHub

### Opsional (akan diinstall otomatis)
- ✅ **wget** - Alternative download tool
- ✅ **python3** - Untuk agent
- ✅ **pip3** - Python package manager
- ✅ **composer** - Untuk dashboard (PHP)
- ✅ **npm** - Untuk dashboard (Node.js)

---

## Auto-Install

Script installer akan **otomatis install** semua tools yang diperlukan:

```bash
# Script akan check dan install otomatis:
- curl (jika belum ada)
- wget (jika belum ada)
- git (jika belum ada, untuk download dari GitHub)
- python3 & pip3 (untuk agent)
- composer (untuk dashboard)
- npm (untuk dashboard)
```

---

## Manual Install (Jika Auto-Install Gagal)

### AlmaLinux / CentOS / RHEL
```bash
dnf install -y curl wget git python3 python3-pip
```

### Ubuntu / Debian
```bash
apt-get update
apt-get install -y curl wget git python3 python3-pip
```

---

## Troubleshooting

### Error: "curl: command not found"
Script akan otomatis install curl. Jika gagal, install manual:
```bash
dnf install -y curl  # atau apt-get install -y curl
```

### Error: "git: command not found"
Script akan otomatis install git. Jika gagal, install manual:
```bash
dnf install -y git  # atau apt-get install -y git
```

### Error: "wget: command not found"
Wget opsional, tapi script akan install otomatis jika memungkinkan.

---

## ✅ Setelah Update

Script installer sekarang sudah include auto-install untuk:
- ✅ curl
- ✅ wget  
- ✅ git
- ✅ python3 & pip3
- ✅ composer (untuk dashboard)
- ✅ npm (untuk dashboard)

**Tidak perlu install manual lagi!** 🎉
