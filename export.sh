#!/bin/bash

# Avant tout :
# Il faut mettre le projet dans le dossier spécifié dans PROJECT_DIRECTORY
# Faire correspondre les config du fichier CONFIG avec les SERVER_NAME et SERVER_ALIAS

# -- Structure attendue ---
#   export.sh
#   fichier.conf
#   PROJECT_DIRECTORY/

CONFIG="www.bubble.conf"
DESTINATION_DIRECTORY="www.bubble.mg"
PROJECT_DIRECTORY="projet"
SERVER_NAME="www.bubble.mg"
SERVER_ALIAS="bubble.mg"
IP="10.251.28.157"

cp $CONFIG /etc/apache2/sites-available/

rm -rf /var/www/html/$DESTINATION_DIRECTORY

mkdir -p /var/www/html/$DESTINATION_DIRECTORY

cp -r $PROJECT_DIRECTORY/* /var/www/html/$DESTINATION_DIRECTORY/

# Droits
chown -R www-data:www-data "/var/www/html/$DESTINATION_DIRECTORY"


# Ajoute SERVER_NAME et SERVER_ALIAS uniquement s'ils n'existent pas déjà dans /etc/hosts
if ! grep -qw "$SERVER_NAME" /etc/hosts; then
  echo "$IP $SERVER_NAME" >> /etc/hosts
fi

if ! grep -qw "$SERVER_ALIAS" /etc/hosts; then
  echo "$IP $SERVER_ALIAS" >> /etc/hosts
fi


a2ensite $CONFIG

systemctl restart apache2