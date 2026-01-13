FROM php:8.2-apache

# 1. Installation des outils et de PostgreSQL
RUN apt-get update && apt-get install -y \
    libicu-dev libpq-dev libzip-dev unzip git zip \
    && docker-php-ext-install intl pdo_pgsql zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Config Apache pour Symfony
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 3. Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
WORKDIR /var/www/html
COPY . .

# 4. Installation des dépendances (sans générer le cache tout de suite)
RUN echo "APP_ENV=prod" > .env \
    && composer install --no-dev --optimize-autoloader --no-scripts

# 5. CONFIGURATION DU CACHE DANS /TMP (LE FIX FINAL)
# On crée les dossiers dans /tmp et on donne tous les droits
RUN mkdir -p /tmp/cache /tmp/logs && chmod -R 777 /tmp/cache /tmp/logs
# On force Symfony à utiliser ces dossiers
ENV SYMFONY_CACHE_DIR=/tmp/cache
ENV SYMFONY_LOG_DIR=/tmp/logs

# 6. Droits sur le reste du code pour Apache
RUN chown -R www-data:www-data /var/www/html

# 7. Démarrage
CMD (php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration || true) && apache2-foreground