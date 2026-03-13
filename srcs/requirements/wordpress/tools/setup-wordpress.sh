
#!/bin/bash
# ============================================================
# setup-wordpress.sh — install WordPress and configure Redis cache
# ============================================================
# This script runs every time the WordPress container starts.
# It is safe to run multiple times: every WP-CLI command that
# changes state is guarded by an "if not already done" check.
#
# Execution order:
#   1. Wait for MariaDB to be ready (retry loop)
#   2. Wait for Redis to be ready (retry loop)        ← bonus
#   3. Download WordPress core if not already present
#   4. Create wp-config.php if not already present
#   5. Run WordPress installation if not already done
#   6. Create the second WordPress user if not present
#   7. Install and enable the Redis cache plugin       ← bonus
#   8. exec php-fpm (becomes PID 1)
# ============================================================

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
# Step 2: Wait for Redis to accept connections (bonus)
# ----------------------------------------------------------
# Redis usually starts in under a second, but we poll it anyway
# to be safe. We use "redis-cli ping" — it returns "PONG" when ready.

echo "Waiting for Redis to be ready..."
count=0
while [ $count -lt 15 ]; do
    if redis-cli -h redis ping 2>/dev/null | grep -q PONG; then
        echo "Redis is ready."
        break
    fi
    count=$((count + 1))
    echo "  Redis not ready yet (attempt ${count}/15)..."
    sleep 1
done
# Redis failure is non-fatal: WordPress will work without the cache,
# just slower. We log a warning and continue.
if [ $count -eq 15 ]; then
    echo "WARNING: Redis did not respond. Continuing without cache."
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

    # Add Redis connection constants to wp-config.php.
    # The redis-cache plugin reads these to know where to connect.
    # We do this here (right after config creation) so the values
    # are in place before the plugin tries to use them.
    wp config set WP_REDIS_HOST redis         --allow-root
    wp config set WP_REDIS_PORT 6379 --raw    --allow-root
    # WP_CACHE enables the object cache drop-in (object-cache.php).
    wp config set WP_CACHE true --raw         --allow-root

    echo "wp-config.php created with Redis settings."
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
# Step 7: Install and enable the Redis cache plugin (bonus)
# ----------------------------------------------------------
# redis-cache is the official WordPress plugin for object caching.
# It installs a "drop-in" file (object-cache.php) that hooks into
# WordPress's caching layer and routes all object-cache calls to Redis.

if ! wp plugin is-installed redis-cache --allow-root 2>/dev/null; then
    echo "Installing redis-cache plugin..."
    wp plugin install redis-cache --activate --allow-root
fi

# wp redis enable copies the drop-in file into wp-content/.
# This is separate from plugin activation and must be run explicitly.
if ! wp redis status --allow-root 2>/dev/null | grep -q "Status: Connected"; then
    echo "Enabling Redis object cache..."
    wp redis enable --allow-root || echo "WARNING: Could not enable Redis cache."
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