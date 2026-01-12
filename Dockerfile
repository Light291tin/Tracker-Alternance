FROM php:8.2-cli

# Installation des dépendances système indispensables (git, zip, et drivers Postgres)
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libicu-dev \
    libpq-dev \
    && docker-php-ext-install intl pdo pdo_pgsql

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copie de tous les fichiers du projet
COPY . .

# Installation des dépendances Symfony
RUN composer install --no-dev --optimize-autoloader

# Création des dossiers nécessaires et droits d'accès
RUN mkdir -p var/cache var/log && chown -R www-data:www-data var

# Expose le port 80 pour Render
EXPOSE 80

# Commande finale : Migrations SQL + Lancement du serveur interne sur le port 80
CMD php bin/console doctrine:migrations:migrate --no-interaction && php -S 0.0.0.0:80 -t public