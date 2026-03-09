FROM debian:bullseye

# Install PHP-FPM, WordPress dependencies, and MariaDB client
RUN apt-get update && apt-get install -y \
	# PHP-FPM stands for FastCGI Process Manager
    php7.4-fpm \
    # A PHP extension that allows PHP code to talk to MySQL/MariaDB databases
    php7.4-mysql \
	# A PHP extension that allows PHP to make HTTP requests to other servers
    php7.4-curl \
	# GD stands for Graphics Draw. This PHP extension handles image manipulation.
    php7.4-gd \
	# handles MB stands for Multi-Byte string 
    php7.4-mbstring \
	# Allows PHP to parse and generate XML
    php7.4-xml \
	# Allows PHP to read and create ZIP files
    php7.4-zip \
	# A command-line tool for downloading files from the internet via HTTP/HTTPS
    wget \
	# Another command-line download tool, similar to wget but more versatile.
    curl \
	# This installs the MariaDB command-line client — specifically the mysql command
    mariadb-client \
	# CA stands for Certificate Authority
    ca-certificates \
	# Deletes the apt package cache to reduce image size
    && rm -rf /var/lib/apt/lists/*

# Configure PHP-FPM to listen on port 9000
RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/' \
    /etc/php/7.4/fpm/pool.d/www.conf

# Copy setup script
COPY tools/setup-wordpress.sh /usr/local/bin/setup-wordpress.sh
RUN chmod +x /usr/local/bin/setup-wordpress.sh

# Create web directory
RUN mkdir -p /var/www/html && \
	# www-data is the standard Linux user that web servers
	# (Nginx, Apache, PHP-FPM) run as by default
    chown -R www-data:www-data /var/www/html

# It's like doing cd /var/www/html
WORKDIR /var/www/html

# Documents that this container communicates on port 9000
EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup-wordpress.sh"]
