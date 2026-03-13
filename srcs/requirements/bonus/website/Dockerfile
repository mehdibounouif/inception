# ============================================================
# Static website — pure HTML/CSS/JS, served by nginx
# ============================================================
# Subject rule: this service must NOT use PHP.
# WordPress already covers PHP — this service demonstrates a
# completely different technology serving a different purpose.
#
# What this is:
#   A personal portfolio / about page for mbounoui.42.fr/portfolio/
#   It is a single self-contained HTML file with embedded CSS and JS.
#   No server-side processing, no database, no PHP.
#
# How the main nginx routes to it:
#   The main nginx (port 443, TLS) acts as a reverse proxy.
#   A "location /portfolio/" block in the main nginx.conf forwards
#   requests to this container on port 80 (inside the Docker network).
#   The outside world never sees port 80 — everything arrives via
#   the main nginx on port 443.
#
# Why a second nginx inside this container?
#   It is the simplest, lightest way to serve static files in Debian.
#   Alternatives: Python http.server, Node.js — both work but add
#   unnecessary runtime complexity for static content.
# ============================================================

FROM debian:bullseye

# nginx is the only dependency — no PHP, no scripting runtime.
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Copy the static site files into the webroot.
# The www/ directory in the build context should contain index.html
# and any assets (CSS, JS, images). Keep everything self-contained
# so there are no external CDN dependencies.
COPY www/ /var/www/static/

# Our minimal nginx config — serves /var/www/static/ on port 80.
# It does NOT handle TLS; TLS termination is done by the main nginx.
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Port 80 — plain HTTP, reachable only inside the inception network.
# The host never sees this port; the main nginx proxies to it.
EXPOSE 80

# Run nginx in the foreground so Docker tracks it as PID 1.
CMD ["nginx", "-g", "daemon off;"]