FROM php:8.2-apache

# 1. Installation des dépendances et drivers Postgres
RUN apt-get update && apt-get install -y \
    libicu-dev libpq-dev libzip-dev unzip git \
    && docker-php-ext-install intl pdo pdo_pgsql zip

# 2. Config Apache
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# 3. Installation Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV APP_ENV=prod

WORKDIR /var/www/html
COPY . .

# --- LE FIX DÉFINITIF ---
# On crée un fichier .env factice pour empêcher Symfony de planter
RUN echo "APP_ENV=prod" > .env
# ------------------------

# 4. Installation des dépendances
RUN composer install --no-dev --optimize-autoloader --no-scripts

# 5. Droits d'accès
RUN mkdir -p var/cache var/log && chown -R www-data:www-data var

# 6. Démarrage (Migrations + Apache)
CMD php bin/console doctrine:migrations:migrate --no-interaction && apache2-foreground