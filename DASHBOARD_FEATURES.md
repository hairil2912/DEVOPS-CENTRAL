# Dashboard Features - Monitoring & Control

## 📊 Fungsi Monitoring

Dashboard menyediakan monitoring real-time untuk semua server yang terhubung melalui agent.

### 1. **Server Status Monitoring**
- ✅ Status server (Online/Offline/Unknown)
- ✅ Last heartbeat timestamp
- ✅ Server information (name, hostname, IP address)
- ✅ Uptime tracking

**API Endpoints:**
```bash
GET /api/v1/servers              # List all servers
GET /api/v1/servers/{id}          # Get server details
GET /api/v1/servers/{id}/status  # Get server status
```

### 2. **System Metrics Monitoring**
Dashboard mengumpulkan dan menampilkan metrics real-time dari setiap server:

#### **CPU Monitoring**
- CPU usage percentage
- CPU load average
- Per-core CPU usage

#### **Memory Monitoring**
- Memory usage percentage
- Total/Used/Available memory
- Swap usage

#### **Disk Monitoring**
- Disk usage percentage
- Disk used/total space
- Per-partition disk usage
- I/O statistics

#### **Service Status Monitoring**
- Nginx status (running/stopped)
- PHP-FPM status dan active processes
- MariaDB/MySQL status dan connections
- Custom services monitoring

**API Endpoints:**
```bash
GET /api/v1/servers/{id}/metrics           # Get latest metrics
GET /api/v1/servers/{id}/metrics/history   # Get metrics history (time-series)
GET /api/v1/servers/{id}/metrics/cpu       # Get CPU metrics
GET /api/v1/servers/{id}/metrics/memory    # Get memory metrics
GET /api/v1/servers/{id}/metrics/disk      # Get disk metrics
```

### 3. **Alerts & Notifications**
Dashboard dapat mengirim alert ketika:
- Server offline (tidak ada heartbeat)
- CPU usage > threshold
- Memory usage > threshold
- Disk usage > threshold
- Service down (Nginx, PHP-FPM, MariaDB)
- Custom alerts

**API Endpoints:**
```bash
GET /api/v1/alerts                    # List all alerts
GET /api/v1/alerts/active            # Get active alerts
GET /api/v1/alerts/{id}               # Get alert details
POST /api/v1/alerts/{id}/resolve      # Resolve alert
GET /api/v1/servers/{id}/alerts       # Get alerts for specific server
```

### 4. **Real-time Dashboard**
- Live metrics charts (CPU, Memory, Disk)
- Server status overview
- Active alerts panel
- Recent commands execution
- System health score

---

## 🎮 Fungsi Kontrol

Dashboard memungkinkan Anda mengontrol server remote melalui agent.

### 1. **Command Execution**
Jalankan perintah di server remote secara aman melalui whitelist commands.

**Supported Commands:**
- Service control (start/stop/restart/status)
- System commands (reboot, shutdown)
- Package management (install/update/remove)
- File operations (read/write/copy/move)
- Custom commands (sesuai whitelist)

**API Endpoints:**
```bash
POST /api/v1/servers/{id}/commands           # Create command
GET /api/v1/servers/{id}/commands            # List commands for server
GET /api/v1/commands/{id}                   # Get command details
POST /api/v1/commands/{id}/cancel           # Cancel pending command
GET /api/v1/commands                        # List all commands
```

**Command Types:**
```json
{
  "type": "service_control",
  "params": {
    "service": "nginx",
    "action": "restart"
  }
}

{
  "type": "system_command",
  "params": {
    "command": "df -h"
  }
}

{
  "type": "package_install",
  "params": {
    "package": "htop"
  }
}
```

### 2. **Service Management**
Kontrol services di server remote:
- Start/Stop/Restart services
- Enable/Disable services
- Check service status
- View service logs

**API Endpoints:**
```bash
POST /api/v1/servers/{id}/services/{name}/start    # Start service
POST /api/v1/servers/{id}/services/{name}/stop    # Stop service
POST /api/v1/servers/{id}/services/{name}/restart # Restart service
GET /api/v1/servers/{id}/services                 # List all services
GET /api/v1/servers/{id}/services/{name}/status   # Get service status
GET /api/v1/servers/{id}/services/{name}/logs     # Get service logs
```

### 3. **File Operations**
Operasi file di server remote (dengan permission):
- Read file
- Write file
- Copy/Move file
- Delete file
- List directory

**API Endpoints:**
```bash
GET /api/v1/servers/{id}/files/read        # Read file
POST /api/v1/servers/{id}/files/write      # Write file
POST /api/v1/servers/{id}/files/copy       # Copy file
POST /api/v1/servers/{id}/files/move       # Move file
DELETE /api/v1/servers/{id}/files/delete   # Delete file
GET /api/v1/servers/{id}/files/list        # List directory
```

### 4. **Package Management**
Install/update/remove packages di server remote:
- Install package
- Update package
- Remove package
- List installed packages

**API Endpoints:**
```bash
POST /api/v1/servers/{id}/packages/install  # Install package
POST /api/v1/servers/{id}/packages/update   # Update package
POST /api/v1/servers/{id}/packages/remove   # Remove package
GET /api/v1/servers/{id}/packages           # List packages
```

### 5. **System Control**
Kontrol sistem level:
- Reboot server
- Shutdown server
- System info
- System updates

**API Endpoints:**
```bash
POST /api/v1/servers/{id}/reboot           # Reboot server
POST /api/v1/servers/{id}/shutdown         # Shutdown server
GET /api/v1/servers/{id}/system/info       # Get system info
POST /api/v1/servers/{id}/system/update    # System update
```

---

## 📋 Audit & Logging

Semua aktivitas dicatat untuk audit trail:

### Audit Logs
- User actions (who, what, when)
- Command execution history
- Server changes
- Permission changes

**API Endpoints:**
```bash
GET /api/v1/audit/logs                     # List audit logs
GET /api/v1/audit/logs/{id}                 # Get audit log details
GET /api/v1/servers/{id}/audit             # Get audit logs for server
GET /api/v1/admins/{id}/audit               # Get audit logs for admin
```

---

## 🔐 Security Features

### 1. **Authentication & Authorization**
- Admin login/logout
- Role-based access control (super_admin, admin, operator)
- Token-based authentication
- Session management

**API Endpoints:**
```bash
POST /api/v1/auth/login                    # Admin login
POST /api/v1/auth/logout                   # Admin logout
GET /api/v1/auth/me                        # Get current user
POST /api/v1/auth/refresh                  # Refresh token
```

### 2. **Command Whitelist**
- Hanya command yang di-whitelist yang bisa dijalankan
- Configurable via `agent/etc/commands.yaml`
- Prevents unauthorized commands

### 3. **Agent Authentication**
- Token-based agent authentication
- Secure communication (HTTPS support)
- IP whitelist (optional)

---

## 📈 Dashboard Views

### 1. **Overview Dashboard**
- Total servers (online/offline)
- System health overview
- Recent alerts
- Active commands
- Quick stats

### 2. **Server Detail View**
- Server information
- Real-time metrics charts
- Service status
- Recent commands
- Alerts history

### 3. **Metrics Dashboard**
- CPU/Memory/Disk charts
- Historical data
- Comparison between servers
- Export data

### 4. **Commands Dashboard**
- Command queue
- Execution history
- Failed commands
- Retry options

### 5. **Alerts Dashboard**
- Active alerts
- Alert history
- Alert rules configuration
- Notification settings

---

## 🔄 Real-time Updates

Dashboard menggunakan WebSocket atau polling untuk update real-time:
- Live metrics updates
- Server status changes
- Command execution status
- New alerts

**WebSocket Endpoints:**
```
ws://dashboard:port/ws/metrics/{server_id}
ws://dashboard:port/ws/commands/{server_id}
ws://dashboard:port/ws/alerts
```

---

## 📝 Implementation Status

### ✅ Completed
- [x] Basic API structure
- [x] Agent registration
- [x] Agent heartbeat
- [x] Database schema
- [x] Installation scripts

### 🚧 In Progress / TODO
- [ ] Complete API endpoints implementation
- [ ] Frontend dashboard UI
- [ ] Real-time metrics collection
- [ ] Command execution system
- [ ] Alert system
- [ ] WebSocket integration
- [ ] Authentication system
- [ ] Audit logging
- [ ] File operations
- [ ] Service management

---

## 🚀 Next Steps

1. **Implement Complete API Endpoints**
   - Metrics endpoints
   - Command execution endpoints
   - Alert endpoints
   - Audit log endpoints

2. **Build Frontend Dashboard**
   - Server overview page
   - Server detail page
   - Metrics charts
   - Command interface
   - Alert management

3. **Implement Real-time Features**
   - WebSocket server
   - Live metrics updates
   - Real-time command status

4. **Add Security Features**
   - Admin authentication
   - Role-based access control
   - Command whitelist enforcement

5. **Testing & Documentation**
   - API documentation
   - User guide
   - Deployment guide

---

## 📚 Related Documentation

- [CONNECT_AGENT.md](./CONNECT_AGENT.md) - How to connect agents
- [DASHBOARD_NEXT_STEPS.md](./DASHBOARD_NEXT_STEPS.md) - Post-installation steps
- [ARSITEKTUR_ANALISIS.md](./ARSITEKTUR_ANALISIS.md) - Architecture analysis
- [dashboard/README.md](./dashboard/README.md) - Dashboard documentation
