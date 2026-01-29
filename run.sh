#!/usr/bin/env bash
set -euo pipefail

# run.sh — copie index.php et samba.php dans les sites sous /var/www/html et redémarre services
# Usage: sudo ./run.sh

if [ "$EUID" -ne 0 ]; then
  echo "Exécuter avec sudo"
  exit 1
fi

PROJECT_DIR="/home/itu/Documents/S3/Mr Haga/Projet_reseaux_Mr_Haga_S3/projet"
SRC_INDEX="$PROJECT_DIR/index.php"
SRC_SAMBA="$PROJECT_DIR/samba.php"
TARGET_BASE="/var/www/html"

# vérifications simple
if [ ! -f "$SRC_INDEX" ] || [ ! -f "$SRC_SAMBA" ]; then
  echo "Fichiers source introuvables dans $PROJECT_DIR"
  [ ! -f "$SRC_INDEX" ] && echo "  manquant: index.php"
  [ ! -f "$SRC_SAMBA" ] && echo "  manquant: samba.php"
  exit 1
fi

echo "Copie des fichiers vers les sites dans $TARGET_BASE ..."

count=0
for d in "$TARGET_BASE"/*; do
  [ -d "$d" ] || continue
  # ignore common system dirs si besoin
  dirname="$(basename "$d")"
  # éviter copier dans racine web si c'est la racine (mais on veut copier dans chaque site)
  echo " -> $d"
  cp -f "$SRC_INDEX" "$d/index.php"
  cp -f "$SRC_SAMBA" "$d/samba.php"
  chown www-data:www-data "$d/index.php" "$d/samba.php"
  chmod 644 "$d/index.php" "$d/samba.php"
  count=$((count+1))
done

# Si aucun site trouvé, on crée le site par défaut www.bubble.mg et copie
if [ "$count" -eq 0 ]; then
  DEFAULT_SITE="$TARGET_BASE/www.bubble.mg"
  echo "Aucun site existant trouvé — création de $DEFAULT_SITE"
  mkdir -p "$DEFAULT_SITE"
  cp -f "$SRC_INDEX" "$DEFAULT_SITE/index.php"
  cp -f "$SRC_SAMBA" "$DEFAULT_SITE/samba.php"
  chown -R www-data:www-data "$DEFAULT_SITE"
  chmod -R 755 "$DEFAULT_SITE"
  count=1
fi

echo "Copies terminées ($count répertoires)."

# optionnel : activer le site si conf existe dans le projet
if [ -f "/home/itu/Documents/S3/Mr Haga/Projet_reseaux_Mr_Haga_S3/www.bubble.conf" ]; then
  cp -f "/home/itu/Documents/S3/Mr Haga/Projet_reseaux_Mr_Haga_S3/www.bubble.conf" /etc/apache2/sites-available/ || true
  a2ensite www.bubble.conf >/dev/null 2>&1 || true
fi
if [ -f "/home/itu/Documents/S3/Mr Haga/Projet_reseaux_Mr_Haga_S3/www.bubble.https.conf" ]; then
  cp -f "/home/itu/Documents/S3/Mr Haga/Projet_reseaux_Mr_Haga_S3/www.bubble.https.conf" /etc/apache2/sites-available/ || true
  a2ensite www.bubble.https.conf >/dev/null 2>&1 || true
fi

echo "Redémarrage des services (apache2, bind9, smbd)..."
systemctl restart apache2 || echo "apache2 restart échoué"
systemctl restart bind9 || echo "bind9 restart échoué"
# restart samba services (system may have only smbd)
systemctl restart smbd nmbd >/dev/null 2>&1 || systemctl restart smbd || echo "samba restart échoué"

echo "Terminé."
exit 0