# Tahap 1: Composer (build vendor)
FROM php:8.2-fpm AS vendor

# Install dependency system dan ekstensi PHP
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copy file composer
COPY composer.json composer.lock ./

# Jalankan composer install
RUN composer install --no-dev --no-interaction --no-progress --optimize-autoloader

# Tahap 2: Production image
FROM php:8.2-fpm

# Install ekstensi runtime PHP
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql

# Copy source code
COPY . /var/www/html

# Copy vendor dari tahap pertama
COPY --from=vendor /app/vendor /var/www/html/vendor

WORKDIR /var/www/html

# Expose port 8000
EXPOSE 8000

# Jalankan Laravel
CMD php artisan serve --host=0.0.0.0 --port=8000
