#!/bin/bash
HTTPSCONFIG="www.bubble.https.conf"
CERTIFICAT="www.bubble.crt"
KEY="www.bubble.key"

cp $HTTPSCONFIG /etc/apache2/sites-available/ 

openssl req -x509 -nodes -days 365 \
		-newkey rsa:2048 \
		-keyout /etc/apache2/ssl/$KEY \
		-out /etc/apache2/ssl/$CERTIFICAT

a2enmod ssl

a2ensite $HTTPSCONFIG

systemctl restart apache2