#!/usr/bin/env bash
set -euo pipefail

# Usage: sudo ./create_site.sh www.bubble.mg /chemin/vers/projet [IP]
DOMAIN="$1"
PROJECT_DIR="${2:-/home/itu/Documents/S3/Mr Haga/Projet_reseaux_Mr_Haga_S3/projet}"
IP="${3:-10.251.28.227}"

if [ -z "$DOMAIN" ]; then
  echo "Usage: $0 <domain> [project_dir] [IP]"
  exit 1
fi

# validation simple
if ! [[ "$DOMAIN" =~ ^[a-zA-Z0-9.-]+$ ]]; then
  echo "Domain invalide"
  exit 1
fi

SITE_NAME="$DOMAIN"
SITE_DIR="/var/www/html/$SITE_NAME"
CONF_FILE="/etc/apache2/sites-available/${SITE_NAME}.conf"

# crée dossier site et copie projet
mkdir -p "$SITE_DIR"
cp -r "$PROJECT_DIR"/* "$SITE_DIR"/
chown -R www-data:www-data "$SITE_DIR"

# crée VirtualHost minimal
cat > "$CONF_FILE" <<EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    ServerAlias ${DOMAIN#*.}
    DocumentRoot $SITE_DIR

    ErrorLog \${APACHE_LOG_DIR}/$SITE_NAME-error.log
    CustomLog \${APACHE_LOG_DIR}/$SITE_NAME-access.log combined

    <Directory $SITE_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# active le site et reload Apache
a2ensite "${SITE_NAME}.conf" >/dev/null 2>&1 || true
systemctl reload apache2

# si domaine sous bubble.mg, ajoute enregistrement A via add_subdomain.sh
if [[ "$DOMAIN" == *.bubble.mg ]]; then
  SUB="${DOMAIN%%.bubble.mg}"
  # gère cas 'bubble.mg' -> sous ' @ ' (not handled here); on ajoute 'www' ou autre
  if [ "$SUB" = "bubble" ] || [ -z "$SUB" ]; then
    # domaine racine : rien à ajouter (A déjà dans zone)
    echo "Domaine racine bubble.mg, aucune entrée sub ajoutée."
  else
    # appel add_subdomain.sh via sudo (script doit exister)
    /usr/bin/sudo /home/itu/Documents/S3/Mr\ Haga/Projet_reseaux_Mr_Haga_S3/add_subdomain.sh "$SUB" "$IP"
  fi
fi

echo "Site créé: $DOMAIN -> $SITE_DIR"
exit 0