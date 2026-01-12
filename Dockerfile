FROM php:8.2-apache

# 1. Installation des dépendances système (Postgres + Zip + ICU)
RUN apt-get update && apt-get install -y \
    git unzip libicu-dev libpq-dev libzip-dev zip \
    && docker-php-ext-install intl pdo pdo_pgsql zip

# 2. Activation du module Apache Rewrite (Indispensable pour Symfony)
RUN a2enmod rewrite

# 3. Configuration d'Apache pour pointer sur le dossier /public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 4. Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /var/www/html
COPY . .

# 5. Installation des dépendances Symfony
RUN composer install --no-dev --optimize-autoloader --no-scripts

# 6. Droits d'accès et nettoyage
RUN mkdir -p var/cache var/log && chown -R www-data:www-data var

# 7. Commande finale : Migrations + Lancement Apache au premier plan
CMD php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration && apache2-foreground