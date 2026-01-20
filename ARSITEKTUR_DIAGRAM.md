# Diagram Arsitektur Server Management Panel

## 1. Arsitektur High-Level

```
┌─────────────────────────────────────────────────────────────────┐
│                         DASHBOARD SERVER                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │   Web UI     │  │   REST API    │  │   Database   │        │
│  │  (Frontend)  │  │   (Backend)   │  │  (MariaDB)   │        │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘        │
│         │                  │                  │                 │
│         └──────────────────┴──────────────────┘                 │
│                            │                                     │
└────────────────────────────┼─────────────────────────────────────┘
                             │ HTTPS + Token Auth
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│  CLIENT #1    │   │  CLIENT #2    │   │  CLIENT #N    │
│  ┌─────────┐  │   │  ┌─────────┐  │   │  ┌─────────┐  │
│  │  Agent  │  │   │  │  Agent  │  │   │  │  Agent  │  │
│  └────┬────┘  │   │  └────┬────┘  │   │  └────┬────┘  │
│       │       │   │       │       │   │       │       │
│  ┌────┴────┐  │   │  ┌────┴────┐  │   │  ┌────┴────┐  │
│  │ Nginx   │  │   │  │ Nginx   │  │   │  │ Nginx   │  │
│  │ PHP-FPM │  │   │  │ PHP-FPM │  │   │  │ PHP-FPM │  │
│  │ MariaDB │  │   │  │ MariaDB │  │   │  │ MariaDB │  │
│  └─────────┘  │   │  └─────────┘  │   │  └─────────┘  │
└───────────────┘   └───────────────┘   └───────────────┘
```

## 2. Komponen Agent Detail

```
┌─────────────────────────────────────────────────────────┐
│                    AGENT (Client Server)                 │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │         Systemd Service (devops-agent)          │   │
│  │                                                  │   │
│  │  ┌──────────────┐      ┌──────────────┐        │   │
│  │  │  Collector   │      │  Executor    │        │   │
│  │  │              │      │              │        │   │
│  │  │ - CPU/RAM    │      │ - Service    │        │   │
│  │  │ - Disk       │      │   Control    │        │   │
│  │  │ - Uptime     │      │ - DB Mgmt    │        │   │
│  │  │ - Services   │      │ - Command    │        │   │
│  │  └──────┬───────┘      └──────┬───────┘        │   │
│  │         │                     │                 │   │
│  │         └──────────┬──────────┘                 │   │
│  │                    │                            │   │
│  │         ┌──────────▼──────────┐                 │   │
│  │         │   Command Queue     │                 │   │
│  │         │   (Local SQLite)    │                 │   │
│  │         └──────────┬──────────┘                 │   │
│  │                    │                            │   │
│  │         ┌──────────▼──────────┐                 │   │
│  │         │   HTTP Client       │                 │   │
│  │         │   - Heartbeat       │                 │   │
│  │         │   - Poll Commands   │                 │   │
│  │         │   - Send Results    │                 │   │
│  │         └─────────────────────┘                 │   │
│  └──────────────────────────────────────────────────┘   │
│                          │                               │
│         ┌────────────────┼────────────────┐            │
│         │                │                 │            │
│         ▼                ▼                 ▼            │
│    ┌────────┐      ┌─────────┐      ┌──────────┐      │
│    │ Nginx  │      │ PHP-FPM │      │ MariaDB  │      │
│    │systemctl│     │systemctl│      │UNIX Socket│      │
│    └────────┘      └─────────┘      └──────────┘      │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

## 3. Komponen Dashboard Detail

```
┌─────────────────────────────────────────────────────────────┐
│                    DASHBOARD SERVER                         │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Frontend (Web UI)                       │   │
│  │  - Server List & Status                              │   │
│  │  - Resource Graphs                                   │   │
│  │  - Command Interface                                 │   │
│  │  - Audit Logs                                        │   │
│  └──────────────────┬───────────────────────────────────┘   │
│                     │                                       │
│  ┌──────────────────▼───────────────────────────────────┐   │
│  │              REST API (Backend)                      │   │
│  │                                                      │   │
│  │  ┌──────────────┐  ┌──────────────┐                  │   │
│  │  │ Auth Module  │  │ Command      │                  │   │
│  │  │ - Token      │  │ Queue        │                  │   │
│  │  │ - RBAC       │  │ Manager      │                  │   │
│  │  └──────────────┘  └──────────────┘                  │   │
│  │                                                      │   │
│  │  ┌──────────────┐  ┌──────────────┐                  │   │
│  │  │ Metrics      │  │ Audit        │                  │   │
│  │  │ Collector    │  │ Logger       │                  │   │
│  │  └──────────────┘  └──────────────┘                  │   │
│  └──────────────────┬───────────────────────────────────┘   │
│                     │                                       │
│  ┌──────────────────▼───────────────────────────────────┐   │
│  │              Database (MariaDB)                      │   │
│  │  - servers                                           │   │
│  │  - commands                                          │   │
│  │  - metrics (time-series)                             │   │
│  │  - audit_logs                                        │   │
│  │  - admins                                            │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 4. Alur Komunikasi Heartbeat

```
┌─────────┐                                   ┌──────────┐
│  Agent  │                                   │Dashboard │
└────┬────┘                                   └────┬─────┘
     │                                             │
     │ 1. Collect Metrics                          │
     │    - CPU, RAM, Disk                         │
     │    - Service Status                         │
     │                                             │
     │ 2. POST /api/v1/heartbeat                   │
     │    ────────────────────────────────────────>│
     │    {                                        │
     │      agent_id: "...",                       │
     │      timestamp: "...",                      │
     │      system: {...},                         │
     │      services: {...}                        │
     │    }                                        │
     │                                             │
     │                                             │ 3. Validate Token
     │                                             │ 4. Store Metrics
     │                                             │ 5. Update Status
     │                                             │
     │ 6. 200 OK                                   │
     │ <───────────────────────────────────────────│
     │    {                                        │
     │      status: "ok",                          │
     │      commands_pending: true                 │
     │    }                                        │
     │                                             │
     │ [Wait 30 seconds]                           │
     │                                             │
     │ [Repeat]                                    │
```

## 5. Alur Komunikasi Command Execution

```
┌─────────┐         ┌──────────┐                    ┌─────────┐
│  Admin  │         │Dashboard │                    │  Agent  │
└────┬────┘         └────┬─────┘                    └────┬────┘
     │                   │                               │
     │ 1. Click          │                               │
     │    "Restart Nginx"│                               │
     │                   │                               │
     │ 2. POST /api/v1/  │                               │
     │    servers/{id}/  │                               │
     │    commands       │                               │
     │ ─────────────────>│                               │
     │                   │                               │
     │                   │ 3. Create Command             │
     │                   │    in Queue                   │
     │                   │    status: "pending"          │
     │                   │                               │
     │ 4. 200 OK         │                               │
     │ <─────────────────│                               │
     │                   │                               │
     │                   │                               │ 5. Polling
     │                   │                               │    GET /api/v1/
     │                   │                               │    commands/pending
     │                   │                               │ ──────────────────>
     │                   │                               │
     │                   │ 6. Return Pending Command    │
     │                   │ <─────────────────────────────│
     │                   │    {                          │
     │                   │      commands: [{             │
     │                   │        id: "...",            │
     │                   │        type: "service_restart",│
     │                   │        params: {...}         │
     │                   │      }]                      │
     │                   │    }                         │
     │                   │                               │
     │                   │                               │ 7. Update Status
     │                   │                               │    to "executing"
     │                   │                               │
     │                   │                               │ 8. Execute Command
     │                   │                               │    systemctl restart nginx
     │                   │                               │
     │                   │                               │ 9. Send Result
     │                   │                               │    POST /api/v1/
     │                   │                               │    commands/{id}/result
     │                   │                               │ ──────────────────>
     │                   │                               │    {              │
     │                   │                               │      status: "success",│
     │                   │                               │      output: "..." │
     │                   │                               │    }              │
     │                   │                               │
     │                   │ 10. Update Command           │
     │                   │     status: "completed"       │
     │                   │                               │
     │                   │ 11. 200 OK                   │
     │                   │ <─────────────────────────────│
     │                   │                               │
     │ 12. UI Update      │                               │
     │     (via polling   │                               │
     │      or WebSocket) │                               │
     │ <──────────────────│                               │
```

## 6. Security Layers

```
┌─────────────────────────────────────────────────────────┐
│                    SECURITY LAYERS                       │
│                                                          │
│  Layer 1: Network Security                              │
│  ┌──────────────────────────────────────────────────┐   │
│  │  - HTTPS Only (TLS 1.2+)                        │   │
│  │  - Firewall Rules                                │   │
│  │  - IP Whitelist (Optional)                       │   │
│  └──────────────────────────────────────────────────┘   │
│                          │                               │
│  Layer 2: Authentication                                │
│  ┌──────────────────────────────────────────────────┐   │
│  │  - API Token (Agent)                             │   │
│  │  - JWT/Session (Admin)                           │   │
│  │  - Token Rotation                                │   │
│  └──────────────────────────────────────────────────┘   │
│                          │                               │
│  Layer 3: Authorization                                │
│  ┌──────────────────────────────────────────────────┐   │
│  │  - RBAC (Admin)                                  │   │
│  │  - Command Whitelist (Agent)                     │   │
│  │  - Parameter Validation                          │   │
│  └──────────────────────────────────────────────────┘   │
│                          │                               │
│  Layer 4: Execution Security                            │
│  ┌──────────────────────────────────────────────────┐   │
│  │  - Non-root Agent User                           │   │
│  │  - Sudo with NOPASSWD (Limited)                 │   │
│  │  - UNIX Socket (MariaDB)                         │   │
│  │  - File Permissions                              │   │
│  └──────────────────────────────────────────────────┘   │
│                          │                               │
│  Layer 5: Audit & Monitoring                            │
│  ┌──────────────────────────────────────────────────┐   │
│  │  - All Actions Logged                           │   │
│  │  - Immutable Audit Logs                         │   │
│  │  - Alert on Anomalies                           │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

## 7. Database Schema Relationship

```
┌─────────────┐
│   admins    │
│─────────────│
│ id (PK)     │
│ username    │
│ password    │
│ role        │
└──────┬──────┘
       │
       │ 1:N
       │
┌──────▼──────────┐      ┌──────────────┐
│  audit_logs     │      │   servers    │
│─────────────────│      │──────────────│
│ id (PK)         │      │ id (PK)      │
│ admin_id (FK)   │      │ name         │
│ server_id (FK)  │      │ agent_token  │
│ action          │      │ status       │
│ details         │      │ last_heartbeat│
│ created_at      │      └──────┬───────┘
└─────────────────┘             │
                                │ 1:N
                                │
                    ┌───────────┴──────────┐
                    │                      │
            ┌───────▼────────┐   ┌────────▼────────┐
            │   commands     │   │    metrics      │
            │────────────────│   │─────────────────│
            │ id (PK)        │   │ id (PK)         │
            │ server_id (FK) │   │ server_id (FK)  │
            │ admin_id (FK)  │   │ timestamp       │
            │ command_type   │   │ cpu_percent     │
            │ command_params │   │ memory_percent  │
            │ status         │   │ disk_percent    │
            │ result         │   │ ...             │
            │ created_at     │   └─────────────────┘
            │ executed_at    │
            └────────────────┘
```

## 8. Deployment Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    PRODUCTION ENVIRONMENT                    │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              DASHBOARD SERVER                        │   │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐   │   │
│  │  │   Nginx    │  │   PHP-FPM  │  │  MariaDB   │   │   │
│  │  │  (Reverse │  │  (Backend) │  │ (Dashboard)│   │   │
│  │  │   Proxy)   │  │            │  │            │   │   │
│  │  └────────────┘  └────────────┘  └────────────┘   │   │
│  │         │                │                │          │   │
│  │         └────────────────┴────────────────┘          │   │
│  │                    │                                 │   │
│  │         ┌───────────▼───────────┐                    │   │
│  │         │   Web Application     │                    │   │
│  │         │   (Dashboard)         │                    │   │
│  │         └───────────────────────┘                    │   │
│  └──────────────────────────────────────────────────────┘   │
│                          │                                   │
│                          │ HTTPS                              │
│                          │                                    │
│        ┌─────────────────┼─────────────────┐                │
│        │                 │                 │                │
│        ▼                 ▼                 ▼                │
│  ┌──────────┐     ┌──────────┐     ┌──────────┐           │
│  │ CLIENT 1 │     │ CLIENT 2 │     │ CLIENT N │           │
│  │          │     │          │     │          │           │
│  │ ┌──────┐ │     │ ┌──────┐ │     │ ┌──────┐ │           │
│  │ │Agent │ │     │ │Agent │ │     │ │Agent │ │           │
│  │ └──────┘ │     │ └──────┘ │     │ └──────┘ │           │
│  │          │     │          │     │          │           │
│  │ ┌──────┐ │     │ ┌──────┐ │     │ ┌──────┐ │           │
│  │ │Nginx │ │     │ │Nginx │ │     │ │Nginx │ │           │
│  │ │PHP   │ │     │ │PHP   │ │     │ │PHP   │ │           │
│  │ │Maria │ │     │ │Maria │ │     │ │Maria │ │           │
│  │ └──────┘ │     │ └──────┘ │     │ └──────┘ │           │
│  └──────────┘     └──────────┘     └──────────┘           │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## 9. Command Flow dengan Error Handling

```
┌─────────┐         ┌──────────┐                    ┌─────────┐
│  Admin  │         │Dashboard │                    │  Agent  │
└────┬────┘         └────┬─────┘                    └────┬────┘
     │                   │                               │
     │ Create Command    │                               │
     │ ─────────────────>│                               │
     │                   │                               │
     │                   │ Store in Queue                │
     │                   │ status: "pending"             │
     │                   │                               │
     │                   │                               │ Polling
     │                   │                               │ ────────>
     │                   │                               │
     │                   │ Return Command                │
     │                   │ <─────────────────────────────│
     │                   │                               │
     │                   │                               │ Execute
     │                   │                               │ ────────┐
     │                   │                               │         │
     │                   │                               │    [SUCCESS]
     │                   │                               │         │
     │                   │                               │    Send Result
     │                   │                               │ <────────
     │                   │                               │
     │                   │ Update: "completed"           │
     │                   │                               │
     │                   │                               │
     │                   │                               │ [FAILURE]
     │                   │                               │         │
     │                   │                               │    Retry?
     │                   │                               │    ──────┐
     │                   │                               │         │
     │                   │                               │    retry_count++
     │                   │                               │    if < max_retries:
     │                   │                               │      status="pending"
     │                   │                               │    else:
     │                   │                               │      status="failed"
     │                   │                               │ <────────
     │                   │                               │
     │                   │ Update: "failed"              │
     │                   │                               │
     │ Alert Admin       │                               │
     │ <─────────────────│                               │
```

## 10. Monitoring & Alerting Flow

```
┌─────────┐                                    ┌──────────┐
│  Agent  │                                    │Dashboard │
└────┬────┘                                    └────┬─────┘
     │                                              │
     │ Collect Metrics                              │
     │                                              │
     │ Send Heartbeat                               │
     │ ────────────────────────────────────────────>│
     │                                              │
     │                                              │ Store Metrics
     │                                              │ Check Thresholds
     │                                              │
     │                                              │ ┌─────────────┐
     │                                              │ │ Alert Rules │
     │                                              │ │ - CPU > 80% │
     │                                              │ │ - RAM > 90% │
     │                                              │ │ - Disk > 85%│
     │                                              │ │ - Service Down│
     │                                              │ └──────┬──────┘
     │                                              │        │
     │                                              │        │ Threshold Exceeded?
     │                                              │        │
     │                                              │        ▼
     │                                              │   ┌─────────────┐
     │                                              │   │ Send Alert  │
     │                                              │   │ - Dashboard │
     │                                              │   │ - Telegram  │
     │                                              │   │ - Email     │
     │                                              │   └─────────────┘
     │                                              │
     │                                              │ Update UI
     │                                              │ Show Alert Badge
```

---

**Catatan**: Diagram ini dapat digunakan sebagai referensi visual selama implementasi.
