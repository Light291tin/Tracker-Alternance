FROM php:8.2-apache

# Installation des pilotes Postgres (Crucial pour l'erreur "pilote introuvable")
RUN apt-get update && apt-get install -y \
    libicu-dev libpq-dev libzip-dev unzip git \
    && docker-php-ext-install intl pdo pdo_pgsql zip

# Config Apache
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

# ON FORCE TOUT EN PRODUCTION ICI
ENV APP_ENV=prod
ENV APP_DEBUG=0

WORKDIR /var/www/html
COPY . .

# On crée un fichier .env minimal qui dit juste "JE SUIS EN PROD"
RUN echo "APP_ENV=prod" > .env

# Installation sans les outils de dev (pour éviter les crashs)
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Droits d'accès
RUN mkdir -p var/cache var/log && chown -R www-data:www-data var

# Commande de démarrage avec forçage PROD
CMD php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration --env=prod && apache2-foreground