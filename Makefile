all: up

up:
	@mkdir -p /home/${USER}/data/db
	@mkdir -p /home/${USER}/data/wordpress
	@docker-compose -f srcs/docker-compose.yml up -d --build

down:
	@docker-compose -f srcs/docker-compose.yml down

clean: down
	@docker system prune -af
	@sudo rm -rf /home/${USER}/data

re: clean all

.PHONY: all up down clean re
