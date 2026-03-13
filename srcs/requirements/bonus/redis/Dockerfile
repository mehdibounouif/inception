# ============================================================
# Redis — in-memory object/page cache for WordPress
# ============================================================
# Why Redis exists in this stack:
#   Without a cache, every HTTP request to WordPress runs PHP
#   and fires multiple SQL queries against MariaDB. Redis keeps
#   the results of those queries in RAM. Repeat requests are
#   served in microseconds instead of 100-500 ms.
#
# How it integrates with WordPress:
#   The WordPress "redis-cache" plugin (installed by WP-CLI in
#   setup-wordpress.sh) tells WordPress to use Redis as its
#   object-cache backend instead of rebuilding data every request.
#   It connects to host=redis port=6379 inside the inception network.
#
# Data persistence:
#   Redis is used here as a pure cache — if the container restarts,
#   the cache is empty and WordPress simply rebuilds it on demand.
#   No volume is needed (and adding one would just waste disk I/O).
# ============================================================

FROM debian:bullseye

# Install only the redis-server package.
# --no-install-recommends skips optional extras (man pages, etc.)
# that add image size without adding runtime value.
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    redis-server \
    && rm -rf /var/lib/apt/lists/*
# rm -rf /var/lib/apt/lists/* removes the apt package index from the
# image layer. We downloaded it only to run apt-get; we never need
# it at runtime, so removing it keeps the layer small.

# Replace Debian's default redis.conf with our custom one.
# The default configuration binds Redis only to 127.0.0.1 (loopback),
# which makes it completely unreachable from other containers.
# Our config binds to 0.0.0.0 so any container on the inception
# network can connect using the service name "redis".
COPY conf/redis.conf /etc/redis/redis.conf

# Document which port Redis uses internally.
# EXPOSE does NOT publish the port to the host machine — it stays
# purely inside the Docker network. WordPress reaches Redis via
# the inception bridge network, not through the host.
EXPOSE 6379

# Start Redis in the foreground.
# Docker needs the process to stay in the foreground (not daemonise)
# so it can detect crashes and apply the restart: always policy.
# "daemonize no" inside redis.conf enforces this, but writing it in
# CMD as well makes the intent clear to anyone reading this file.
CMD ["redis-server", "/etc/redis/redis.conf"]