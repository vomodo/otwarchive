# Deploy Guide — ao3.ducvu.vn

## Yêu cầu
- Mac Mini M4 với OrbStack
- CF Tunnel `mac-mini-m4` đang active
- Resend API key

---

## Lần đầu deploy

### 1. Clone repo
```bash
git clone https://github.com/vomodo/otwarchive /Users/ducvu/projects/ao3
cd /Users/ducvu/projects/ao3
```

### 2. Tạo file .env
```bash
cp .env.example .env
nano .env
```

**Bắt buộc phải điền:**
- `DB_ROOT_PASSWORD` / `DB_PASSWORD` — đặt password mạnh
- `DATABASE_URL` — cập nhật password trùng với `DB_PASSWORD`
- `SECRET_KEY_BASE` — chạy: `openssl rand -hex 64`
- `DEVISE_SECRET_KEY` — chạy: `openssl rand -hex 64`
- `SMTP_PASSWORD` — Resend API key (lấy tại resend.com)
- `ACTIVE_RECORD_ENCRYPTION_*` — xem bước 3

### 3. Chạy init script
```bash
bash scripts/init-prod.sh
```

Nếu script báo cần generate encryption keys:
```bash
docker compose -f docker-compose.prod.yml run --rm web bundle exec rails db:encryption:init
# Copy 3 dòng KEY output vào .env, rồi chạy lại:
bash scripts/init-prod.sh
```

### 4. Tạo admin account
```bash
docker compose -f docker-compose.prod.yml run --rm web \
  bundle exec rails runner \
  "User.create!(login: 'admin', email: 'vomodojp@gmail.com', password: 'your_password', password_confirmation: 'your_password', age_over_18: true)"
```

### 5. CF Tunnel
```
one.dash.cloudflare.com → Networks → Tunnels → mac-mini-m4
→ Public Hostnames → Add:
  Subdomain : ao3
  Domain    : ducvu.vn
  Service   : http://localhost:3000
```

---

## Update code

```bash
cd /Users/ducvu/projects/ao3
git pull
docker compose -f docker-compose.prod.yml run --rm web bundle exec rails db:migrate
docker compose -f docker-compose.prod.yml restart web worker
```

Nếu có thay đổi Gemfile:
```bash
docker compose -f docker-compose.prod.yml build web
docker compose -f docker-compose.prod.yml up -d
```

---

## Nhận update từ AO3 gốc

```bash
git remote add upstream https://github.com/otwcode/otwarchive
git fetch upstream
git merge upstream/main
git push
```

---

## Navicat — Kết nối database

MariaDB chạy trong container `ao3_db`, không expose port mặc định.
Để connect Navicat, tạm thời thêm vào `docker-compose.prod.yml` trong service `db`:
```yaml
ports:
  - "3306:3306"
```
Sau đó:
```
New Connection → MySQL
Host     : localhost
Port     : 3306
User     : root
Password : DB_ROOT_PASSWORD trong .env
Database : ao3_production
```
Xong việc thì xoá `ports` đi.

---

## Monitoring

```bash
# Logs realtime
docker compose -f docker-compose.prod.yml logs -f web
docker compose -f docker-compose.prod.yml logs -f worker

# RAM usage
docker stats
```

---

## Backup tự động (cron)

```bash
crontab -e
# Thêm:
0 */6 * * * cd /Users/ducvu/projects/ao3 && bash scripts/backup.sh >> logs/backup.log 2>&1
```
