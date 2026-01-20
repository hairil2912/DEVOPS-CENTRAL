# Struktur Folder Proyek Server Management Panel

## 📁 Struktur Proyek Keseluruhan

```
DEVOPS-CENTRAL/
├── agent/                          # Komponen Agent (untuk Client Server)
│   ├── src/
│   ├── config/
│   ├── scripts/
│   ├── tests/
│   └── ...
├── dashboard/                      # Komponen Dashboard (untuk Central Server)
│   ├── backend/
│   ├── frontend/
│   ├── database/
│   └── ...
├── docs/                          # Dokumentasi
├── scripts/                       # Script instalasi & deployment
└── README.md
```

---

## 🤖 Struktur Folder AGENT

### Lokasi Instalasi: `/opt/devops-agent/` atau `/usr/local/devops-agent/`

```
devops-agent/
├── bin/                           # Binary & executable scripts
│   ├── devops-agent               # Main agent binary/script
│   ├── agent-cli                  # CLI tool untuk debugging
│   └── install.sh                 # Script instalasi agent
│
├── etc/                           # Konfigurasi
│   ├── config.yaml                # Konfigurasi utama agent
│   ├── config.yaml.example        # Template konfigurasi
│   └── commands.yaml              # Command whitelist definition
│
├── lib/                           # Library & modules Python
│   ├── __init__.py
│   ├── collector.py               # System metrics collector
│   ├── executor.py                # Command executor
│   ├── http_client.py              # HTTP client untuk komunikasi dengan dashboard
│   ├── command_queue.py            # Local command queue manager
│   ├── db_manager.py               # MariaDB management
│   ├── service_manager.py          # Service control (nginx, php-fpm, mariadb)
│   └── utils.py                   # Utility functions
│
├── var/                           # Data & runtime files
│   ├── run/                       # PID files, sockets
│   │   └── devops-agent.pid
│   ├── lib/                       # Local database (SQLite)
│   │   └── command_queue.db
│   └── log/                       # Log files
│       └── agent.log
│
├── systemd/                       # Systemd service files
│   └── devops-agent.service
│
├── tests/                         # Unit tests
│   ├── test_collector.py
│   ├── test_executor.py
│   └── test_http_client.py
│
├── requirements.txt               # Python dependencies
├── README.md                      # Dokumentasi agent
└── LICENSE
```

### File Konfigurasi Agent (`etc/config.yaml`)

```yaml
agent:
  id: "550e8400-e29b-41d4-a716-446655440000"  # UUID unik per agent
  name: "web-server-01"                        # Nama server
  version: "1.0.0"

dashboard:
  url: "https://dashboard.example.com"
  api_version: "v1"
  token: ""                                    # Akan diisi saat instalasi
  token_file: "/opt/devops-agent/etc/token"    # File encrypted token
  verify_ssl: true
  timeout: 30                                  # seconds

heartbeat:
  interval: 30                                 # seconds
  timeout: 5                                   # seconds
  retry_count: 3
  retry_delay: 10                              # seconds

polling:
  interval: 10                                 # seconds (normal)
  fast_interval: 2                             # seconds (setelah command dikirim)
  fast_duration: 60                            # seconds
  timeout: 5                                    # seconds

logging:
  level: "INFO"                                # DEBUG, INFO, WARNING, ERROR
  file: "/opt/devops-agent/var/log/agent.log"
  max_size: "10MB"
  backup_count: 5
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

database:
  queue_file: "/opt/devops-agent/var/lib/command_queue.db"
  backup_retention: 7                          # days

security:
  user: "devops-agent"                         # User untuk menjalankan agent
  group: "devops-agent"
  token_encryption: true
```

### Systemd Service File (`systemd/devops-agent.service`)

```ini
[Unit]
Description=DevOps Central Agent
After=network.target mariadb.service

[Service]
Type=simple
User=devops-agent
Group=devops-agent
WorkingDirectory=/opt/devops-agent
ExecStart=/usr/bin/python3 /opt/devops-agent/bin/devops-agent
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

# Security
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/devops-agent/var

[Install]
WantedBy=multi-user.target
```

---

## 🎛️ Struktur Folder DASHBOARD

### Lokasi Instalasi: `/var/www/devops-dashboard/` atau sesuai konvensi web server

```
devops-dashboard/
├── backend/                      # Backend API (PHP/Python/Node.js)
│   ├── app/
│   │   ├── Controllers/
│   │   │   ├── ServerController.php
│   │   │   ├── CommandController.php
│   │   │   ├── MetricController.php
│   │   │   ├── AuthController.php
│   │   │   └── AuditController.php
│   │   │
│   │   ├── Models/
│   │   │   ├── Server.php
│   │   │   ├── Command.php
│   │   │   ├── Metric.php
│   │   │   ├── Admin.php
│   │   │   └── AuditLog.php
│   │   │
│   │   ├── Services/
│   │   │   ├── CommandQueueService.php
│   │   │   ├── MetricService.php
│   │   │   ├── AlertService.php
│   │   │   └── TokenService.php
│   │   │
│   │   ├── Middleware/
│   │   │   ├── AuthMiddleware.php
│   │   │   ├── RBACMiddleware.php
│   │   │   └── RateLimitMiddleware.php
│   │   │
│   │   ├── Validators/
│   │   │   └── CommandValidator.php
│   │   │
│   │   └── config/
│   │       ├── database.php
│   │       ├── app.php
│   │       └── security.php
│   │
│   ├── routes/
│   │   ├── api.php               # API routes
│   │   └── web.php               # Web routes
│   │
│   ├── database/
│   │   ├── migrations/
│   │   │   ├── 001_create_servers_table.php
│   │   │   ├── 002_create_commands_table.php
│   │   │   ├── 003_create_metrics_table.php
│   │   │   ├── 004_create_admins_table.php
│   │   │   └── 005_create_audit_logs_table.php
│   │   │
│   │   ├── seeds/
│   │   │   └── AdminSeeder.php
│   │   │
│   │   └── schema.sql            # Full schema SQL
│   │
│   ├── storage/
│   │   ├── logs/
│   │   ├── cache/
│   │   └── backups/
│   │
│   ├── tests/
│   │   ├── Unit/
│   │   └── Integration/
│   │
│   ├── public/
│   │   └── index.php             # Entry point
│   │
│   ├── composer.json             # PHP dependencies
│   └── .env                      # Environment variables
│
├── frontend/                     # Frontend Web UI
│   ├── src/
│   │   ├── components/
│   │   │   ├── ServerList.vue
│   │   │   ├── ServerCard.vue
│   │   │   ├── MetricsChart.vue
│   │   │   ├── CommandPanel.vue
│   │   │   ├── AuditLog.vue
│   │   │   └── AlertBadge.vue
│   │   │
│   │   ├── views/
│   │   │   ├── Dashboard.vue
│   │   │   ├── Servers.vue
│   │   │   ├── ServerDetail.vue
│   │   │   ├── Commands.vue
│   │   │   └── Audit.vue
│   │   │
│   │   ├── services/
│   │   │   ├── api.js
│   │   │   └── websocket.js
│   │   │
│   │   ├── store/                # State management
│   │   │   ├── servers.js
│   │   │   ├── commands.js
│   │   │   └── auth.js
│   │   │
│   │   ├── router/
│   │   │   └── index.js
│   │   │
│   │   ├── assets/
│   │   │   ├── css/
│   │   │   └── images/
│   │   │
│   │   └── main.js
│   │
│   ├── public/
│   │   └── index.html
│   │
│   ├── package.json
│   └── vite.config.js
│
├── database/                     # Database scripts & backups
│   ├── schema/
│   │   └── full_schema.sql
│   ├── migrations/
│   └── backups/
│
├── nginx/                        # Nginx configuration
│   ├── devops-dashboard.conf
│   └── ssl/
│
├── scripts/                      # Utility scripts
│   ├── install.sh
│   ├── backup-db.sh
│   ├── migrate.sh
│   └── generate-token.sh
│
├── docs/                         # Dokumentasi
│   ├── API.md
│   ├── INSTALLATION.md
│   └── DEPLOYMENT.md
│
└── README.md
```

### Struktur Backend Detail (PHP Laravel/Slim Framework)

```
backend/app/
├── Controllers/
│   ├── Api/
│   │   ├── Agent/
│   │   │   ├── HeartbeatController.php      # POST /api/v1/heartbeat
│   │   │   ├── CommandController.php        # GET /api/v1/commands/pending
│   │   │   └── ResultController.php         # POST /api/v1/commands/{id}/result
│   │   │
│   │   └── Admin/
│   │       ├── ServerController.php         # CRUD servers
│   │       ├── CommandController.php        # Create commands
│   │       ├── MetricController.php         # Get metrics
│   │       └── AuditController.php          # Get audit logs
│   │
│   └── Web/
│       └── DashboardController.php
│
├── Models/
│   ├── Server.php
│   ├── Command.php
│   ├── Metric.php
│   ├── Admin.php
│   └── AuditLog.php
│
├── Services/
│   ├── CommandQueueService.php
│   ├── MetricService.php
│   ├── AlertService.php
│   └── TokenService.php
│
└── config/
    ├── database.php
    ├── app.php
    └── security.php
```

### Struktur Frontend Detail (Vue.js)

```
frontend/src/
├── components/
│   ├── common/
│   │   ├── Header.vue
│   │   ├── Sidebar.vue
│   │   └── LoadingSpinner.vue
│   │
│   ├── server/
│   │   ├── ServerList.vue
│   │   ├── ServerCard.vue
│   │   ├── ServerDetail.vue
│   │   └── ServerMetrics.vue
│   │
│   ├── command/
│   │   ├── CommandPanel.vue
│   │   ├── CommandHistory.vue
│   │   └── CommandForm.vue
│   │
│   └── chart/
│       ├── CpuChart.vue
│       ├── MemoryChart.vue
│       └── DiskChart.vue
│
├── views/
│   ├── Dashboard.vue
│   ├── Servers.vue
│   ├── ServerDetail.vue
│   ├── Commands.vue
│   └── Audit.vue
│
├── services/
│   ├── api.js                  # API client
│   ├── websocket.js            # WebSocket client
│   └── auth.js                 # Authentication
│
└── store/
    ├── modules/
    │   ├── servers.js
    │   ├── commands.js
    │   ├── metrics.js
    │   └── auth.js
    └── index.js
```

---

## 📋 File Konfigurasi Dashboard

### Backend `.env` (Laravel/PHP)

```env
APP_NAME=DevOps Central Dashboard
APP_ENV=production
APP_DEBUG=false
APP_URL=https://dashboard.example.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=devops_dashboard
DB_USERNAME=devops_dashboard
DB_PASSWORD=secure_password_here

# Security
APP_KEY=base64:...
JWT_SECRET=...
SESSION_DRIVER=redis
SESSION_LIFETIME=120

# Redis (optional, untuk cache & session)
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Alerting
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=
SMTP_HOST=
SMTP_PORT=587
SMTP_USER=
SMTP_PASSWORD=

# Agent Settings
AGENT_TOKEN_LENGTH=64
AGENT_TOKEN_EXPIRY_DAYS=90
```

### Frontend `.env`

```env
VITE_API_URL=https://dashboard.example.com/api/v1
VITE_WS_URL=wss://dashboard.example.com/ws
VITE_APP_NAME=DevOps Central
```

---

## 🔧 Script Instalasi

### Agent Install Script (`agent/bin/install.sh`)

```bash
#!/bin/bash
# Install script untuk DevOps Agent

AGENT_DIR="/opt/devops-agent"
AGENT_USER="devops-agent"
AGENT_GROUP="devops-agent"

# Create user & group
useradd -r -s /bin/false $AGENT_USER
groupadd -r $AGENT_GROUP

# Create directories
mkdir -p $AGENT_DIR/{bin,etc,lib,var/{run,lib,log},systemd,tests}
chown -R $AGENT_USER:$AGENT_GROUP $AGENT_DIR

# Copy files
cp -r bin/* $AGENT_DIR/bin/
cp -r etc/* $AGENT_DIR/etc/
cp systemd/*.service /etc/systemd/system/

# Install Python dependencies
pip3 install -r requirements.txt

# Set permissions
chmod +x $AGENT_DIR/bin/devops-agent
chmod 600 $AGENT_DIR/etc/config.yaml

# Enable & start service
systemctl daemon-reload
systemctl enable devops-agent
systemctl start devops-agent

echo "Agent installed successfully!"
```

### Dashboard Install Script (`dashboard/scripts/install.sh`)

```bash
#!/bin/bash
# Install script untuk DevOps Dashboard

DASHBOARD_DIR="/var/www/devops-dashboard"
NGINX_USER="nginx"

# Create directories
mkdir -p $DASHBOARD_DIR/{backend,frontend,database,nginx,scripts,docs}
mkdir -p $DASHBOARD_DIR/backend/storage/{logs,cache,backups}

# Set permissions
chown -R $NGINX_USER:$NGINX_USER $DASHBOARD_DIR
chmod -R 755 $DASHBOARD_DIR
chmod -R 775 $DASHBOARD_DIR/backend/storage

# Install backend dependencies
cd $DASHBOARD_DIR/backend
composer install --no-dev --optimize-autoloader

# Install frontend dependencies
cd $DASHBOARD_DIR/frontend
npm install
npm run build

# Setup database
mysql -u root -p < $DASHBOARD_DIR/database/schema/full_schema.sql

# Copy nginx config
cp $DASHBOARD_DIR/nginx/devops-dashboard.conf /etc/nginx/conf.d/

# Reload nginx
systemctl reload nginx

echo "Dashboard installed successfully!"
```

---

## 📊 Database Schema Location

```
database/
├── schema/
│   ├── full_schema.sql           # Complete schema
│   └── tables/
│       ├── servers.sql
│       ├── commands.sql
│       ├── metrics.sql
│       ├── admins.sql
│       └── audit_logs.sql
│
└── migrations/                   # Versioned migrations
    ├── 001_create_servers_table.php
    ├── 002_create_commands_table.php
    ├── 003_create_metrics_table.php
    ├── 004_create_admins_table.php
    └── 005_create_audit_logs_table.php
```

---

## 🔐 Security Files Location

### Agent
- Token file: `/opt/devops-agent/etc/token` (encrypted, 600)
- Config: `/opt/devops-agent/etc/config.yaml` (600)
- SSL certificates: `/opt/devops-agent/etc/ssl/` (optional)

### Dashboard
- `.env`: `/var/www/devops-dashboard/backend/.env` (600)
- SSL certificates: `/etc/nginx/ssl/` atau `/var/www/devops-dashboard/nginx/ssl/`
- Session files: `/var/www/devops-dashboard/backend/storage/sessions/` (700)

---

## 📝 Log Files Location

### Agent
- Main log: `/opt/devops-agent/var/log/agent.log`
- Systemd journal: `journalctl -u devops-agent`

### Dashboard
- Backend log: `/var/www/devops-dashboard/backend/storage/logs/app.log`
- Nginx access: `/var/log/nginx/devops-dashboard-access.log`
- Nginx error: `/var/log/nginx/devops-dashboard-error.log`

---

## 🚀 Deployment Checklist

### Agent Deployment
- [ ] Create agent user & group
- [ ] Copy files to `/opt/devops-agent/`
- [ ] Install Python dependencies
- [ ] Configure `config.yaml`
- [ ] Generate & store agent token
- [ ] Install systemd service
- [ ] Start & enable service
- [ ] Verify heartbeat working

### Dashboard Deployment
- [ ] Setup web server (Nginx)
- [ ] Install PHP/Python/Node.js backend
- [ ] Install frontend dependencies
- [ ] Configure database
- [ ] Run migrations
- [ ] Configure `.env`
- [ ] Setup SSL certificates
- [ ] Configure Nginx
- [ ] Test API endpoints
- [ ] Deploy frontend build

---

**Catatan**: Struktur ini dapat disesuaikan dengan teknologi stack yang dipilih (PHP Laravel, Python Flask/Django, Node.js Express, dll).
