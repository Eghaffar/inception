WP_DATA = /home/eghaffar/data/wordpress
DB_DATA = /home/eghaffar/data/mariadb

all: up

up: build
	@sudo mkdir -p $(WP_DATA) $(DB_DATA)
	@sudo chmod 777 $(WP_DATA) $(DB_DATA)
	docker-compose up -d --build

down:
	docker-compose down --remove-orphans

build:
	docker-compose build

clean:
	@docker-compose down -v --remove-orphans
	@sudo rm -rf $(WP_DATA) $(DB_DATA)
	@sudo mkdir -p $(WP_DATA) $(DB_DATA)
	@sudo chmod 777 $(WP_DATA) $(DB_DATA)

prune: clean
	@docker system prune -a --volumes -f

re: prune up

.PHONY: all up down build clean prune re
