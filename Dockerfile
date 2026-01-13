FROM php:8.2-apache

# 1. Installation des dépendances système et du driver PostgreSQL
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpq-dev \
    libzip-dev \
    unzip \
    git \
    zip \
    && docker-php-ext-install intl pdo_pgsql zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Configuration d'Apache pour Symfony
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 3. Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /var/www/html

# 4. Copie des fichiers
COPY . .

# 5. Création du .env et installation des dépendances
RUN echo "APP_ENV=prod" > .env \
    && composer install --no-dev --optimize-autoloader --no-scripts

# 6. FIX DES PERMISSIONS (LA VERSION STABLE)
# On force la création du dossier var s'il n'existe pas, puis on donne les droits
RUN mkdir -p /var/www/html/var /var/www/html/var/cache /var/www/html/var/log \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 777 /var/www/html/var

# 7. Commande de démarrage
CMD (php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration || true) && apache2-foreground