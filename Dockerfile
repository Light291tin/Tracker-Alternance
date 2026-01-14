FROM php:8.2-apache

# 1. Installation des outils
RUN apt-get update && apt-get install -y \
    libicu-dev libpq-dev libzip-dev unzip git zip \
    && docker-php-ext-install intl pdo_pgsql zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Config Apache
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 3. Installation de Composer et fichiers
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
WORKDIR /var/www/html
COPY . .

# 4. Installation SANS scripts (pour que root ne crée aucun cache)
RUN echo "APP_ENV=prod" > .env \
    && composer install --no-dev --optimize-autoloader --no-scripts

# 5. Droits sur le dossier projet
RUN chown -R www-data:www-data /var/www/html

# 6. REDIRECTION CACHE
ENV SYMFONY_CACHE_DIR=/tmp/cache
ENV SYMFONY_LOG_DIR=/tmp/logs

# 7. LA COMMANDE DE DÉMARRAGE (LE SEUL VRAI FIX)
# On donne les droits sur /tmp à www-data au démarrage du service
CMD mkdir -p /tmp/cache /tmp/logs && \
    chown -R www-data:www-data /tmp/cache /tmp/logs && \
    chmod -R 777 /tmp/cache /tmp/logs && \
    (php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration || true) && \
    apache2-foreground