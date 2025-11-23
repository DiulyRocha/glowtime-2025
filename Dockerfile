# ------------------------------------------------------
# STAGE 1 - Build (Composer + NPM / Vite)
# ------------------------------------------------------
FROM php:8.2-fpm AS builder

# Dependências necessárias para Laravel + Vite
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libonig-dev libxml2-dev \
    nodejs npm \
    && docker-php-ext-install pdo_mysql zip \
    && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Pasta do app
WORKDIR /var/www/html

# Copia o código do projeto
COPY . .

# Instala dependências PHP (sem dev) e otimiza autoloader
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-progress

# Instala dependências JS e gera o build do Vite
RUN npm install
RUN npm run build


# ------------------------------------------------------
# STAGE 2 - Runtime (Nginx + PHP-FPM + Supervisor)
# ------------------------------------------------------
FROM php:8.2-fpm

# Instala Nginx, Supervisor e extensões necessárias
RUN apt-get update && apt-get install -y \
    nginx supervisor libzip-dev zip \
    && docker-php-ext-install pdo_mysql zip \
    && rm -rf /var/lib/apt/lists/*

# Pasta do app
WORKDIR /var/www/html

# Copia tudo que foi gerado no estágio de build
COPY --from=builder /var/www/html /var/www/html

# Copia configs de Nginx e Supervisor
COPY deploy/nginx.conf /etc/nginx/nginx.conf
COPY deploy/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# Permissões Laravel
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Porta exposta
EXPOSE 80
RUN chmod -R 777 storage bootstrap/cache

# Inicia Supervisor (que sobe php-fpm e nginx)
CMD ["/usr/bin/supervisord", "-n"]
