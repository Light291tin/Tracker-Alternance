FROM php:8.2-apache

# 1. Installation des dépendances et drivers Postgres (Correction Driver)
RUN apt-get update && apt-get install -y \
    libicu-dev libpq-dev libzip-dev unzip git \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install intl pdo pdo_pgsql pgsql zip

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

# 4. Fix .env manquant : on crée le fichier pour Symfony
RUN echo "APP_ENV=prod" > .env

# 5. Installation des dépendances
RUN composer install --no-dev --optimize-autoloader --no-scripts

# 6. Droits d'accès
RUN mkdir -p var/cache var/log && chown -R www-data:www-data var

# 7. Démarrage (Migrations + Apache)
CMD php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration && apache2-foreground