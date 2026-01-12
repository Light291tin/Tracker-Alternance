FROM php:8.2-cli

# Installation des dépendances système nécessaires
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libicu-dev \
    libpq-dev \
    libzip-dev \
    zip \
    && docker-php-ext-install intl pdo pdo_pgsql zip

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# On définit une variable pour autoriser Composer à tourner en tant que root
ENV COMPOSER_ALLOW_SUPERUSER=1

# Copie des fichiers du projet
COPY . .

# Installation des dépendances avec nettoyage du cache pour éviter les erreurs
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Création des dossiers de cache et logs avec les bons droits
RUN mkdir -p var/cache var/log && chown -R www-data:www-data var

# Expose le port 80
EXPOSE 80

# Commande de démarrage (Migrations + Serveur)
CMD php bin/console doctrine:migrations:migrate --no-interaction && php -S 0.0.0.0:80 -t public