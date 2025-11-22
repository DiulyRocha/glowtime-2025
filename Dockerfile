# ------------------------------------------------------
# STAGE 1 - Build (Composer + NPM)
# ------------------------------------------------------
FROM php:8.2-fpm AS builder

RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev \
    nodejs npm \
    && docker-php-ext-install pdo_mysql zip

COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --optimize-autoloader
RUN npm install
RUN npm run build


# ------------------------------------------------------
# STAGE 2 - Runtime (Nginx + PHP-FPM)
# ------------------------------------------------------
FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    nginx supervisor libzip-dev zip \
    && docker-php-ext-install pdo_mysql zip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

COPY --from=builder /var/www/html /var/www/html
COPY deploy/nginx.conf /etc/nginx/nginx.conf

# Supervisor controla nginx + php-fpm juntos
COPY deploy/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

RUN mkdir -p /run/php \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

EXPOSE $PORT

CMD ["/usr/bin/supervisord", "-n"]
