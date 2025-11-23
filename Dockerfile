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

# Instala dependências PHP (sem dev) e otimiza autoload
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

# Copia tudo do estágio builder (já compilado)
COPY --from=builder /var/www/html /var/www/html

# Copia configs de Nginx e Supervisor
COPY deploy/nginx.conf /etc/nginx/nginx.conf
COPY deploy/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# Copia o entrypoint
COPY deploy/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Ajusta permissões Laravel
RUN chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

# Expõe a porta usada pelo Nginx
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-n"]
