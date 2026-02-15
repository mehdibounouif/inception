# Developer Documentation

## Setup from Scratch

1. Install Docker and Docker Compose
2. Clone the repository
3. Configure domain in `/etc/hosts`:
```bash
   sudo bash -c 'echo "127.0.0.1 yourlogin.42.fr" >> /etc/hosts'
```
4. Update credentials in `srcs/.env`

## Build and Launch
```bash
make              # Build and start all containers
make down         # Stop containers
make clean        # Remove everything (including data)
make re           # Clean rebuild
```

## Container Management
```bash
docker ps                           # List running containers
docker exec -it mariadb bash        # Access MariaDB container
docker exec -it wordpress bash      # Access WordPress container
docker logs -f nginx                # Follow NGINX logs
```

## Data Persistence
- Database data: `~/data/db`
- WordPress files: `~/data/wordpress`

## Architecture
- NGINX (port 443) → WordPress (port 9000) → MariaDB (port 3306)
- All containers communicate via `inception` network