# ============================================================
# Adminer — web-based database management UI
# ============================================================
# What Adminer is:
#   Adminer is a single PHP file (~500 KB) that provides a full
#   database administration interface in a browser — browse tables,
#   run SQL queries, import/export data. Think phpMyAdmin but far
#   simpler to deploy (one file, no configuration database needed).
#
# Why it is useful for the defense:
#   Evaluators can open https://mbounoui.42.fr/adminer/ and visually
#   confirm that MariaDB is running, the wordpress database exists,
#   the two required users are present, and the tables were created
#   by WordPress. This makes the database verification step instant
#   instead of requiring CLI commands.
#
# Architecture:
#   This container runs php-fpm on port 9000 (same pattern as
#   the WordPress container). The main nginx reverse-proxies the
#   /adminer/ location to adminer:9000 via FastCGI.
#   Adminer never gets a direct port to the host — all traffic
#   goes through the main nginx, keeping NGINX as the sole entrypoint.
#
# Why not just add adminer.php to the WordPress container?
#   The subject requires each service in its own container.
#   Mixing Adminer into WordPress would also risk breaking the
#   WordPress setup and muddles separation of concerns.
# ============================================================

FROM debian:bullseye

# php7.4-fpm   — PHP FastCGI process manager (same version as WordPress)
# php7.4-mysql — PHP's MySQLi/PDO drivers so Adminer can talk to MariaDB
# wget         — to download the Adminer PHP file during the build
# ca-certificates — allows wget to verify GitHub's HTTPS certificate
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    php7.4-fpm \
    php7.4-mysql \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create the directory that php-fpm will serve Adminer from.
RUN mkdir -p /var/www/adminer

# Download a pinned version of Adminer.
# We pin to 4.8.1 (not "latest") because:
#   1. The subject forbids the :latest tag pattern — stability matters.
#   2. A specific URL ensures reproducible builds.
# The file is renamed to index.php so nginx's fastcgi_index works.
RUN wget -q \
    https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
    -O /var/www/adminer/index.php

# Configure php-fpm to listen on TCP port 9000 instead of a Unix socket.
# The main nginx reaches this container over the Docker network (TCP),
# not via a shared filesystem socket — so TCP is required.
RUN sed -i \
    's|listen = /run/php/php7.4-fpm.sock|listen = 9000|' \
    /etc/php/7.4/fpm/pool.d/www.conf

# Fix ownership so php-fpm (running as www-data) can read the file.
RUN chown -R www-data:www-data /var/www/adminer

# The entrypoint script ensures the php-fpm runtime directory exists
# then starts php-fpm. This mirrors the pattern used in WordPress.
COPY tools/start-adminer.sh /usr/local/bin/start-adminer.sh
RUN chmod +x /usr/local/bin/start-adminer.sh

# Port 9000 — FastCGI, reachable only inside the inception network.
# The main nginx connects here; the host never sees this port.
EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/start-adminer.sh"]