#!/usr/local/bin/bash

domain=$1
export SSL_CERT_FILE=/etc/ssl/certs/rootca.pem
sudo acme.sh --issue --server https://ca.nasa.nycu:9000/acme/acme/directory -d $domain --standalone --force

sudo acme.sh --install-cert -d $domain \
    --key-file       /usr/local/etc/nginx/certs/key.pem  \
    --fullchain-file /usr/local/etc/nginx/certs/cert.pem \
    --force