# DevOps Agent

Agent yang dipasang di setiap server client untuk komunikasi dengan Dashboard Central.

## Instalasi

```bash
# 1. Clone atau copy folder agent ke server
cd /opt
git clone <repo-url> devops-agent
# atau
scp -r agent/ root@server:/opt/devops-agent

# 2. Install dependencies
cd /opt/devops-agent
pip3 install -r requirements.txt

# 3. Buat user untuk agent
useradd -r -s /bin/false devops-agent
groupadd -r devops-agent

# 4. Setup konfigurasi
cp etc/config.yaml.example etc/config.yaml
nano etc/config.yaml  # Edit konfigurasi

# 5. Generate token dari dashboard dan simpan ke etc/token

# 6. Set permissions
chown -R devops-agent:devops-agent /opt/devops-agent
chmod 600 etc/config.yaml etc/token
chmod +x bin/devops-agent

# 7. Install systemd service
cp systemd/devops-agent.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable devops-agent
systemctl start devops-agent

# 8. Check status
systemctl status devops-agent
journalctl -u devops-agent -f
```

## Struktur Folder

- `bin/` - Executable scripts
- `etc/` - Konfigurasi
- `lib/` - Python modules
- `var/` - Data & logs
- `systemd/` - Service files
- `tests/` - Unit tests

## Konfigurasi

Edit file `etc/config.yaml` untuk mengatur:
- Dashboard URL
- Heartbeat interval
- Polling interval
- Logging level

## Troubleshooting

```bash
# Check logs
tail -f /opt/devops-agent/var/log/agent.log
journalctl -u devops-agent -f

# Test connection
python3 bin/agent-cli test-connection

# Check service status
systemctl status devops-agent
```
