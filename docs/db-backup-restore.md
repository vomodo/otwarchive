# Database Backup & Restore — AO3 Vietnam

## Strategy
- Backup mỗi 6 giờ → `./data/backups/ao3_YYYYMMDD_HHMM.sql.gz`
- Giữ 7 ngày rolling
- MariaDB 10.5.4 trong container `ao3_db`

---

## Backup thủ công
```bash
cd /Users/ducvu/projects/ao3
bash scripts/backup.sh
```

---

## Restore
```bash
bash scripts/restore.sh ./data/backups/ao3_20250511_0600.sql.gz
```

---

## Backup tự động (cron)
```bash
crontab -e
# Thêm:
0 */6 * * * cd /Users/ducvu/projects/ao3 && bash scripts/backup.sh >> logs/backup.log 2>&1
```

---

## Migrate lên VPS

```bash
# 1. Copy backup lên VPS
rsync -avz ./data/backups/ user@vps:/path/to/ao3/data/backups/

# 2. Restore trên VPS
bash scripts/restore.sh ./data/backups/ao3_latest.sql.gz

# 3. Copy uploads
rsync -avz ./data/uploads/ user@vps:/path/to/ao3/data/uploads/
```

---

## Portability
- `./data/mysql/` — raw MariaDB files (bind mount, nhanh)
- `./data/backups/` — SQL dumps (portable, dùng để migrate)
- `./data/uploads/` — user uploaded files

Khi chuyển platform: dùng SQL dump, **không copy raw data files**.
