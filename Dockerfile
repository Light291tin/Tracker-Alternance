FROM php:8.2-apache

# 1. Dépendances système
RUN apt-get update && apt-get install -y \
    libicu-dev libpq-dev libzip-dev unzip git zip \
    && docker-php-ext-install intl pdo_pgsql zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Config Apache
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 3. Installation de Composer et du projet
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
WORKDIR /var/www/html
COPY . .

# 4. Installation sans scripts (on ne veut pas créer de cache maintenant)
RUN echo "APP_ENV=prod" > .env \
    && composer install --no-dev --optimize-autoloader --no-scripts

# 5. Redirection du Cache vers /tmp (Crucial)
ENV SYMFONY_CACHE_DIR=/tmp/cache
ENV SYMFONY_LOG_DIR=/tmp/logs

# 6. Droits sur le code source
RUN chown -R www-data:www-data /var/www/html

# 7. LA COMMANDE MIRACLE
# On vide /tmp au démarrage pour que www-data puisse tout recréer
CMD rm -rf /tmp/cache/* /tmp/logs/* && \
    (php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration || true) && \
    apache2-foreground