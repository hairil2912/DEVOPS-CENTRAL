# Analisis Arsitektur Server Management Panel (Agent-Dashboard)

## 📋 Ringkasan Eksekutif

Arsitektur Agent-Dashboard ini mengadopsi pola **pull-based command execution** dengan **push-based monitoring**. Desain ini memiliki beberapa kelebihan signifikan namun juga memiliki beberapa area yang perlu diperkuat sebelum implementasi.

---

## 🏗️ Arsitektur Umum

### Pola Komunikasi

```
┌─────────────┐                    ┌─────────────┐
│  Dashboard  │                    │   Agent     │
│  (Central)  │                    │  (Client)   │
└──────┬──────┘                    └──────┬──────┘
       │                                   │
       │  ←─── Heartbeat (Push) ──────────│
       │      (Periodic, e.g. 30s)         │
       │                                   │
       │  ──── Command Queue ───────────→ │
       │      (Polling)                    │
       │                                   │
       │  ←─── Execution Result ──────────│
       │      (Push)                       │
       │                                   │
```

**Karakteristik:**
- **Monitoring**: Agent → Dashboard (push, periodic)
- **Command**: Dashboard → Agent (pull-based via polling)
- **Result**: Agent → Dashboard (push, after execution)

---

## ✅ Kelebihan Arsitektur

### 1. **Keamanan yang Baik**
- ✅ Dashboard tidak perlu akses SSH ke client
- ✅ Dashboard tidak menyimpan credential database client
- ✅ Agent menggunakan UNIX socket untuk MariaDB (lebih aman)
- ✅ Command whitelist mencegah eksekusi perintah berbahaya

### 2. **Isolasi yang Kuat**
- ✅ Setiap agent independen
- ✅ Kompromi satu agent tidak langsung mempengaruhi dashboard
- ✅ Tidak ada direct database connection dari dashboard

### 3. **Scalability**
- ✅ Agent ringan (Python + systemd)
- ✅ Dashboard dapat menangani banyak agent
- ✅ Polling-based command mengurangi beban dashboard

### 4. **Audit Trail**
- ✅ Semua aktivitas tercatat
- ✅ Dapat dilacak siapa melakukan apa dan kapan

---

## ⚠️ Area yang Perlu Diperkuat

### 1. **Detail Komunikasi yang Kurang Jelas**

#### Masalah:
- **Heartbeat interval** tidak disebutkan
- **Polling interval** untuk command tidak didefinisikan
- **Timeout** untuk eksekusi command tidak ada
- **Retry mechanism** tidak dijelaskan

#### Rekomendasi:
```yaml
Heartbeat:
  interval: 30 detik
  timeout: 5 detik
  retry: 3 kali dengan exponential backoff

Command Polling:
  interval: 10 detik (normal)
  interval: 2 detik (setelah command dikirim, untuk 60 detik)
  timeout: 300 detik per command
  max_queue_size: 100 per agent
```

### 2. **Keamanan Token**

#### Masalah:
- Token rotasi "berkala" tidak spesifik
- Tidak ada mekanisme token revocation yang jelas
- Token storage di agent tidak disebutkan (file? env? vault?)

#### Rekomendasi:
- **Token rotation**: Otomatis setiap 90 hari
- **Token revocation**: Dashboard dapat revoke token secara real-time
- **Token storage**: Encrypted file dengan permission 600
- **Token format**: JWT dengan expiry atau UUID dengan database lookup

### 3. **Command Queue Management**

#### Masalah:
- Bagaimana jika agent offline saat command dikirim?
- Bagaimana jika command gagal dieksekusi?
- Apakah command queue persistent?
- Bagaimana handling concurrent commands?

#### Rekomendasi:
```python
Command Queue Schema:
- id (UUID)
- agent_id
- command_type (whitelist)
- command_params (JSON, validated)
- status (pending, executing, completed, failed)
- created_at
- executed_at
- result (JSON)
- retry_count
- max_retries (default: 3)
```

**Flow:**
1. Command masuk queue dengan status `pending`
2. Agent polling mengambil command dengan status `pending`
3. Status berubah ke `executing`
4. Agent eksekusi → kirim result
5. Status berubah ke `completed` atau `failed`
6. Jika failed dan retry_count < max_retries → status kembali `pending`

### 4. **Error Handling & Resilience**

#### Masalah:
- Bagaimana jika dashboard down?
- Bagaimana jika network terputus?
- Bagaimana jika agent crash?

#### Rekomendasi:
- **Agent**: Local command queue (SQLite) untuk menyimpan command yang belum dikirim result
- **Dashboard**: Health check endpoint untuk agent
- **Agent**: Auto-restart mechanism (systemd restart=always)
- **Dashboard**: Graceful degradation (tampilkan "last known status" jika agent offline)

### 5. **MariaDB Management - Detail Implementasi**

#### Masalah:
- Bagaimana agent mengakses MariaDB root tanpa password?
- Apakah menggunakan `mysql` command atau library Python?
- Bagaimana handling privilege template?

#### Rekomendasi:
```python
# Agent menggunakan mysql command dengan UNIX socket
# MariaDB config: root dapat login via socket tanpa password
# Command: mysql -u root --socket=/var/lib/mysql/mysql.sock

Privilege Templates:
- app_user: SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER
- readonly_user: SELECT
- reporting_user: SELECT (dengan beberapa tabel tertentu)
```

**Security Note:**
- Root access hanya via UNIX socket (localhost only)
- Tidak ada remote root access
- Agent berjalan sebagai user non-root dengan sudo untuk specific commands

### 6. **Monitoring & Alerting**

#### Masalah:
- Tidak ada detail tentang metrik yang dikumpulkan
- Tidak ada threshold untuk alert
- Tidak ada mekanisme notifikasi

#### Rekomendasi:
```json
Heartbeat Payload:
{
  "agent_id": "uuid",
  "timestamp": "ISO8601",
  "system": {
    "cpu_percent": 45.2,
    "memory_percent": 62.1,
    "disk_percent": 78.5,
    "uptime_seconds": 86400
  },
  "services": {
    "nginx": {"status": "running", "uptime": 86400},
    "php-fpm": {"status": "running", "active_processes": 5},
    "mariadb": {"status": "running", "connections": 12}
  },
  "alerts": [
    {"type": "high_cpu", "value": 85.0, "threshold": 80.0}
  ]
}
```

---

## 🔒 Analisis Keamanan Mendalam

### Strengths
1. ✅ **No SSH Access**: Dashboard tidak perlu SSH key management
2. ✅ **No Direct DB Access**: Dashboard tidak menyimpan DB credentials
3. ✅ **Command Whitelist**: Mencegah arbitrary command execution
4. ✅ **UNIX Socket**: MariaDB access lebih aman dari TCP

### Potential Vulnerabilities

#### 1. **Token Theft**
**Risiko**: Jika token dicuri, attacker dapat mengirim command ke agent

**Mitigasi**:
- Token disimpan encrypted di agent
- Token rotation otomatis
- IP whitelist di dashboard (optional)
- Rate limiting di dashboard API

#### 2. **Command Injection via Parameters**
**Risiko**: Jika command parameters tidak divalidasi dengan baik

**Mitigasi**:
```python
# Contoh command whitelist dengan parameter validation
ALLOWED_COMMANDS = {
    "service_restart": {
        "allowed_services": ["nginx", "php-fpm", "mariadb"],
        "param_validation": lambda x: x in ["nginx", "php-fpm", "mariadb"]
    },
    "db_create": {
        "param_validation": lambda x: re.match(r'^[a-zA-Z0-9_]{1,64}$', x)
    }
}
```

#### 3. **Agent Compromise**
**Risiko**: Jika agent di-compromise, attacker dapat:
- Mengakses MariaDB root via socket
- Mengubah service status
- Mengirim false heartbeat data

**Mitigasi**:
- Agent berjalan sebagai user terbatas (bukan root)
- Sudo hanya untuk specific commands dengan NOPASSWD
- File permission ketat untuk agent binary dan config
- Integrity check (optional: checksum verification)

#### 4. **Dashboard Compromise**
**Risiko**: Jika dashboard di-compromise:
- Attacker dapat mengirim command ke semua agent
- Attacker dapat melihat semua server status

**Mitigasi**:
- RBAC dengan granular permissions
- 2FA untuk admin accounts
- Audit log yang tidak dapat dihapus
- Network isolation (dashboard di network terpisah)

---

## 📊 Arsitektur Data Flow Detail

### Scenario 1: Normal Monitoring

```
Time    Agent                          Dashboard
─────────────────────────────────────────────────────
00:00   Collect system metrics
00:00   ──── POST /api/heartbeat ────→ Store metrics
00:00   ←──── 200 OK ──────────────────
00:30   Collect system metrics
00:30   ──── POST /api/heartbeat ────→ Store metrics
00:30   ←──── 200 OK ──────────────────
```

### Scenario 2: Command Execution

```
Time    Admin        Dashboard                    Agent
─────────────────────────────────────────────────────────────
00:00   Click        ──── Create command ────→   Queue
        "Restart     │    in queue                │
        Nginx"       │                            │
                     │                            │
00:05                │    ←─── GET /api/cmd ────── Polling
                     │    ──── Return command ────│
                     │                            │
00:05                │                            │ Execute:
                     │                            │ systemctl restart nginx
                     │                            │
00:07                │    ←─── POST /api/result ── Send result
                     │    ──── 200 OK ────────────│
                     │                            │
00:07   See result   Update UI
        in UI
```

### Scenario 3: Agent Offline

```
Time    Agent        Dashboard
─────────────────────────────────────
00:00   Online       ←─── Heartbeat ────
00:30   Online       ←─── Heartbeat ────
01:00   CRASH        (no heartbeat)
01:30   Offline      (no heartbeat)
02:00   Offline      Mark as offline
                     Show "Last seen: 01:00"
```

---

## 🎯 Rekomendasi Implementasi

### Phase 1 Enhancement

**Tambahkan ke Phase 1:**

1. **Health Check Endpoint**
   - Agent expose `/health` endpoint (optional, untuk debugging)
   - Dashboard health check untuk semua agent

2. **Error Handling**
   - Agent: Local queue untuk failed commands
   - Dashboard: Retry mechanism untuk failed heartbeats

3. **Configuration Management**
   - Agent config file (YAML/JSON)
   - Dashboard dapat push config update via command

### Phase 2 Enhancement

**Tambahkan ke Phase 2:**

1. **Command Validation**
   - Schema validation untuk setiap command type
   - Parameter sanitization

2. **Rate Limiting**
   - Limit command per agent per waktu
   - Prevent command spam

### Phase 3 Enhancement

**Tambahkan ke Phase 3:**

1. **Backup Verification**
   - Checksum backup files
   - Backup rotation (keep last N backups)

2. **Database Size Monitoring**
   - Track database size over time
   - Alert jika size meningkat drastis

### Phase 4 Enhancement

**Tambahkan ke Phase 4:**

1. **Real-time Updates**
   - WebSocket untuk real-time status update
   - Server-Sent Events (SSE) sebagai alternatif

2. **Dashboard Performance**
   - Caching untuk status yang tidak berubah
   - Pagination untuk server list

### Phase 5 Enhancement

**Tambahkan ke Phase 5:**

1. **Multi-tenancy**
   - Support untuk multiple organizations
   - Isolasi data per tenant

2. **API Gateway**
   - Rate limiting per API key
   - API versioning

---

## 🔧 Detail Teknis yang Perlu Didefinisikan

### 1. API Endpoints

#### Dashboard API (untuk Agent)

```
POST   /api/v1/heartbeat
  Body: {agent_id, timestamp, system, services, alerts}
  Response: {status: "ok", commands_pending: true}

GET    /api/v1/commands/pending
  Headers: Authorization: Bearer <token>
  Response: {commands: [{id, type, params, created_at}]}

POST   /api/v1/commands/{id}/result
  Body: {status: "success|failed", output: "...", error: "..."}
  Response: {status: "ok"}

GET    /api/v1/config
  Response: {heartbeat_interval: 30, polling_interval: 10}
```

#### Dashboard API (untuk Admin)

```
GET    /api/v1/servers
POST   /api/v1/servers
GET    /api/v1/servers/{id}
PUT    /api/v1/servers/{id}
DELETE /api/v1/servers/{id}

POST   /api/v1/servers/{id}/commands
  Body: {type: "service_restart", params: {service: "nginx"}}

GET    /api/v1/servers/{id}/metrics
GET    /api/v1/servers/{id}/logs
```

### 2. Database Schema (Dashboard)

```sql
-- Servers table
CREATE TABLE servers (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    hostname VARCHAR(255),
    ip_address INET,
    agent_token VARCHAR(255) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'offline', -- online, offline, unknown
    last_heartbeat TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Commands table
CREATE TABLE commands (
    id UUID PRIMARY KEY,
    server_id UUID REFERENCES servers(id),
    admin_id UUID REFERENCES admins(id),
    command_type VARCHAR(50) NOT NULL,
    command_params JSONB,
    status VARCHAR(20) DEFAULT 'pending', -- pending, executing, completed, failed
    result JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    executed_at TIMESTAMP,
    retry_count INT DEFAULT 0,
    max_retries INT DEFAULT 3
);

-- Metrics table (time-series data)
CREATE TABLE metrics (
    id UUID PRIMARY KEY,
    server_id UUID REFERENCES servers(id),
    timestamp TIMESTAMP NOT NULL,
    cpu_percent DECIMAL(5,2),
    memory_percent DECIMAL(5,2),
    disk_percent DECIMAL(5,2),
    nginx_status VARCHAR(20),
    php_fpm_status VARCHAR(20),
    mariadb_status VARCHAR(20)
);

CREATE INDEX idx_metrics_server_time ON metrics(server_id, timestamp DESC);

-- Audit logs
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY,
    admin_id UUID REFERENCES admins(id),
    server_id UUID REFERENCES servers(id),
    action VARCHAR(100) NOT NULL,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 3. Agent Configuration File

```yaml
# /etc/devops-agent/config.yaml
agent:
  id: "550e8400-e29b-41d4-a716-446655440000"
  name: "web-server-01"
  
dashboard:
  url: "https://dashboard.example.com"
  token: "encrypted_token_here"
  verify_ssl: true
  
heartbeat:
  interval: 30  # seconds
  timeout: 5    # seconds
  retry_count: 3
  
polling:
  interval: 10  # seconds
  timeout: 5    # seconds
  
logging:
  level: "INFO"
  file: "/var/log/devops-agent/agent.log"
  max_size: "10MB"
  backup_count: 5
```

---

## 🚨 Critical Issues yang Harus Diatasi

### 1. **Command Queue Race Condition**

**Problem**: Jika dua admin mengirim command bersamaan ke agent yang sama

**Solution**: 
- Database-level locking (SELECT FOR UPDATE)
- Command queue dengan priority
- Sequential processing per agent

### 2. **Heartbeat Loss**

**Problem**: Jika network terputus, dashboard tidak tahu apakah agent offline atau hanya network issue

**Solution**:
- Grace period (mark offline setelah 3 missed heartbeats)
- Agent retry dengan exponential backoff
- Dashboard health check endpoint (optional)

### 3. **Token Storage Security**

**Problem**: Token di agent dapat dibaca oleh user dengan akses file system

**Solution**:
- Encrypt token file
- Use systemd credential (systemd 248+)
- Or use environment variable dengan proper permission

### 4. **Command Timeout**

**Problem**: Command yang hang dapat memblokir queue

**Solution**:
- Set timeout untuk setiap command type
- Kill process jika timeout
- Mark command as failed dan continue

---

## 📈 Scalability Considerations

### Current Design Limits

1. **Polling Overhead**: 
   - 100 agents × polling setiap 10 detik = 10 requests/detik ke dashboard
   - Manageable untuk dashboard modern

2. **Heartbeat Volume**:
   - 100 agents × heartbeat setiap 30 detik = ~3.3 requests/detik
   - Manageable

3. **Database Growth**:
   - Metrics table akan tumbuh cepat
   - **Solution**: Retention policy (hapus data > 90 hari) atau time-series DB (InfluxDB, TimescaleDB)

### Optimization Recommendations

1. **Batch Heartbeat**: Agent dapat mengirim multiple metrics sekaligus
2. **Compression**: Compress payload besar
3. **Caching**: Cache status server di dashboard (update setiap heartbeat)
4. **Database Partitioning**: Partition metrics table per bulan

---

## 🎓 Best Practices yang Disarankan

1. **Idempotency**: Semua command harus idempotent
2. **Idempotency Key**: Command dengan key yang sama tidak dieksekusi dua kali
3. **Versioning**: API versioning sejak awal
4. **Documentation**: OpenAPI/Swagger untuk API documentation
5. **Testing**: Unit test untuk command whitelist validation
6. **Monitoring**: Monitor dashboard sendiri (self-monitoring)
7. **Backup**: Backup database dashboard secara berkala
8. **Disaster Recovery**: Plan untuk recovery jika dashboard down

---

## 📝 Kesimpulan

Arsitektur Agent-Dashboard ini **solid dan aman** dengan beberapa area yang perlu diperkuat:

### Strengths
- ✅ Security-first design
- ✅ Good isolation
- ✅ Scalable architecture
- ✅ Clear separation of concerns

### Areas for Improvement
- ⚠️ Detail implementasi perlu lebih spesifik
- ⚠️ Error handling perlu lebih robust
- ⚠️ Monitoring & alerting perlu lebih detail
- ⚠️ Scalability considerations perlu lebih eksplisit

### Next Steps
1. Buat detail API specification (OpenAPI)
2. Buat detail database schema
3. Buat detail command whitelist dengan validation
4. Buat proof of concept untuk Phase 1
5. Buat security review sebelum production

---

**Dokumen ini melengkapi readme.MD dengan analisis mendalam dan rekomendasi implementasi.**
