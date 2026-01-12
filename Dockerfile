FROM php:8.2-apache

# 1. Installation des dépendances et pilotes Postgres
RUN apt-get update && apt-get install -y \
    libicu-dev libpq-dev libzip-dev unzip git \
    && docker-php-ext-install intl pdo pdo_pgsql zip

# 2. Configuration Apache (module rewrite pour Symfony)
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# 3. Installation de Composer et définition de l'environnement PRODUCTION
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV APP_ENV=prod
ENV APP_DEBUG=0

WORKDIR /var/www/html
COPY . .

# --- LE FIX POUR LE FICHIER .env ---
# On crée un fichier .env qui définit explicitement l'environnement de production
RUN echo "APP_ENV=prod\nAPP_DEBUG=0" > .env
# -----------------------------------

# 4. Installation des dépendances
RUN composer install --no-dev --optimize-autoloader --no-scripts

# 5. Droits d'accès sur les dossiers vitaux
RUN mkdir -p var/cache var/log && chown -R www-data:www-data var

# 6. Démarrage : Migrations SQL forcées en prod + Serveur Apache
CMD php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration --env=prod && apache2-foreground