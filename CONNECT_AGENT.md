# 🔗 Cara Connect Agent ke Dashboard

## 📋 Langkah-langkah

### 1. Install Agent di Server Lain

Di server yang ingin di-monitor, jalankan:

```bash
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh | bash
```

Saat ditanya:
- **Server Name**: Nama server (contoh: `web-server-01`)
- **Dashboard URL**: `http://192.168.18.106:38490` (sesuai port dashboard Anda)

### 2. Generate Token dari Dashboard

**Opsi A: Via Dashboard UI (jika frontend sudah di-build)**
1. Login ke dashboard
2. Masuk ke menu "Servers" atau "Agents"
3. Klik "Add New Server" atau "Generate Token"
4. Masukkan nama server
5. Copy token yang di-generate

**Opsi B: Via API (langsung)**
```bash
# Di dashboard server
curl -X POST http://192.168.18.106:38490/api/v1/agents/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "server-agent-01",
    "ip": "192.168.18.105"
  }'
```

Response akan berisi token, simpan token tersebut.

### 3. Simpan Token ke Agent

**Di Agent Server:**

```bash
# Simpan token (ganti YOUR_TOKEN dengan token dari dashboard)
echo "YOUR_TOKEN_HERE" > /opt/devops-agent/etc/token

# Set permissions
chmod 600 /opt/devops-agent/etc/token
chown devops-agent:devops-agent /opt/devops-agent/etc/token
```

### 4. Restart Agent

```bash
systemctl restart devops-agent
systemctl status devops-agent
```

### 5. Verify Connection

**Check logs di agent:**
```bash
journalctl -u devops-agent -f
```

**Check di dashboard:**
- Agent akan muncul di dashboard dengan status "online"
- Metrics (CPU, RAM, Disk) akan mulai muncul

---

## 🎯 Quick Start

**1. Install Agent:**
```bash
curl -sSL https://raw.githubusercontent.com/hairil2912/DEVOPS-CENTRAL/master/install-agent.sh | bash
# Masukkan: Dashboard URL = http://192.168.18.106:38490
```

**2. Generate Token (di dashboard server):**
```bash
# Via API
curl -X POST http://192.168.18.106:38490/api/v1/agents/register \
  -H "Content-Type: application/json" \
  -d '{"name": "server-name", "ip": "192.168.18.105"}'
```

**3. Simpan Token (di agent server):**
```bash
echo "TOKEN_DARI_DASHBOARD" > /opt/devops-agent/etc/token
chmod 600 /opt/devops-agent/etc/token
chown devops-agent:devops-agent /opt/devops-agent/etc/token
systemctl restart devops-agent
```

---

## ✅ Checklist

- [ ] Agent sudah terinstall
- [ ] Dashboard URL sudah benar di config agent
- [ ] Token sudah di-generate dari dashboard
- [ ] Token sudah disimpan ke `/opt/devops-agent/etc/token`
- [ ] Permissions token sudah benar (600)
- [ ] Agent service sudah restart
- [ ] Agent muncul di dashboard dengan status "online"

---

## 🔧 Troubleshooting

### Agent tidak connect

1. **Check config:**
   ```bash
   cat /opt/devops-agent/etc/config.yaml
   # Pastikan dashboard.url benar
   ```

2. **Check token:**
   ```bash
   cat /opt/devops-agent/etc/token
   # Pastikan token benar dan tidak ada spasi
   ```

3. **Test connection:**
   ```bash
   curl -v http://192.168.18.106:38490/api/v1/health
   ```

4. **Check logs:**
   ```bash
   journalctl -u devops-agent -n 50
   ```

---

**Setelah semua selesai, agent akan otomatis mengirim heartbeat ke dashboard setiap 30 detik! 🚀**
