# ...existing code...
#!/usr/bin/env bash
set -euo pipefail

# bind.sh

IP="10.251.28.227"

BIND_DIR=/etc/bind
BIND_FILE="$BIND_DIR/db.bubble.mg"

echo "Ensuring $BIND_DIR exists (will use sudo if necessary)..."
if [ ! -d "$BIND_DIR" ]; then
  sudo mkdir -p "$BIND_DIR"
fi

# Si fichier existant, récupérer le serial actuel (numéro précédant "; Serial")
if [ -f "$BIND_FILE" ]; then
  current_serial=$(grep -m1 -oE '[0-9]+[[:space:]]*;[[:space:]]*Serial' "$BIND_FILE" 2>/dev/null | grep -oE '[0-9]+' || true)
  if [ -z "$current_serial" ]; then
    # fallback : chercher premier nombre dans le bloc SOA
    current_serial=$(sed -n '/SOA/,/\)/p' "$BIND_FILE" | tr -d '\n' | grep -oE '[0-9]+' | head -n1 || true)
  fi
else
  current_serial=""
fi

if [ -z "$current_serial" ]; then
  NEW_SERIAL=1
else
  NEW_SERIAL=$((current_serial + 1))
fi

if [ -f "$BIND_FILE" ]; then
  echo "Backing up existing $BIND_FILE -> ${BIND_FILE}.bak"
  sudo cp -a "$BIND_FILE" "${BIND_FILE}.bak"
fi

echo "Writing zone file to $BIND_FILE (serial: $NEW_SERIAL)"
sudo tee "$BIND_FILE" > /dev/null <<EOF
;
; BIND data file for bubble.mg
;

    \$TTL	604800
@	IN	SOA	ns1.bubble.mg. admin.bubble.mg. (
                ${NEW_SERIAL}	; Serial
            604800		; Refresh
            86400		; Retry
            2419200		; Expire
            604800 )	; Negative Cache TTL
;
@		IN	NS	ns1.bubble.mg.
@		IN	A	$IP
ns1.bubble.mg	IN	A	$IP
www		IN	A	$IP
EOF

echo "Zone file written (serial ${NEW_SERIAL}). Reloading bind9..."
sudo systemctl reload bind9
# ...existing code...