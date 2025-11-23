#!/bin/sh

echo "Gerando .env a partir das variáveis do Railway..."

cat <<EOF > /var/www/html/.env
APP_NAME=GlowTime
APP_ENV=production
APP_KEY=${APP_KEY}
APP_DEBUG=false
APP_URL=${APP_URL}

LOG_CHANNEL=stack

DB_CONNECTION=mysql
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}

CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
EOF

php artisan config:clear
php artisan route:clear
php artisan view:clear

exec "$@"
