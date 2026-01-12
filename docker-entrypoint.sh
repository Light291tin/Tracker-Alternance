#!/bin/bash
# Exécuter les migrations
php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration
# Lancer Apache en mode normal
exec apache2-foreground