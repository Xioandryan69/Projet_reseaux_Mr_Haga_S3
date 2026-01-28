#!/bin/bash
./export.sh
./exportHttps.sh
./bind.sh
sudo systemctl restart apache2
sudo systemctl restart bind9