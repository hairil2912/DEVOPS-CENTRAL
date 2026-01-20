# 🚀 Install di Banyak Server Agent

Untuk install di banyak server agent, ada beberapa cara:

## ✅ Cara 1: Push ke GitHub (Paling Mudah untuk Banyak Server)

### Step 1: Push Script ke GitHub (Sekali Saja)

**Di komputer lokal Anda:**

```bash
cd D:\KLIKDATA\DEVOPS-CENTRAL

# Push script installer
git add install.sh install-agent.sh install-dashboard.sh
git commit -m "Update installer with auto-download"
git push origin master
```

### Step 2: Install di Setiap Server Agent (Sama untuk Semua Server)

**Di setiap server agent, jalankan:**

```bash
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh | bash
```

**Keuntungan:**
- ✅ Satu command untuk semua server
- ✅ Tidak perlu copy file
- ✅ Mudah di-automate
- ✅ Selalu dapat versi terbaru

---

## ✅ Cara 2: Copy Script ke Server (Jika Belum Bisa Push)

### Step 1: Copy Script ke Server

**Dari komputer lokal, copy file ke server:**

```bash
# Via SCP (dari Windows, gunakan PowerShell atau WSL)
scp install-agent.sh root@server-agent-1:/tmp/
scp install-agent.sh root@server-agent-2:/tmp/
scp install-agent-3:/tmp/
```

**Atau buat script untuk copy ke banyak server:**

```bash
# Buat file servers.txt dengan list IP server
# 192.168.1.10
# 192.168.1.11
# 192.168.1.12

for server in $(cat servers.txt); do
    scp install-agent.sh root@$server:/tmp/
    ssh root@$server "bash /tmp/install-agent.sh"
done
```

### Step 2: Install di Server

**SSH ke setiap server dan jalankan:**

```bash
# Di server agent
bash /tmp/install-agent.sh
```

---

## ✅ Cara 3: Git Clone di Setiap Server (Manual)

**Di setiap server agent:**

```bash
git clone https://github.com/hairil2912/DEVOPS-CENTRAL.git
cd DEVOPS-CENTRAL
bash install-agent.sh
```

**Keuntungan:**
- ✅ Langsung bisa digunakan sekarang
- ✅ Tidak perlu push dulu

**Kekurangan:**
- ❌ Harus clone di setiap server
- ❌ Lebih lama jika banyak server

---

## 🎯 Rekomendasi untuk Banyak Server

### Untuk Sekarang (Cepat):
```bash
# Di setiap server agent
git clone https://github.com/hairil2912/DEVOPS-CENTRAL.git
cd DEVOPS-CENTRAL
bash install-agent.sh
```

### Untuk Masa Depan (Setelah Push):
```bash
# Di setiap server agent - satu command saja!
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh | bash
```

---

## 📝 Script untuk Install Otomatis ke Banyak Server

Buat file `install-all-agents.sh`:

```bash
#!/bin/bash
# Install agent ke banyak server sekaligus

SERVERS=(
    "192.168.1.10"
    "192.168.1.11"
    "192.168.1.12"
)

for server in "${SERVERS[@]}"; do
    echo "Installing on $server..."
    ssh root@$server "curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh | bash"
done
```

**Setelah push ke GitHub, script ini bisa install ke semua server sekaligus!**

---

## 🔄 Workflow yang Disarankan

1. **Sekarang:** Push script ke GitHub (sekali saja)
2. **Kemudian:** Install di setiap server dengan one-line command
3. **Masa depan:** Bisa automate install ke banyak server sekaligus

---

**Pilih cara yang paling sesuai dengan kebutuhan Anda! 🚀**
