*This project has been created as part of the 42 curriculum by mehdibounouif.*

# Inception

A Docker-based infrastructure project that sets up a complete WordPress website with NGINX, PHP-FPM, and MariaDB running in separate containers.

## Description

This project demonstrates system administration skills by creating a multi-container Docker application. It includes:

- **NGINX**: Web server with TLS v1.2/1.3 encryption
- **WordPress + PHP-FPM**: Content management system
- **MariaDB**: Database server

All services run in isolated Docker containers, communicating through a custom Docker network, with persistent data stored in Docker volumes.

## Instructions

### Prerequisites

- Docker and Docker Compose installed
- A Linux virtual machine (Debian/Ubuntu recommended)
- At least 2GB of free disk space

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd inception
```

2. Configure your domain in `/etc/hosts`:
```bash
sudo bash -c 'echo "127.0.0.1 mehdibounouif.42.fr" >> /etc/hosts'
```

3. Update environment variables in `srcs/.env`:
   - Change `DOMAIN_NAME` to your login (e.g., `yourlogin.42.fr`)
   - Modify passwords for security
   - Update email addresses

### Usage

Build and start the infrastructure:
```bash
make
```

Stop the infrastructure:
```bash
make down
```

View logs:
```bash
make logs
```

Clean everything (removes containers, images, and data):
```bash
make clean
```

Restart from scratch:
```bash
make re
```

### Accessing the Website

After starting the containers (wait ~2 minutes for initialization):

- **WordPress Site**: https://mehdibounouif.42.fr
- **WordPress Admin**: https://mehdibounouif.42.fr/wp-admin

**Note**: You'll see a security warning because of the self-signed SSL certificate. Click "Advanced" → "Proceed anyway".

### Default Credentials

Defined in `srcs/.env`:
- **Admin user**: mbounouif / admin_pass_789
- **Regular user**: wpeditor / editor_pass_012
- **Database**: wordpress / wpuser / wpuser_secure_pass_123

**⚠️ Change these passwords before deployment!**

## Project Structure

```
inception/
├── Makefile                          # Build automation
├── README.md                         # This file
├── secrets/                          # (Optional) Docker secrets
└── srcs/
    ├── .env                          # Environment variables
    ├── docker-compose.yml            # Container orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── 50-server.cnf    # MariaDB configuration
        │   └── tools/
        │       └── init-db.sh        # Database initialization
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── nginx.conf        # NGINX configuration
        │   └── tools/
        │       └── generate-ssl.sh   # SSL certificate generation
        └── wordpress/
            ├── Dockerfile
            └── tools/
                └── setup-wordpress.sh # WordPress installation
```

## Technical Details

### Docker Architecture

- **Network**: Custom bridge network for inter-container communication
- **Volumes**: Two persistent volumes (database data + WordPress files)
- **Images**: Built from Debian Bullseye base images

### Key Design Choices

**Virtual Machines vs Docker**
- VMs include full OS (heavy, slow to start)
- Containers share host kernel (lightweight, fast)
- Docker provides better resource utilization and portability

**Secrets vs Environment Variables**
- Environment variables: Used for non-sensitive configuration
- Secrets: Recommended for passwords and API keys (more secure)
- This project uses `.env` for simplicity; production should use Docker secrets

**Docker Network vs Host Network**
- Docker network: Isolated, secure, allows service name resolution
- Host network: Direct host access, less isolation
- Custom bridge network chosen for security and flexibility

**Docker Volumes vs Bind Mounts**
- Volumes: Managed by Docker, portable, better performance
- Bind mounts: Direct host filesystem access, less portable
- This project uses bind mounts for easy data access during development

### Security Features

- TLS 1.2/1.3 encryption on NGINX
- No passwords in Dockerfiles (environment variables)
- Isolated container network
- Non-root users where possible
- Self-signed SSL certificates (replace with Let's Encrypt in production)

## Resources

### Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress CLI](https://wp-cli.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)

### Tutorials
- [Docker Tutorial for Beginners](https://docker-curriculum.com/)
- [Docker Networking Guide](https://docs.docker.com/network/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

### AI Usage
AI (Claude) was used for:
- Understanding Docker concepts and best practices
- Generating initial Dockerfile templates
- Debugging container networking issues
- Writing documentation structure
- Explaining differences between Docker and VMs

All AI-generated code was reviewed, tested, and modified to ensure correctness and project requirements compliance.

## Troubleshooting

**Containers keep restarting:**
```bash
docker logs mariadb
docker logs wordpress
docker logs nginx
```

**Permission denied errors:**
```bash
sudo chown -R $USER:$USER ~/data
```

**Port 443 already in use:**
```bash
sudo lsof -i :443
# Stop the conflicting service
```

**Can't connect to database:**
- Wait 60 seconds for MariaDB to fully initialize
- Check logs: `docker logs mariadb`
- Verify `.env` credentials match

**WordPress not accessible:**
- Verify all containers are running: `docker ps`
- Check NGINX logs: `docker logs nginx`
- Ensure domain is in `/etc/hosts`

## Author

Created by **mehdibounouif** for the 42 Inception project.
