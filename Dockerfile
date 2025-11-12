# Gunakan PHP + Apache (bukan FPM)
FROM php:8.2-apache

# Install dependency sistem & ekstensi PHP
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy source code Laravel
COPY . .

# Install dependency Laravel
RUN composer install --no-dev --no-interaction --no-progress --optimize-autoloader

# Pastikan folder storage dan bootstrap/cache bisa ditulis
RUN chmod -R 775 storage bootstrap/cache

# Laravel optimization (boleh di-skip kalau build awal gagal)
RUN php artisan config:cache || true \
    && php artisan route:cache || true \
    && php artisan view:cache || true

# Expose port 80 (default Apache)
EXPOSE 80

# Apache otomatis serve folder public/
CMD ["apache2-foreground"]
