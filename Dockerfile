FROM php:8.2-apache

# 1. Installation des dépendances système
RUN apt-get update && apt-get install -y \
    libicu-dev libpq-dev libzip-dev unzip git zip \
    && docker-php-ext-install intl pdo_pgsql zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Configuration d'Apache pour pointer vers /public
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 3. Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
WORKDIR /var/www/html

# 4. Copie des fichiers et installation
COPY . .
RUN echo "APP_ENV=prod" > .env \
    && composer install --no-dev --optimize-autoloader --no-scripts

# 5. Redirection du Cache vers /tmp (Crucial pour Render)
ENV SYMFONY_CACHE_DIR=/tmp/cache
ENV SYMFONY_LOG_DIR=/tmp/logs

# 6. Droits sur le code source
RUN chown -R www-data:www-data /var/www/html

# 7. LA COMMANDE DE DÉMARRAGE (CORRECTIF PERMISSIONS)
# Commande de démarrage corrigée
CMD mkdir -p /tmp/cache /tmp/logs && \
    chown -R www-data:www-data /tmp/cache /tmp/logs && \
    chmod -R 777 /tmp/cache /tmp/logs && \
    (php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration || true) && \
    apache2-foreground