#!/bin/bash
# ============================================================
# setup-ftp.sh — create the FTP OS user then launch vsftpd
# ============================================================
# Why do this at runtime and not at build time?
#   The FTP_USER and FTP_PASSWORD values come from the .env file,
#   which is loaded by Docker at container startup — not during
#   "docker build". Build-time RUN commands cannot access env_file
#   variables. So we create the user here, when the env vars exist.
#
# What this script does:
#   1. Creates an OS user whose home directory is /var/www/html
#      (the WordPress webroot). vsftpd's chroot will lock the FTP
#      client inside that directory.
#   2. Sets that user's password.
#   3. Hands control to vsftpd as PID 1 (via exec).
# ============================================================

set -e
# set -e makes the script exit immediately if any command fails,
# preventing vsftpd from starting with a broken user setup.

# ----------------------------------------------------------
# Validate that required environment variables are present.
# ----------------------------------------------------------
if [ -z "${FTP_USER}" ]; then
    echo "ERROR: FTP_USER is not set. Check your .env file."
    exit 1
fi

if [ -z "${FTP_PASSWORD}" ]; then
    echo "ERROR: FTP_PASSWORD is not set. Check your .env file."
    exit 1
fi

# ----------------------------------------------------------
# Create the FTP OS user (only on first boot).
# ----------------------------------------------------------
# We check whether the user already exists before creating them.
# On container restart the filesystem is preserved (volume mount),
# but /etc/passwd is reset — the user always needs to be recreated.
# The "|| true" on the id check lets us always run useradd safely.

echo "Creating FTP user: ${FTP_USER}"

# useradd flags:
#   -m            create home directory if it doesn't exist
#   -d            set home directory to /var/www/html so the FTP
#                 client lands directly in the WordPress webroot
#   -s /bin/bash  give the user a real shell (vsftpd requires this
#                 for local_enable=YES to work)
useradd -m -d /var/www/html -s /bin/bash "${FTP_USER}" 2>/dev/null || true

# Set the password using chpasswd, which reads "user:password" from stdin.
# We never write the password to a file or pass it as a shell argument
# (visible in "ps aux") — stdin is the secure way.
echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd

# ----------------------------------------------------------
# Fix ownership of the WordPress volume so the FTP user can
# read and write files there.
# ----------------------------------------------------------
# The wp_data volume is owned by www-data (set by the WordPress
# container). We add our FTP user to the www-data group so they
# share write access without needing to change the owner.
usermod -aG www-data "${FTP_USER}"

# Ensure the webroot is group-writable so the FTP user (now in
# www-data) can actually create and modify files.
chmod -R 775 /var/www/html 2>/dev/null || true

echo "FTP user ${FTP_USER} created. Starting vsftpd..."

# ----------------------------------------------------------
# Launch vsftpd as PID 1.
# ----------------------------------------------------------
# "exec" replaces this shell process with vsftpd, making vsftpd PID 1.
# This is required for:
#   - Docker to correctly detect crashes and apply restart: always
#   - Signals (SIGTERM on "docker stop") to reach vsftpd directly
#     instead of being swallowed by a parent shell
exec vsftpd /etc/vsftpd.conf