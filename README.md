*This project has been created as part of the 42 curriculum by mehdibounouif.*

# Inception

A Docker-based infrastructure project that sets up a complete WordPress website with NGINX, PHP-FPM, and MariaDB running in separate containers.

## Description

This project demonstrates system administration skills by creating a multi-container Docker application. It includes:

- **NGINX**: Web server with TLS v1.2/1.3 encryption (port 443 only)
- **WordPress + PHP-FPM**: Content management system
- **MariaDB**: Database server

All services run in isolated Docker containers, communicating through a custom Docker network, with persistent data stored in Docker volumes.

## Instructions

### Prerequisites

**Required Software:**
- Docker (20.10+)
- Docker Compose (2.0+)
- Git
- A Linux virtual machine (Debian/Ubuntu/Fedora recommended)
- At least 2GB of free disk space
- Root/sudo access

**Check if Docker is installed:**
```bash
docker --version
docker compose version
```

**If Docker is not installed:**
```bash
# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
sudo apt-get install -y docker.io docker-compose

# Add your user to docker group
sudo usermod -aG docker $USER

# Log out and log back in, or run:
newgrp docker

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
docker ps
```

### Installation

1. **Clone the repository:**
```bash
cd ~
git clone <your-repo-url>
cd inception
```

2. **Configure your domain in `/etc/hosts`:**
```bash
# Replace 'mehdibounouif' with YOUR 42 login
sudo bash -c 'echo "127.0.0.1 mehdibounouif.42.fr" >> /etc/hosts'

# Verify it was added
cat /etc/hosts | grep 42.fr
```

3. **Update environment variables in `srcs/.env`:**
```bash
nano srcs/.env
```

**Change these values:**
- `DOMAIN_NAME=yourlogin.42.fr` (replace with YOUR login)
- `WP_ADMIN_USER=youradmin` (cannot contain 'admin' or 'administrator')
- All passwords (make them strong and unique)
- Email addresses

**Example `.env` file:**
```bash
# Domain Configuration
DOMAIN_NAME=yourlogin.42.fr

# MySQL/MariaDB Configuration
DB_NAME=wordpress
DB_USER=wpuser
DB_PASSWORD=MySecureDBPass123!
DB_ROOT_PASSWORD=MyRootPass456!

# WordPress Admin User
WP_ADMIN_USER=youradmin
WP_ADMIN_PASSWORD=AdminPass789!
WP_ADMIN_EMAIL=admin@yourlogin.42.fr

# WordPress Regular User
WP_USER=editor
WP_USER_EMAIL=editor@yourlogin.42.fr
WP_PASSWORD=EditorPass012!
```

4. **Verify directory structure:**
```bash
# Check that all files exist
ls -la srcs/requirements/nginx/
ls -la srcs/requirements/wordpress/
ls -la srcs/requirements/mariadb/
```

### Usage

**Build and start the infrastructure:**
```bash
make
```

This command will:
- Create data directories (`~/data/db` and `~/data/wordpress`)
- Build Docker images from Dockerfiles
- Create volumes and networks
- Start all containers

**Wait 2-3 minutes** for WordPress to download and configure.

**Other commands:**
```bash
make down    # Stop containers
make clean   # Remove everything (containers, images, volumes, data)
make re      # Clean rebuild from scratch
make logs    # View logs from all containers
make status  # Show running containers
```

**View individual container logs:**
```bash
docker logs mariadb
docker logs wordpress
docker logs nginx

# Follow logs in real-time
docker logs -f wordpress
```

### Accessing the Website

After starting the containers (wait ~2-3 minutes for complete initialization):

1. **Check that all containers are running:**
```bash
docker ps
```
You should see 3 containers: `nginx`, `wordpress`, `mariadb` - all with status "Up"

2. **Open your browser and visit:**
```
https://yourlogin.42.fr
```
Replace `yourlogin` with your actual 42 login.

3. **Handle SSL certificate warning:**
   - You'll see: "Your connection is not private" or "Warning: Potential Security Risk"
   - Click **Advanced**
   - Click **Proceed to yourlogin.42.fr (unsafe)** or **Accept the Risk and Continue**
   
   This is normal - we're using a self-signed SSL certificate for development.

4. **Access WordPress Admin Panel:**
```
https://yourlogin.42.fr/wp-admin
```

**Login with credentials from your `.env` file:**
- Username: (your WP_ADMIN_USER)
- Password: (your WP_ADMIN_PASSWORD)

### Default Credentials

As defined in `srcs/.env`:
- **Admin user**: `youradmin` / `AdminPass789!`
- **Regular user**: `editor` / `EditorPass012!`
- **Database**: `wordpress` / `wpuser` / `MySecureDBPass123!`

**⚠️ IMPORTANT: Change these passwords before deployment!**

## Project Structure

```
inception/
├── Makefile                          # Build automation
├── README.md                         # This file
├── USER_DOC.md                       # User documentation
├── DEV_DOC.md                        # Developer documentation
├── .gitignore                        # Git ignore rules
├── secrets/                          # (Optional) Docker secrets
└── srcs/
    ├── .env                          # Environment variables (NOT in git)
    ├── docker-compose.yml            # Container orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile            # MariaDB image definition
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── 50-server.cnf    # MariaDB configuration
        │   └── tools/
        │       └── init-db.sh        # Database initialization script
        ├── nginx/
        │   ├── Dockerfile            # NGINX image definition
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── nginx.conf        # NGINX configuration
        │   └── tools/
        │       └── generate-ssl.sh   # SSL certificate generation
        └── wordpress/
            ├── Dockerfile            # WordPress image definition
            ├── .dockerignore
            └── tools/
                └── setup-wordpress.sh # WordPress installation script
```

## Technical Details

### Docker Architecture

- **Network**: Custom bridge network (`inception`) for inter-container communication
- **Volumes**: Two persistent bind-mounted volumes
  - `db_data`: MariaDB database files (`~/data/db`)
  - `wp_data`: WordPress files (`~/data/wordpress`)
- **Images**: Built from Debian Bullseye base images
- **No pre-built images**: All images built from scratch (except base OS)

### Container Communication Flow

```
Internet/Browser
      ↓
   NGINX (port 443, TLS)
      ↓
   WordPress (port 9000, PHP-FPM)
      ↓
   MariaDB (port 3306)
      ↓
   Data Volumes (persistent storage)
```

### Key Design Choices

#### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker Containers |
|--------|-----------------|-------------------|
| **OS** | Full OS included | Shares host kernel |
| **Size** | GBs (heavy) | MBs (lightweight) |
| **Startup** | Minutes | Seconds |
| **Resource Usage** | High | Low |
| **Isolation** | Complete | Process-level |
| **Use Case** | Different OS needed | Same OS, different apps |

**Why Docker for this project:**
- Faster development and deployment
- Better resource utilization
- Easy to replicate environment
- Microservices architecture

#### Secrets vs Environment Variables

| Secrets | Environment Variables |
|---------|----------------------|
| Encrypted at rest | Plain text |
| Not in container env | Visible in container |
| Require special access | Easy to read |
| Production best practice | Development acceptable |

**This project uses `.env` files for simplicity. Production deployments should use Docker secrets.**

#### Docker Network vs Host Network

| Docker Network | Host Network |
|---------------|--------------|
| Isolated from host | Direct host access |
| Service name DNS | Use localhost |
| Secure | Less secure |
| Portable | Host-dependent |

**This project uses custom bridge network for security and container name resolution.**

#### Docker Volumes vs Bind Mounts

| Docker Volumes | Bind Mounts |
|---------------|-------------|
| Managed by Docker | Direct filesystem access |
| Platform-independent | OS-specific paths |
| Better performance | Easier debugging |
| Production use | Development use |

**This project uses bind mounts (`~/data`) for easy access during development and evaluation.**

### Security Features

- **TLS 1.2/1.3 only** on NGINX (no older protocols)
- **No passwords in Dockerfiles** (uses environment variables)
- **Isolated container network** (containers can't access host network directly)
- **Port 443 only** exposed to host (MariaDB and WordPress ports are internal)
- **Non-root users** where possible (mysql user, www-data)
- **Self-signed SSL certificates** (replace with Let's Encrypt for production)
- **No hard-coded credentials** in code

## Complete Setup Guide (Step-by-Step)

### Step 1: Prepare Your VM

```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker
sudo apt-get install -y docker.io docker-compose

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, then verify
docker ps
```

### Step 2: Clone and Configure

```bash
# Clone project
cd ~
git clone <your-repo>
cd inception

# Configure domain
sudo nano /etc/hosts
# Add: 127.0.0.1 yourlogin.42.fr

# Update environment variables
nano srcs/.env
# Change DOMAIN_NAME and all passwords
```

### Step 3: Build and Start

```bash
# Build everything
make

# This will take 5-10 minutes on first run
# Watch the logs
docker logs -f wordpress
```

### Step 4: Verify Everything Works

```bash
# Check containers
docker ps
# All 3 should show "Up"

# Test database connection
docker exec wordpress mysql -h mariadb -u wpuser -p<DB_PASSWORD> -e "SHOW DATABASES;"

# Test NGINX
curl -k https://localhost:443

# Check WordPress files
docker exec wordpress ls -la /var/www/html/ | grep wp-config
```

### Step 5: Access Website

Open browser: `https://yourlogin.42.fr`

## Troubleshooting

### Problem: Containers Keep Restarting

**Symptoms:**
```bash
docker ps
# Shows "Restarting" status
```

**Solution:**
```bash
# Check logs to find the error
docker logs mariadb
docker logs wordpress
docker logs nginx

# Common causes:
# 1. MariaDB: Socket directory missing
# 2. WordPress: Can't connect to database
# 3. NGINX: Can't find upstream server
```

### Problem: MariaDB Shows "already initialized" but Wrong Database

**Symptoms:**
- MariaDB logs say "MariaDB already initialized, skipping..."
- WordPress can't connect: "Host not allowed to connect"

**Solution:**
```bash
# Complete clean rebuild
make down
docker volume rm srcs_db_data srcs_wp_data
docker rmi srcs-mariadb srcs-wordpress srcs-nginx
sudo rm -rf ~/data
make
```

### Problem: Port 443 Already in Use

**Symptoms:**
```
Error: bind: address already in use
```

**Solution:**
```bash
# Find what's using port 443
sudo lsof -i :443

# Stop the conflicting service
sudo systemctl stop <service-name>

# Or change your Docker port (not recommended for this project)
```

### Problem: Permission Denied on Volumes

**Symptoms:**
```
Permission denied: '/var/lib/mysql'
```

**Solution:**
```bash
# Fix ownership
sudo chown -R $USER:$USER ~/data

# Or
sudo chmod -R 755 ~/data
```

### Problem: WordPress Shows Installation Page Instead of Site

**Symptoms:**
- Browser shows "Welcome to WordPress" setup page

**Cause:**
- WordPress didn't auto-install

**Solution:**
```bash
# Check WordPress logs
docker logs wordpress

# If you see errors, restart WordPress
docker restart wordpress

# Wait 30 seconds and check again
docker logs wordpress | grep "Success"

# If still not working, do clean rebuild
make clean
make
```

### Problem: SSL Certificate Error in Browser

**This is NORMAL!**

**Why:**
- We're using self-signed SSL certificates
- Browsers don't trust self-signed certificates

**Solution:**
- Click "Advanced" 
- Click "Proceed to site (unsafe)"
- This is safe for local development

**For production:**
- Use Let's Encrypt for real SSL certificates

### Problem: Can't Access Website After Reboot

**Solution:**
```bash
# Docker service might not be running
sudo systemctl start docker

# Containers might not have started
cd ~/inception
make
```

### Problem: Database Connection Error 1130

**Full error:**
```
Error: Database connection error (1130) Host 'wordpress.srcs_inception' is not allowed to connect
```

**Cause:**
- Database user created with wrong host permissions
- Old database data persisting

**Solution:**
```bash
# Option 1: Clean rebuild (recommended)
make clean
make

# Option 2: Manual fix
docker exec -it mariadb mysql -u root -p<DB_ROOT_PASSWORD>
# Then run:
DROP USER IF EXISTS 'wpuser'@'%';
CREATE USER 'wpuser'@'%' IDENTIFIED BY '<DB_PASSWORD>';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';
FLUSH PRIVILEGES;
EXIT;

docker restart wordpress
```

### Problem: Docker Says "Cannot Mount Volume"

**Error:**
```
failed to mount local volume: no such file or directory
```

**Solution:**
```bash
# Create directories manually
mkdir -p ~/data/db
mkdir -p ~/data/wordpress

# Then start
docker compose -f srcs/docker-compose.yml up -d
```

### Problem: MariaDB Image Contains Old Database Files

**Symptoms:**
- Even after `make clean`, old database persists
- Timestamps show old files

**Solution:**
```bash
# Rebuild MariaDB without cache
docker compose -f srcs/docker-compose.yml down
docker rmi -f srcs-mariadb
docker compose -f srcs/docker-compose.yml build --no-cache mariadb
sudo rm -rf ~/data
mkdir -p ~/data/db ~/data/wordpress
docker compose -f srcs/docker-compose.yml up -d
```

**This ensures the MariaDB image doesn't contain pre-initialized database files.**

## Resources

### Official Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Docker Networking](https://docs.docker.com/network/)
- [Docker Volumes](https://docs.docker.com/storage/volumes/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [NGINX SSL Configuration](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [WordPress CLI (WP-CLI)](https://wp-cli.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.php)

### Tutorials
- [Docker Tutorial for Beginners](https://docker-curriculum.com/)
- [Docker Compose Tutorial](https://docs.docker.com/compose/gettingstarted/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [NGINX Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html)

### Useful Commands Reference

```bash
# Docker Management
docker ps                          # List running containers
docker ps -a                       # List all containers
docker images                      # List images
docker volume ls                   # List volumes
docker network ls                  # List networks

# Container Operations
docker start <container>           # Start container
docker stop <container>            # Stop container
docker restart <container>         # Restart container
docker logs <container>            # View logs
docker logs -f <container>         # Follow logs
docker exec -it <container> bash   # Access container shell

# Cleanup Commands
docker system prune -a             # Remove all unused containers/images
docker volume prune                # Remove unused volumes
docker network prune               # Remove unused networks

# Debugging
docker inspect <container>         # View container details
docker stats                       # View resource usage
docker top <container>             # View running processes
```

### AI Usage

AI (Claude) was used extensively throughout this project for:

**Understanding Concepts:**
- Docker fundamentals and best practices
- Container networking and volume management
- Difference between VMs and containers
- Docker Compose orchestration
- TLS/SSL certificate management

**Code Generation:**
- Initial Dockerfile templates
- Shell script structures (init-db.sh, setup-wordpress.sh)
- NGINX configuration templates
- Docker Compose YAML structure

**Debugging and Problem-Solving:**
- Container restart issues
- Network connectivity problems
- Volume mounting errors
- Database initialization bugs
- Permission issues

**Documentation:**
- README structure and content
- Troubleshooting guides
- Technical comparisons
- Step-by-step tutorials

**How AI Was Used Responsibly:**
- All AI-generated code was reviewed line-by-line
- Code was tested extensively before use
- Understanding was verified through debugging
- Documentation was customized for this specific project
- AI explanations helped build fundamental knowledge

**All final code and documentation represents my understanding and has been fully tested and debugged.**

## Testing Before Submission

### Pre-Submission Checklist

```bash
# 1. Clean rebuild test
make clean
make
sleep 180  # Wait 3 minutes

# 2. Verify containers
docker ps
# All 3 should show "Up"

# 3. Test website
curl -k https://localhost:443 | grep WordPress

# 4. Test admin login
# Open browser: https://yourlogin.42.fr/wp-admin

# 5. Verify volumes
ls -la ~/data/db/
ls -la ~/data/wordpress/

# 6. Check no passwords in Dockerfiles
grep -r "password" srcs/requirements/*/Dockerfile
# Should return nothing

# 7. Verify .env not in git
cat .gitignore | grep .env

# 8. Check documentation
ls -la | grep -E "README|USER_DOC|DEV_DOC"

# 9. Test restart
docker restart mariadb wordpress nginx
sleep 30
docker ps
# All should be "Up"

# 10. Verify network isolation
docker exec nginx ping -c 1 mariadb
# Should work (containers on same network)
```

### Evaluation Preparation

**Before your evaluation:**

1. **Clean state:**
```bash
make clean
```

2. **Fresh build:**
```bash
make
# Wait for complete initialization
```

3. **Verify everything works:**
- Visit website in browser
- Login to admin panel
- Check both users exist

4. **Be ready to explain:**
- Why you chose Docker over VMs
- How containers communicate
- What happens when container crashes
- Where data is stored
- How TLS encryption works

## Common Evaluation Questions

**Q: Why use Docker instead of VMs?**
A: Docker containers are lighter, faster, and more portable. They share the host kernel, use fewer resources, and start in seconds vs minutes for VMs.

**Q: What happens if a container crashes?**
A: The `restart: always` policy in docker-compose.yml automatically restarts crashed containers.

**Q: Where is the database data stored?**
A: In `~/data/db` on the host, mounted as a volume to `/var/lib/mysql` in the container.

**Q: How do containers communicate?**
A: Through a custom Docker bridge network called "inception". Containers can reference each other by service name (e.g., `mariadb`, `wordpress`).

**Q: Why only port 443?**
A: Security - only HTTPS traffic is allowed from outside. MariaDB (3306) and WordPress (9000) are only accessible within the Docker network.

**Q: What's the difference between CMD and ENTRYPOINT?**
A: ENTRYPOINT sets the main command that always runs. CMD provides default arguments. ENTRYPOINT is better for services that should always run the same command.

## Author

Created by **mehdibounouif** for the 42 Inception project.

---

*If you encounter any issues not covered here, check the container logs first with `docker logs <container_name>`. Most problems are logged with clear error messages.*
