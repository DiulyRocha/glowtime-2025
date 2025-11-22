# -------------------------------------------------------
# STAGE 1 — Build (Composer + Node para Vite)
# -------------------------------------------------------
FROM php:8.2-fpm AS build

RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev \
    nodejs npm \
    && docker-php-ext-install pdo_mysql zip

COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

# Instala dependências PHP
RUN composer install --no-dev --optimize-autoloader

# Compila assets do Vite
RUN npm install && npm run build

# -------------------------------------------------------
# STAGE 2 — Runtime (PHP-FPM + Nginx)
# -------------------------------------------------------
FROM php:8.2-fpm AS runtime

RUN apt-get update && apt-get install -y \
    nginx libzip-dev zip \
    && docker-php-ext-install pdo_mysql zip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Copia o projeto e os assets buildados
COPY --from=build /var/www/html /var/www/html

# Copia configuração do Nginx
COPY deploy/nginx.conf /etc/nginx/nginx.conf

# Cria diretórios necessários
RUN mkdir -p /var/www/html/storage /var/www/html/bootstrap/cache \
    && chown -R www-data:www-data /var/www/html

EXPOSE 80

# Inicia PHP-FPM e Nginx juntos
CMD service nginx start && php-fpm
