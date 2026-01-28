#!/bin/bash

# Avant tout :
# Il faut mettre le projet dans le dossier spécifié dans PROJECT_DIRECTORY
# Faire correspondre les config du fichier CONFIG avec les SERVER_NAME et SERVER_ALIAS

# -- Structure attendue ---
#   export.sh
#   fichier.conf
#   PROJECT_DIRECTORY/

CONFIG="www.bubbletest.conf"
DESTINATION_DIRECTORY="www.bubbletest.com"
PROJECT_DIRECTORY="projet"
SERVER_NAME="www.bubbletest.com"
SERVER_ALIAS="bubbletest.com"
IP="172.80.1.92"

cp $CONFIG /etc/apache2/sites-available/

rm -rf /var/www/html/$DESTINATION_DIRECTORY

mkdir -p /var/www/html/$DESTINATION_DIRECTORY

cp -r $PROJECT_DIRECTORY/* /var/www/html/$DESTINATION_DIRECTORY/

rm -f temp

touch temp

grep -qxF "$IP $SERVER_NAME" /etc/hosts || echo "$IP $SERVER_NAME" > temp

grep -qxF "$IP $SERVER_ALIAS" /etc/hosts || echo "$IP $SERVER_ALIAS" >> temp

cat /etc/hosts >> temp

cat temp > /etc/hosts

rm temp

a2ensite $CONFIG

systemctl restart apache2