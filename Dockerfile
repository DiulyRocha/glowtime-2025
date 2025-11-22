# =========================
# 1) BUILD (Composer + NPM)
# =========================
FROM php:8.2-fpm AS build

# Dependências
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev \
    nodejs npm \
    && docker-php-ext-install pdo_mysql zip

# Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

# Instalar dependências Laravel
RUN composer install --no-dev --optimize-autoloader

# Build do Vite
RUN npm install && npm run build


# =========================
# 2) RUNTIME (Nginx + PHP-FPM)
# =========================
FROM php:8.2-fpm

# Dependências de runtime + Nginx
RUN apt-get update && apt-get install -y \
    nginx libzip-dev zip \
    && docker-php-ext-install pdo_mysql zip \
    && rm -rf /var/lib/apt/lists/*

# Diretório Laravel
WORKDIR /var/www/html

# Copiar app compilado
COPY --from=build /var/www/html /var/www/html

# Copiar configuração do Nginx
COPY deploy/nginx.conf /etc/nginx/nginx.conf

# Permissões
RUN mkdir -p /var/www/html/storage /var/www/html/bootstrap/cache \
    && chown -R www-data:www-data /var/www/html

# Expõe a porta do Nginx
EXPOSE 80

# Iniciar PHP-FPM + NGINX juntos
CMD service nginx start && php-fpm
