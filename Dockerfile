FROM php:8.2-fpm

# Install system dependencies dan ekstensi PHP yang dibutuhkan
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy file composer terlebih dahulu
COPY composer.json composer.lock ./

# Jalankan composer install
RUN composer install --no-dev --no-interaction --no-progress --optimize-autoloader

# Copy seluruh source code Laravel
COPY . .

# Expose port default Laravel
EXPOSE 8000

# Jalankan Laravel
CMD php artisan serve --host=0.0.0.0 --port=8000
