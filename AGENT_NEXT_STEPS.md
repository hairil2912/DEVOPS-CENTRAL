# ✅ Agent Installed Successfully - Next Steps

## 🎉 Instalasi Berhasil!

Agent sudah terinstall di server. Sekarang perlu setup koneksi ke Dashboard.

---

## 📋 Langkah Selanjutnya

### 1. Generate Token dari Dashboard

**Di Dashboard Server:**

Login ke dashboard dan generate token untuk agent ini:
- Masuk ke menu "Servers" atau "Agents"
- Klik "Add New Server" atau "Generate Token"
- Masukkan nama server (sesuai yang diinput saat install)
- Copy token yang di-generate

**Atau via API (jika sudah ada):**
```bash
curl -X POST https://your-dashboard.com/api/v1/servers \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -d '{"name": "server-agent", "ip": "192.168.1.100"}'
```

---

### 2. Simpan Token ke Agent

**Di Agent Server:**

```bash
# Simpan token (ganti YOUR_TOKEN dengan token dari dashboard)
echo "YOUR_TOKEN_HERE" > /opt/devops-agent/etc/token

# Set permissions
chmod 600 /opt/devops-agent/etc/token
chown devops-agent:devops-agent /opt/devops-agent/etc/token
```

**Atau edit manual:**
```bash
nano /opt/devops-agent/etc/token
# Paste token di sini, save (Ctrl+X, Y, Enter)
chmod 600 /opt/devops-agent/etc/token
chown devops-agent:devops-agent /opt/devops-agent/etc/token
```

---

### 3. Verify Configuration

**Check config file:**
```bash
cat /opt/devops-agent/etc/config.yaml
```

Pastikan:
- ✅ `dashboard.url` sudah benar (sesuai yang diinput)
- ✅ `agent.name` sudah diisi
- ✅ `agent.id` sudah ada (UUID)

**Edit jika perlu:**
```bash
nano /opt/devops-agent/etc/config.yaml
```

---

### 4. Start Agent Service

```bash
# Start service
systemctl start devops-agent

# Enable auto-start on boot
systemctl enable devops-agent

# Check status
systemctl status devops-agent
```

**Expected output:**
```
● devops-agent.service - DevOps Central Agent
   Loaded: loaded (/etc/systemd/system/devops-agent.service)
   Active: active (running)
```

---

### 5. Check Logs

```bash
# View logs
journalctl -u devops-agent -f

# Atau
tail -f /opt/devops-agent/var/log/agent.log
```

**Look for:**
- ✅ "Connected to dashboard"
- ✅ "Heartbeat sent successfully"
- ✅ No error messages

---

### 6. Verify Connection ke Dashboard

**Di Dashboard:**

1. Login ke dashboard
2. Masuk ke menu "Servers" atau "Agents"
3. Cek apakah server muncul dengan status "online"
4. Cek apakah metrics (CPU, RAM, Disk) sudah muncul

**Atau test manual:**
```bash
# Di agent server, test connection
curl -X POST http://YOUR_DASHBOARD_IP/api/v1/heartbeat \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"agent_id": "YOUR_AGENT_ID", "timestamp": "2026-01-21T00:00:00Z"}'
```

---

## 🔧 Troubleshooting

### Agent tidak start

```bash
# Check service status
systemctl status devops-agent

# Check logs
journalctl -u devops-agent -n 50

# Check config
cat /opt/devops-agent/etc/config.yaml

# Check token
cat /opt/devops-agent/etc/token
```

### Agent tidak connect ke Dashboard

1. **Check network:**
   ```bash
   ping YOUR_DASHBOARD_IP
   curl -v http://YOUR_DASHBOARD_IP/api/v1/health
   ```

2. **Check token:**
   ```bash
   cat /opt/devops-agent/etc/token
   # Pastikan token benar dan tidak ada spasi
   ```

3. **Check config:**
   ```bash
   cat /opt/devops-agent/etc/config.yaml
   # Pastikan dashboard.url benar
   ```

4. **Check firewall:**
   ```bash
   firewall-cmd --list-all
   # Pastikan port dashboard bisa diakses
   ```

### Agent start tapi tidak ada di Dashboard

1. Check token di dashboard - pastikan token benar
2. Check agent_id di config - pastikan sesuai dengan yang di dashboard
3. Check logs untuk error messages
4. Verify dashboard URL bisa diakses dari agent

---

## ✅ Checklist

- [ ] Token sudah di-generate dari dashboard
- [ ] Token sudah disimpan ke `/opt/devops-agent/etc/token`
- [ ] Permissions token sudah benar (600)
- [ ] Config file sudah benar (`config.yaml`)
- [ ] Agent service sudah start
- [ ] Agent muncul di dashboard dengan status "online"
- [ ] Metrics sudah muncul di dashboard

---

## 📝 Quick Commands

```bash
# Check status
systemctl status devops-agent

# View logs
journalctl -u devops-agent -f

# Restart agent
systemctl restart devops-agent

# Stop agent
systemctl stop devops-agent

# Check config
cat /opt/devops-agent/etc/config.yaml

# Check token
cat /opt/devops-agent/etc/token

# Test connection
curl -v http://YOUR_DASHBOARD_IP/api/v1/health
```

---

**Setelah semua checklist selesai, agent akan otomatis mengirim heartbeat ke dashboard setiap 30 detik! 🚀**
