#!/bin/bash
FILE="/etc/bind/db.bubble.mg"
IP="8.8.8.8"

grep -qxF "$1   IN  A   $IP" "$FILE" || echo "$1   IN  A   $IP" >> "$FILE"