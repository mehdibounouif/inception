# ── Detect which docker compose command is available ──────────────────────────
# Newer Docker ships "docker compose" (plugin form).
# Older systems have the standalone "docker-compose" binary.
# We prefer the standalone binary if found, otherwise fall back to the plugin.
DOCKER_COMPOSE := $(shell which docker-compose 2>/dev/null)
ifeq ($(DOCKER_COMPOSE),)
	DOCKER_COMPOSE := docker compose
else
	DOCKER_COMPOSE := docker-compose
endif

all: up

# 1. Create host directories that the named volumes bind-mount to.
#    Docker cannot create these automatically when driver_opts type=none is used.
#    If the directories already exist, mkdir -p is a no-op (safe to re-run).
# 2. Build all images from their Dockerfiles and start containers in detached mode.
up:
	@mkdir -p $(HOME)/data/db
	@mkdir -p $(HOME)/data/wordpress
	@mkdir -p $(HOME)/data/portainer
	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml up -d --build

# Stop and remove containers and the default network.
# Named volumes and images are preserved  data survives a "make down".
down:
	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml down

# Full teardown:
#   docker system prune -af    removes stopped containers, unused images,
#                               build cache, and dangling volumes.
#   rm -rf $(HOME)/data        removes the host-side volume data.
# Use before a fresh "make re" or when submitting the project.
clean: down
	@docker system prune -af
	@sudo rm -rf $(HOME)/data

# Full clean then fresh build. Useful after changing Dockerfiles or configs.
re: clean all

# Stream logs from all containers. Ctrl-C to stop following.
logs:
	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml logs -f

# Quick overview of running containers (name, image, status, ports).
status:
	@docker ps

# Prevents make from treating these names as filenames.
.PHONY: all up down clean re logs status