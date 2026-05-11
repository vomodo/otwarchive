#!/bin/bash
# Backup MariaDB ao3_production
# Usage: bash scripts/backup.sh
# Cron gợi ý: 0 */6 * * * cd /Users/ducvu/projects/ao3 && bash scripts/backup.sh >> logs/backup.log 2>&1
set -e

DATE=$(date +%Y%m%d_%H%M)
BACKUP_DIR="./data/backups"
BACKUP_FILE="${BACKUP_DIR}/ao3_${DATE}.sql"

mkdir -p "$BACKUP_DIR"
export $(grep -v '^#' .env | xargs)

echo "[$(date)] Starting backup..."

docker exec ao3_db mysqldump \
  -u root \
  -p"${DB_ROOT_PASSWORD}" \
  --single-transaction \
  --quick \
  ao3_production > "$BACKUP_FILE"

gzip "$BACKUP_FILE"
echo "[$(date)] ✅ Backup: ${BACKUP_FILE}.gz ($(du -sh ${BACKUP_FILE}.gz | cut -f1))"

# Xóa backup cũ hơn 7 ngày
find "$BACKUP_DIR" -name "ao3_*.sql.gz" -mtime +7 -delete
echo "[$(date)] 🧹 Old backups cleaned"
