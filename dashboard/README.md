# DevOps Dashboard

Dashboard central untuk mengelola banyak server melalui agent.

## Struktur

- `backend/` - Backend API (PHP/Python/Node.js)
- `frontend/` - Frontend Web UI (Vue.js/React)
- `database/` - Database schema & migrations
- `nginx/` - Nginx configuration
- `scripts/` - Installation & utility scripts

## Instalasi

```bash
# 1. Clone repository
cd /var/www
git clone <repo-url> devops-dashboard

# 2. Run install script
cd devops-dashboard
chmod +x scripts/install.sh
sudo ./scripts/install.sh

# 3. Configure
# Edit backend/.env
# Edit nginx/devops-dashboard.conf

# 4. Setup SSL
# Generate SSL certificates atau gunakan Let's Encrypt

# 5. Reload Nginx
sudo systemctl reload nginx
```

## Konfigurasi

### Backend (.env)
- Database credentials
- Security keys
- Alerting settings

### Frontend (.env)
- API URL
- WebSocket URL

### Nginx
- SSL certificates
- Server name
- Upstream configuration

## Development

### Backend
```bash
cd backend
composer install
php artisan serve
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```

## API Endpoints

### Agent API
- `POST /api/v1/heartbeat` - Agent heartbeat
- `GET /api/v1/commands/pending` - Get pending commands
- `POST /api/v1/commands/{id}/result` - Submit command result

### Admin API
- `GET /api/v1/servers` - List servers
- `POST /api/v1/servers/{id}/commands` - Create command
- `GET /api/v1/servers/{id}/metrics` - Get metrics
- `GET /api/v1/audit` - Get audit logs

## Database

```bash
# Run migrations
mysql -u root -p < database/schema/full_schema.sql

# Backup
mysqldump -u root -p devops_dashboard > backup.sql

# Restore
mysql -u root -p devops_dashboard < backup.sql
```
