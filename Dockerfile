# Gunakan image PHP 8.2 dengan Apache
FROM php:8.2-apache

# Install dependency sistem
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev libssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo_mysql bcmath zip opcache \
    && a2enmod rewrite

# Atur working directory
WORKDIR /var/www/html

# Copy semua file project ke dalam container
COPY . .

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install dependensi Laravel (tanpa dev)
RUN composer install --no-dev --optimize-autoloader

# Pastikan permission storage & cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Salin file environment (opsional, Railway biasanya inject langsung)
# COPY .env.example .env

# Expose port
EXPOSE 80

# Jalankan Apache
CMD ["apache2-foreground"]
