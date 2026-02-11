#!/bin/bash

# Wait for MariaDB to be ready
sleep 10

# Download WordPress CLI
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Go to web directory
cd /var/www/html

# Download WordPress
if [ ! -f wp-config.php ]; then
    wp core download --allow-root

    # Create wp-config.php
    wp config create \
        --dbname=${DB_NAME} \
        --dbuser=${DB_USER} \
        --dbpass=${DB_PASSWORD} \
        --dbhost=mariadb:3306 \
        --allow-root

    # Install WordPress
    wp core install \
        --url=${DOMAIN_NAME} \
        --title="Inception" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --allow-root

    # Create second user
    wp user create ${WP_USER} ${WP_USER_EMAIL} \
        --user_pass=${WP_PASSWORD} \
        --role=author \
        --allow-root
fi

# Create necessary directories
mkdir -p /run/php

# Start PHP-FPM in foreground
exec php-fpm7.4 -F
