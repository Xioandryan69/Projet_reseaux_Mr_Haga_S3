#!/usr/bin/env bash
set -euo pipefail

# bind.sh

IP="10.251.28.157"

BIND_DIR=/etc/bind
BIND_FILE="$BIND_DIR/db.bubble.mg"
HOSTS_FILE=/etc/hosts

echo "Ensuring $BIND_DIR exists (will use sudo if necessary)..."
if [ ! -d "$BIND_DIR" ]; then
  sudo mkdir -p "$BIND_DIR"
fi

if [ -f "$BIND_FILE" ]; then
  echo "Backing up existing $BIND_FILE -> ${BIND_FILE}.bak"
  sudo cp -a "$BIND_FILE" "${BIND_FILE}.bak"
fi

echo "Writing zone file to $BIND_FILE"
sudo tee "$BIND_FILE" > /dev/null <<EOF
;
; BIND data file for bubble.mg
;

	\$TTL	604800
@	IN	SOA	ns1.bubble.mg. admin.bubble.mg. (
				3		; Serial
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

echo "Zone file written."
