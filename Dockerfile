# ------------------------------------------------------
# STAGE 1 — Build (Composer + NPM)
# ------------------------------------------------------
FROM php:8.2-fpm AS builder

# Instala dependências necessárias
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev \
    nodejs npm \
    && docker-php-ext-install pdo_mysql zip

# Copia o Composer do container oficial
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Copia o projeto
WORKDIR /var/www/html
COPY . .

# Instala dependências PHP (sem dev no Railway)
RUN composer install --no-dev --optimize-autoloader

# Instala dependências JS e gera build do Vite
RUN npm install
RUN npm run build


# ------------------------------------------------------
# STAGE 2 — Runtime (Nginx + PHP-FPM)
# ------------------------------------------------------
FROM php:8.2-fpm

# Instala nginx e supervisor
RUN apt-get update && apt-get install -y \
    nginx supervisor libzip-dev zip \
    && docker-php-ext-install pdo_mysql zip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Copia os arquivos construídos
COPY --from=builder /var/www/html /var/www/html

# Copia as configs
COPY deploy/nginx.conf /etc/nginx/nginx.conf
COPY deploy/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# Permissões necessárias
RUN mkdir -p /run/php && \
    chown -R www-data:www-data /run/php && \
    chmod -R 775 /run/php && \
    chmod -R 775 storage bootstrap/cache

# Railway escuta sempre na porta 80
EXPOSE 80

# Inicia Supervisor (controla Nginx + PHP-FPM)
CMD ["/usr/bin/supervisord", "-n"]
