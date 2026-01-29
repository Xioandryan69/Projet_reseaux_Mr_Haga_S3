#!/bin/bash
# Ajoute dans /etc/hosts la résolution pour www.bubbletest.com et bubbletest.com
# Usage: sudo ./add_hosts_client.sh [IP]
IP="${1:-10.251.28.227}"
HOSTS="/etc/hosts"
BACKUP="/etc/hosts.bak.$(date +%s)"

if [ "$EUID" -ne 0 ]; then
  echo "Exécuter avec sudo : sudo $0 [IP]"
  exit 1
fi

cp "$HOSTS" "$BACKUP"
# Supprime anciennes lignes contenant bubbletest
sed -i '/bubble/d' "$HOSTS"
# Ajoute la nouvelle ligne
echo "$IP www.bubble.mg bubble.mg" >> "$HOSTS"
echo "Hosts mis à jour -> $IP www.bubble.mg bubble.mg (backup: $BACKUP)"