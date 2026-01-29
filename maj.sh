#!/bin/bash

IP="10.251.28.157"

Nom="bubble.mg"

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo."
  exit 1
fi

sed -E 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'"$IP"'/g' /etc/bind/db.bubble.mg > /etc/bind/db.new.mg
cp /etc/bind/db.new.mg /etc/bind/db.bubble.mg
rm /etc/bind/db.new.


sudo systemctl restart bind9