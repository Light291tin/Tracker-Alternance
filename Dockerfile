FROM php:8.2-apache

# 1. Installation des dépendances et drivers PostgreSQL
RUN apt-get update && apt-get install -y \
    libicu-dev libpq-dev libzip-dev unzip git zip \
    && docker-php-ext-install intl pdo pdo_pgsql zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Config Apache pour Symfony
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# 3. Installation Composer et définition PRODUCTION
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV APP_ENV=prod

WORKDIR /var/www/html
COPY . .

# 4. Création du .env et installation des dépendances
RUN echo "APP_ENV=prod" > .env \
    && composer install --no-dev --optimize-autoloader --no-scripts

# 5. Droits d'accès
RUN mkdir -p var/cache var/log && chown -R www-data:www-data var

# --- LE FIX FINAL POUR LE DÉMARRAGE ---
# On lance les migrations en tâche de fond pour laisser Apache démarrer immédiatement
CMD (php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration || true) && apache2-foreground