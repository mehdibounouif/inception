## Detect which docker compose command to use
#DOCKER_COMPOSE := $(shell which docker-compose 2>/dev/null)
#ifeq ($(DOCKER_COMPOSE),)
#	DOCKER_COMPOSE := docker compose
#else
#	DOCKER_COMPOSE := docker-compose
#endif
#
#all: up
#
## Creates the host data folders (~/data/db, ~/data/wordpress),
## then builds and starts all containers in detached background mode.
#up:
#	@mkdir -p $(HOME)/data/db
#	@mkdir -p $(HOME)/data/wordpress
#	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml up -d --build
#
##  Stops and removes the containers (but keeps data)
#down:
#	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml down
#
## Stops containers, prunes all Docker images/networks,
## and deletes all data from the host.
#clean: down
#	@docker system prune -af
#	@sudo rm -rf $(HOME)/data
#
#re: clean all
#
## Follows live logs from all containers.
#logs:
#	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml logs -f
#
## Shows which containers are running.
#status:
#	@docker ps
#
#.PHONY: all up down clean re logs status



# ─────────────────────────────────────────────────────────────────────────────
# Makefile  —  Inception project
#
# Usage:
#   make          →  build images and start all containers (default target)
#   make up       →  same as above
#   make down     →  stop and remove containers (volumes and images kept)
#   make clean    →  down + remove all images, volumes, and host data dirs
#   make re       →  full clean then build + start from scratch
#   make logs     →  tail logs from all containers
#   make status   →  show running containers
# ─────────────────────────────────────────────────────────────────────────────

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

# ── Default target ────────────────────────────────────────────────────────────
all: up

# ── up ────────────────────────────────────────────────────────────────────────
# 1. Create host directories that the named volumes bind-mount to.
#    Docker cannot create these automatically when driver_opts type=none is used.
#    If the directories already exist, mkdir -p is a no-op (safe to re-run).
# 2. Build all images from their Dockerfiles and start containers in detached mode.
up:
	@mkdir -p $(HOME)/data/db
	@mkdir -p $(HOME)/data/wordpress
	@mkdir -p $(HOME)/data/portainer
	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml up -d --build

# ── down ──────────────────────────────────────────────────────────────────────
# Stop and remove containers and the default network.
# Named volumes and images are preserved — data survives a "make down".
down:
	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml down

# ── clean ─────────────────────────────────────────────────────────────────────
# Full teardown:
#   docker system prune -af  →  removes stopped containers, unused images,
#                               build cache, and dangling volumes.
#   rm -rf $(HOME)/data      →  removes the host-side volume data.
# Use before a fresh "make re" or when submitting the project.
clean: down
	@docker system prune -af
	@sudo rm -rf $(HOME)/data

# ── re ────────────────────────────────────────────────────────────────────────
# Full clean then fresh build. Useful after changing Dockerfiles or configs.
re: clean all

# ── logs ──────────────────────────────────────────────────────────────────────
# Stream logs from all containers. Ctrl-C to stop following.
logs:
	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml logs -f

# ── status ────────────────────────────────────────────────────────────────────
# Quick overview of running containers (name, image, status, ports).
status:
	@docker ps

# ── Declare phony targets ─────────────────────────────────────────────────────
# Prevents make from treating these names as filenames.
.PHONY: all up down clean re logs status