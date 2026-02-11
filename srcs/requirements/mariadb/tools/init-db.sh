#!/bin/bash

# Start MySQL in background to configure it
mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

-- Delete anonymous users
DELETE FROM mysql.user WHERE User='';

-- Create database
CREATE DATABASE IF NOT EXISTS ${DB_NAME};

-- Create user and grant privileges
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';

-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF

# Now start MySQL normally in foreground
exec mysqld --user=mysql
