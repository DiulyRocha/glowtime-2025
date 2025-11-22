# === Etapa 1: Build ===
FROM php:8.2-fpm AS build

# Instala dependências do sistema
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev \
    nodejs npm \
    && docker-php-ext-install pdo_mysql zip

# Instala Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Copia projeto
WORKDIR /var/www/html
COPY . .

# Instala dependências do Laravel
RUN composer install --no-dev --optimize-autoloader

# Instala dependências do frontend e compila o Vite
RUN npm install && npm run build

# === Etapa 2: Produção ===
FROM php:8.2-fpm

WORKDIR /var/www/html

# Instala extensões PHP
RUN apt-get update && apt-get install -y \
    libzip-dev \
    && docker-php-ext-install pdo_mysql zip

# Copia arquivos do build
COPY --from=build /var/www/html /var/www/html

# Comando final: iniciar PHP-FPM
CMD ["php-fpm"]
