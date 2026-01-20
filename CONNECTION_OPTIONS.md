# 🔌 Opsi Koneksi Agent - Dashboard

## 📋 Opsi Koneksi yang Didukung

Agent bisa terhubung ke Dashboard dengan beberapa cara:

### ✅ 1. HTTPS dengan Domain (Recommended untuk Production)
```
https://dashboard.example.com
https://devops.company.com
```

**Keuntungan:**
- ✅ Secure (encrypted)
- ✅ SSL certificate validation
- ✅ Professional
- ✅ Mudah diingat

**Konfigurasi:**
```yaml
dashboard:
  url: "https://dashboard.example.com"
  verify_ssl: true
```

---

### ✅ 2. HTTPS dengan IP (Untuk Testing/Internal)
```
https://192.168.1.100
https://10.0.0.50
```

**Keuntungan:**
- ✅ Secure (encrypted)
- ✅ Tidak perlu DNS
- ✅ Cocok untuk internal network

**Konfigurasi:**
```yaml
dashboard:
  url: "https://192.168.1.100"
  verify_ssl: false  # Set false karena IP tidak punya valid SSL cert
```

**Note:** Perlu setup SSL certificate untuk IP atau gunakan self-signed certificate.

---

### ✅ 3. HTTP dengan Domain (Untuk Development)
```
http://dashboard.local
http://devops-dev.company.com
```

**Keuntungan:**
- ✅ Simple setup
- ✅ Tidak perlu SSL certificate
- ✅ Cocok untuk development/testing

**Konfigurasi:**
```yaml
dashboard:
  url: "http://dashboard.local"
  verify_ssl: false
```

**⚠️ Warning:** Tidak secure! Jangan gunakan di production.

---

### ✅ 4. HTTP dengan IP (Paling Simple, untuk Internal Network)
```
http://192.168.1.100
http://10.0.0.50
```

**Keuntungan:**
- ✅ Paling mudah setup
- ✅ Tidak perlu DNS
- ✅ Tidak perlu SSL certificate
- ✅ Cocok untuk internal network yang aman

**Konfigurasi:**
```yaml
dashboard:
  url: "http://192.168.1.100"
  verify_ssl: false
```

**⚠️ Warning:** 
- Tidak secure (tidak encrypted)
- Hanya untuk internal network yang terpercaya
- Jangan gunakan di internet/public network

---

## 🔒 Rekomendasi Keamanan

### Production Environment
```
✅ HTTPS + Domain + verify_ssl: true
   Contoh: https://dashboard.company.com
```

### Internal Network (Trusted)
```
✅ HTTPS + IP + verify_ssl: false
   Contoh: https://192.168.1.100
   
⚠️ Atau HTTP + IP (jika network benar-benar aman)
   Contoh: http://192.168.1.100
```

### Development/Testing
```
⚠️ HTTP + IP atau Domain
   Contoh: http://192.168.1.100
   Contoh: http://dashboard.local
```

---

## 📝 Contoh Konfigurasi

### Contoh 1: Production dengan HTTPS
```yaml
dashboard:
  url: "https://devops.company.com"
  verify_ssl: true
  timeout: 30
```

### Contoh 2: Internal Network dengan IP (HTTPS)
```yaml
dashboard:
  url: "https://192.168.1.100"
  verify_ssl: false  # Self-signed certificate
  timeout: 30
```

### Contoh 3: Internal Network dengan IP (HTTP)
```yaml
dashboard:
  url: "http://192.168.1.100"
  verify_ssl: false
  timeout: 30
```

### Contoh 4: Development dengan Port Custom
```yaml
dashboard:
  url: "http://192.168.1.100:8080"
  verify_ssl: false
  timeout: 30
```

---

## 🔧 Setup SSL untuk IP (Opsional)

Jika ingin pakai HTTPS dengan IP:

### 1. Generate Self-Signed Certificate
```bash
# Di dashboard server
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/dashboard.key \
  -out /etc/nginx/ssl/dashboard.crt \
  -subj "/CN=192.168.1.100"
```

### 2. Configure Nginx
```nginx
server {
    listen 443 ssl;
    server_name 192.168.1.100;
    
    ssl_certificate /etc/nginx/ssl/dashboard.crt;
    ssl_certificate_key /etc/nginx/ssl/dashboard.key;
    
    # ... rest of config
}
```

### 3. Agent Config
```yaml
dashboard:
  url: "https://192.168.1.100"
  verify_ssl: false  # Karena self-signed
```

---

## ✅ Jawaban Singkat

**Q: Apakah harus HTTPS?**
A: **Tidak wajib**. Bisa pakai HTTP, terutama untuk internal network.

**Q: Bisa pakai IP saja?**
A: **Bisa!** Bisa pakai IP langsung, contoh: `http://192.168.1.100`

**Q: Apakah tetap bisa?**
A: **Ya, tetap bisa!** Agent akan connect ke dashboard dengan IP atau domain, HTTP atau HTTPS.

---

## 🎯 Rekomendasi

| Environment | Protocol | URL Format | verify_ssl |
|------------|----------|------------|------------|
| Production | HTTPS | Domain | true |
| Internal (Trusted) | HTTPS | IP | false |
| Internal (Very Trusted) | HTTP | IP | false |
| Development | HTTP | IP/Domain | false |

---

**Pilih sesuai kebutuhan dan tingkat keamanan yang diinginkan! 🔒**
