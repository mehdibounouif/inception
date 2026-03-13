#!/bin/bash
# Entrypoint for the Adminer container.
# Ensures /run/php exists then hands control to php-fpm as PID 1.
set -e

# php-fpm writes its PID file here — directory must exist at startup.
mkdir -p /run/php

echo "Adminer (php-fpm) starting on port 9000."
echo "Access via: https://mbounoui.42.fr/adminer/"
echo "DB host: mariadb | DB name: wordpress"

# exec makes php-fpm PID 1. -F = foreground, never daemonize.
exec php-fpm7.4 -F