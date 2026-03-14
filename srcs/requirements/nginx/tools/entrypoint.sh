#!/bin/bash
set -e

DOMAIN=${DOMAIN_NAME:-localhost}

# Generate the self-signed TLS certificate with the correct CN.
/usr/local/bin/generate-ssl.sh "${DOMAIN}"

# Substitute DOMAIN_NAME into the nginx config template and write the live config.
sed "s/DOMAIN_PLACEHOLDER/${DOMAIN}/g" \
    /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Hand off to nginx as PID 1.
exec nginx -g "daemon off;"