#!/bin/bash

echo "Waiting for MariaDB to be ready..."

# Wait for MariaDB to be accessible
max_tries=30
count=0

while [ $count -lt $max_tries ]; do
    if mysqladmin ping -h"mariadb" --silent 2>/dev/null; then
        echo "MariaDB is ready!"
        break
    fi
    count=$((count + 1))
    echo "Attempt $count/$max_tries: MariaDB not ready yet, waiting..."
    sleep 2
done

if [ $count -eq $max_tries ]; then
    echo "ERROR: MariaDB did not become ready in time"
    exit 1
fi

# Download WordPress CLI
if [ ! -f /usr/local/bin/wp ]; then
    echo "Downloading WP-CLI..."
    wget --no-check-certificate https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# Go to web directory
cd /var/www/html

# Download and configure WordPress if not already done
if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root

    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${DB_NAME}" \
        --dbuser="${DB_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost=mariadb:3306 \
        --allow-root

    echo "Installing WordPress..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

    echo "Creating additional user..."
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${WP_PASSWORD}" \
        --role=author \
        --allow-root
    
    echo "WordPress setup complete!"
else
    echo "WordPress already configured, skipping setup..."
fi

# Create necessary directories for PHP-FPM
mkdir -p /run/php

# Start PHP-FPM in foreground
echo "Starting PHP-FPM..."
exec php-fpm7.4 -F
