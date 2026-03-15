#!/bin/bash
set -e

DOMAIN="${1:-localhost}"
SSL_DIR="/etc/nginx/ssl"

mkdir -p "${SSL_DIR}"

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout "${SSL_DIR}/nginx.key" \
    -out    "${SSL_DIR}/nginx.crt" \
    -subj "/C=MA/ST=Casa/L=Casablanca/O=42/OU=42/CN=${DOMAIN}"
