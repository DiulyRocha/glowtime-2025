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
COPY deploy/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# 🔹 Cria o diretório correto do socket do PHP-FPM
RUN mkdir -p /var/run/php && \
    chown -R www-data:www-data /var/run/php && \
    chmod -R 775 /var/run/php && \
    chmod -R 775 storage bootstrap/cache

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n"]
