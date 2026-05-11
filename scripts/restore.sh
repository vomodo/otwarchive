#!/bin/bash
# Restore MariaDB từ backup
# Usage: bash scripts/restore.sh ./data/backups/ao3_20250511_0600.sql.gz
set -e

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
  echo "Usage: bash scripts/restore.sh <backup-file.sql.gz>"
  echo ""
  echo "Available backups:"
  ls -lh ./data/backups/ao3_*.sql.gz 2>/dev/null || echo "  (none found)"
  exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
  echo "❌ File not found: $BACKUP_FILE"
  exit 1
fi

export $(grep -v '^#' .env | xargs)

echo "⚠️  Restore sẽ XOÁ toàn bộ data hiện tại trong ao3_production"
read -p "Tiếp tục? (yes/no): " confirm
[ "$confirm" = "yes" ] || exit 1

echo "🔄 Restoring from $BACKUP_FILE..."
gunzip -c "$BACKUP_FILE" | docker exec -i ao3_db mysql \
  -u root \
  -p"${DB_ROOT_PASSWORD}" \
  ao3_production

echo "✅ Restore hoàn tất từ: $BACKUP_FILE"
echo "🔄 Restart web để clear cache:"
echo "   docker compose -f docker-compose.prod.yml restart web worker"
