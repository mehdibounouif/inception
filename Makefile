# Detect which docker compose command to use
DOCKER_COMPOSE := $(shell which docker-compose 2>/dev/null)
ifeq ($(DOCKER_COMPOSE),)
	DOCKER_COMPOSE := docker compose
else
	DOCKER_COMPOSE := docker-compose
endif

all: up

up:
	@mkdir -p $(HOME)/data/db
	@mkdir -p $(HOME)/data/wordpress
	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml up -d --build

down:
	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml down

clean: down
	@docker system prune -af
	@sudo rm -rf $(HOME)/data

re: clean all

logs:
	@$(DOCKER_COMPOSE) -f srcs/docker-compose.yml logs -f

status:
	@docker ps

.PHONY: all up down clean re logs status
