
set -e
# ----------------------------------------------------------
# Step 1: Wait for MariaDB to accept connections
# ----------------------------------------------------------
# MariaDB takes a few seconds to initialise on first run.
# We poll it with "mysqladmin ping" until it responds or we time out.

echo "Waiting for MariaDB to be ready..."
max_tries=30
count=0
while [ $count -lt $max_tries ]; do
    if mysqladmin ping -h "mariadb" --silent 2>/dev/null; then
        echo "MariaDB is ready."
        break
    fi
    count=$((count + 1))
    echo "  MariaDB not ready yet (attempt ${count}/${max_tries})..."
    sleep 2
done

if [ $count -eq $max_tries ]; then
    echo "ERROR: MariaDB did not become ready in time. Exiting."
    exit 1
fi


# ----------------------------------------------------------
# Step 3: Download WordPress core
# ----------------------------------------------------------

cd /var/www/html

if [ ! -f wp-login.php ]; then
    echo "Downloading WordPress core..."
    # --allow-root is needed because this script runs as root inside
    # the container. WP-CLI normally refuses to run as root as a
    # safety measure; we override this intentionally.
    wp core download --allow-root
    echo "WordPress core downloaded."
fi

# ----------------------------------------------------------
# Step 4: Create wp-config.php
# ----------------------------------------------------------

if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${DB_NAME}" \
        --dbuser="${DB_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root

    echo "wp-config.php created."
fi

# ----------------------------------------------------------
# Step 5: Install WordPress
# ----------------------------------------------------------

if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Running WordPress installation..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
    echo "WordPress installed."
fi

# ----------------------------------------------------------
# Step 6: Create the second WordPress user
# ----------------------------------------------------------
# The subject requires exactly TWO users in the WordPress database.
# Admin (WP_ADMIN_USER) was created in step 5.
# This creates the author (WP_USER).

if ! wp user get "${WP_USER}" --allow-root 2>/dev/null; then
    echo "Creating WordPress user: ${WP_USER}..."
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${WP_PASSWORD}" \
        --role=author \
        --allow-root
    echo "User ${WP_USER} created."
fi


# ----------------------------------------------------------
# Step 8: Start php-fpm as PID 1
# ----------------------------------------------------------

# Create the runtime directory php-fpm needs for its PID file and socket.
mkdir -p /run/php

echo "Starting php-fpm..."

# exec replaces this shell with php-fpm.
# php-fpm becomes PID 1 — required for Docker signal handling and
# for the restart: always policy to work correctly.
# -F runs php-fpm in the foreground (no daemonise).
exec php-fpm7.4 -F