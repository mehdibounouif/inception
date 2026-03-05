# Detect which docker compose command to use
DOCKER_COMPOSE := $(shell which docker-compose 2>/dev/null)
ifeq ($(DOCKER_COMPOSE),)
	DOCKER_COMPOSE := docker compose
else
	DOCKER_COMPOSE := docker-compose
endif

all: up

# Creates the host data folders (~/data/db, ~/data/wordpress),
# then builds and starts all containers in detached background mode.
up:
	@mkdir -p $(HOME)/data/db
	@mkdir -p $(HOME)/data/wordpress
	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml up -d --build

#  Stops and removes the containers (but keeps data)
down:
	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml down

# Stops containers, prunes all Docker images/networks,
# and deletes all data from the host.
clean: down
	@docker system prune -af
	@sudo rm -rf $(HOME)/data

re: clean all

# Follows live logs from all containers.
logs:
	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml logs -f

# Shows which containers are running.
status:
	@docker ps

.PHONY: all up down clean re logs status
