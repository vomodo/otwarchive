#!/bin/bash
# First-time production setup cho ao3.ducvu.vn
# Usage: bash scripts/init-prod.sh
set -e

echo "=== AO3 Vietnam — Production Init ==="

# 1. Kiểm tra .env
if [ ! -f .env ]; then
  echo "❌ File .env chưa tồn tại. Tạo từ .env.example:"
  echo "   cp .env.example .env && nano .env"
  exit 1
fi
echo "✅ .env exists"

# 2. Tạo thư mục data
mkdir -p data/mysql data/redis data/es data/uploads data/backups logs
echo "✅ Directories created"

# 3. Copy database config
cp config/docker/database.prod.yml config/database.yml
echo "✅ database.yml set to production"

# 4. Build image
echo "🔨 Building Docker image (lần đầu ~10-15 phút)..."
docker compose -f docker-compose.prod.yml build web

# 5. Start infrastructure services trước
echo "🚀 Starting DB, Redis, ES, Memcached..."
docker compose -f docker-compose.prod.yml up -d db redis es mc

# 6. Chờ DB sẵn sàng
echo "⏳ Waiting for MariaDB to be ready..."
export $(grep -v '^#' .env | xargs)
until docker exec ao3_db mysqladmin ping -u root -p"${DB_ROOT_PASSWORD}" --silent 2>/dev/null; do
  sleep 2
done
echo "✅ MariaDB ready"

# 7. Precompile assets
echo "📦 Precompiling assets..."
docker compose -f docker-compose.prod.yml run --rm web bundle exec rails assets:precompile

# 8. Run migrations
echo "🗄️  Running database migrations..."
docker compose -f docker-compose.prod.yml run --rm web bundle exec rails db:create db:migrate

# 9. Generate encryption keys nếu chưa có
echo ""
echo "🔑 Nếu ACTIVE_RECORD_ENCRYPTION_* trong .env còn trống, chạy:"
echo "   docker compose -f docker-compose.prod.yml run --rm web bundle exec rails db:encryption:init"
echo "   Rồi copy output vào .env và chạy lại script này"
echo ""

# 10. Start all services
echo "🚀 Starting all services..."
docker compose -f docker-compose.prod.yml up -d

echo ""
echo "✅ Done! App đang chạy tại http://localhost:3000"
echo "📡 CF Tunnel: thêm hostname ao3.ducvu.vn → http://localhost:3000"
echo "📋 Xem logs: docker compose -f docker-compose.prod.yml logs -f web"
