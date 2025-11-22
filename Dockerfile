# ----------- Build Stage (Composer + Node) ---------------
FROM php:8.2-fpm AS build

RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev \
    nodejs npm \
    && docker-php-ext-install pdo_mysql zip

COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --optimize-autoloader
RUN npm install && npm run build

# ----------- Runtime Stage (somente PHP) ---------------
FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    libzip-dev zip \
    && docker-php-ext-install pdo_mysql zip

WORKDIR /var/www/html

COPY --from=build /var/www/html /var/www/html

EXPOSE 8000

# Rodar migrations automaticamente no deploy
RUN php artisan migrate --force || true

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
