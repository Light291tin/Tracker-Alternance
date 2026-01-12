FROM php:8.2-fpm

# Installation des dépendances système
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libicu-dev \
    libpq-dev \
    && docker-php-ext-install intl pdo pdo_pgsql

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Définition du dossier de travail
WORKDIR /var/www/html

# Copie de tous les fichiers du projet
COPY . .

# Installation des dépendances Symfony
RUN composer install --no-dev --optimize-autoloader

# On donne les droits d'écriture pour le cache et les logs
RUN chown -R www-data:www-data var

# Commande magique pour lancer les migrations PUIS le serveur
CMD php bin/console doctrine:migrations:migrate --no-interaction && php -S 0.0.0.0:80 -t public