#!/bin/bash

# OpenSSL: is a command-line tool and library that handles all things cryptography.
#
# req: certificate request
#
# -x509:
# with : openssl req -x509
# create CSR : Certificate Signing Request -> CA : Certificate Authority -> signed SSL certificate.
# with : openssl req
# self-signed certificate
#
# -nodes stands for "no DES" says "don't encrypt the private key file with a password."
#
# -days 365 : The certificate will be valid for 365 days
#
# -newkey: generate a brand new key pair right now (instead of using an existing one)
# 
# rsa:2048: the type and size of the key to generate
#
# RSA: is the encryption algorithm
# 
# 2048 is the key size in bits
#openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
#	# Tells OpenSSL where to save the private key
#    -keyout /etc/nginx/ssl/nginx.key \
#	# Tells OpenSSL where to save the certificate (pablic key)
#    -out /etc/nginx/ssl/nginx.crt \
#	# Country: Maroc
#	# State: Case
#	# Locality: Casablanca
#	# Organization: 42
#	# Organization Unit: 42
#	# Common Name: mehdibounouif.42.fr



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
