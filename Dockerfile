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

# Set permission Laravel
RUN chmod -R 775 storage bootstrap/cache

# Atur DocumentRoot ke folder public
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# Izinkan .htaccess Laravel berfungsi
RUN a2enmod rewrite
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Optimisasi Laravel (boleh di-skip kalau error APP_KEY)
RUN php artisan config:cache || true \
    && php artisan route:cache || true \
    && php artisan view:cache || true

EXPOSE 80

CMD ["apache2-foreground"]
