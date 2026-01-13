FROM php:8.2-apache

# 1. Installation des dépendances et drivers avec nettoyage immédiat
RUN apt-get update && apt-get install -y \
    libicu-dev libpq-dev libzip-dev unzip git zip \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install intl pdo pdo_pgsql pgsql zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Config Apache
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# 3. Installation Composer et définition PROD
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV APP_ENV=prod

WORKDIR /var/www/html
COPY . .

# 4. Forcer le fichier .env et vider le cache Symfony
RUN echo "APP_ENV=prod" > .env

# 5. Installation des dépendances
RUN composer install --no-dev --optimize-autoloader --no-scripts

# 6. Droits d'accès
RUN mkdir -p var/cache var/log && chown -R www-data:www-data var

# --- LE FIX CRUCIAL ---
# On crée un script pour s'assurer que le driver est chargé au démarrage
CMD php -d extension=pdo_pgsql bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration --env=prod && apache2-foreground