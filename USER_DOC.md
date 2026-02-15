# User Documentation

## Services Provided
- **WordPress Website**: Content management system
- **NGINX Web Server**: HTTPS access with TLS encryption
- **MariaDB Database**: Data storage

## Starting the Project
```bash
make
```

## Stopping the Project
```bash
make down
```

## Accessing the Website
- **Main Site**: https://yourlogin.42.fr
- **Admin Panel**: https://yourlogin.42.fr/wp-admin

## Credentials
See `srcs/.env` file for all passwords.

Admin user: mbounouif

## Checking Services
```bash
docker ps                # Check running containers
docker logs mariadb      # View database logs
docker logs wordpress    # View WordPress logs
docker logs nginx        # View web server logs
```