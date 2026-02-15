#!/bin/bash

# Create the run directory for mysqld socket
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Check if database is already initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    
    # Initialize the database
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # Start MariaDB in background
    mysqld --user=mysql --datadir=/var/lib/mysql &
    mysql_pid=$!
    
    echo "Waiting for MariaDB to start..."
    # Wait for MariaDB to be ready
    for i in {1..30}; do
        if mysqladmin ping --silent 2>/dev/null; then
            echo "MariaDB is ready!"
            break
        fi
        echo "Waiting... ($i/30)"
        sleep 1
    done
    
    # Configure database
    mysql -u root << EOF
-- Secure the installation
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Create WordPress database
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create WordPress user with access from any host
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

-- Apply changes
FLUSH PRIVILEGES;
EOF
    
    echo "MariaDB configuration complete!"
    
    # Stop the background MariaDB
    mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
    
    echo "MariaDB initialized successfully!"
else
    echo "MariaDB already initialized, skipping..."
fi

# Start MariaDB in foreground
echo "Starting MariaDB server..."
exec mysqld --user=mysql --console
