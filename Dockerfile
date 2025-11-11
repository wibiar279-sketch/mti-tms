FROM php:8.2-fpm

# Install system dependencies & ekstensi PHP
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy semua source code Laravel (termasuk artisan)
COPY . .

# Jalankan composer install setelah semua file tersedia
RUN composer install --no-dev --no-interaction --no-progress --optimize-autoloader

# Jalankan optimisasi Laravel
RUN php artisan config:cache || true \
    && php artisan route:cache || true \
    && php artisan view:cache || true

EXPOSE 8000

CMD php artisan serve --host=0.0.0.0 --port=8000
