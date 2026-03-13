# ============================================================
# FTP server — vsftpd pointing at the WordPress volume
# ============================================================
# Why FTP exists in this stack:
#   Evaluators verify this bonus by connecting an FTP client
#   (e.g. FileZilla) directly to the VM's IP on port 21, then
#   uploading a file into the WordPress folder. They then open
#   a browser and confirm the file is accessible on the website.
#
# Why vsftpd?
#   "Very Secure FTP Daemon" is the standard, well-documented FTP
#   server in Debian. It supports chroot jails (locking users inside
#   their home directory) and passive-mode, both required here.
#
# Volume sharing:
#   This container mounts the SAME wp_data volume as WordPress and
#   nginx. Files uploaded via FTP appear instantly on the website
#   because they land in the same directory (/var/www/html).
#
# Passive mode explained:
#   FTP uses TWO TCP connections:
#     1. Control connection on port 21 (commands: login, LIST, STOR…)
#     2. Data connection for actual file transfer
#   In passive mode the server opens a port in a range (21100-21110)
#   and tells the client "connect here for data". This works through
#   Docker's NAT; active mode (server connects back to client) does not.
# ============================================================

FROM debian:bullseye

# Install vsftpd only. No extras needed.
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

# Our vsftpd.conf replaces the Debian default.
# The default config is read-only and binds incorrectly for Docker.
COPY conf/vsftpd.conf /etc/vsftpd.conf

# The setup script creates the FTP user at runtime using credentials
# from environment variables (FTP_USER, FTP_PASSWORD from .env).
# We cannot create the user at build time because the credentials
# are not available as build arguments — only at container runtime.
COPY tools/setup-ftp.sh /usr/local/bin/setup-ftp.sh
RUN chmod +x /usr/local/bin/setup-ftp.sh

# Port 21 — FTP control connection (login, commands).
EXPOSE 21

# Ports 21100-21110 — passive mode data connections (file transfers).
# This range must match pasv_min_port / pasv_max_port in vsftpd.conf
# AND the ports: mapping in docker-compose.yml.
EXPOSE 21100-21110

# setup-ftp.sh creates the OS user then hands off to vsftpd.
ENTRYPOINT ["/usr/local/bin/setup-ftp.sh"]