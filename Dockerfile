# ------------------------------------------------------
# STAGE 1 - Build (Composer + NPM)
# ------------------------------------------------------
FROM php:8.2-fpm AS builder

RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev \
    nodejs npm \
    && docker-php-ext-install pdo_mysql zip

# Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copia o código do projeto
COPY . .

# Instala dependências PHP (sem dev) e otimiza autoloader
RUN composer install --no-dev --optimize-autoloader

# Instala dependências JS e gera o build do Vite
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

# Copia tudo o que foi construído no estágio builder
COPY --from=builder /var/www/html /var/www/html

# Copia configs de Nginx e Supervisor
COPY deploy/nginx.conf /etc/nginx/nginx.conf
COPY deploy/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# Permissões Laravel
RUN chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

# Limpa caches do Laravel
RUN php artisan config:clear && \
    php artisan route:clear && \
    php artisan view:clear && \
    php artisan cache:clear

# Porta exposta no container
EXPOSE 80

# Inicia Supervisor (que vai subir php-fpm e nginx)
CMD ["/usr/bin/supervisord", "-n"]
