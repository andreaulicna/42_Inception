
name = inception

all:
	@echo "Configuring ${name}\n"
	@bash srcs/requirements/wordpress/tools/make_dir.sh
	@docker-compose -f ./srcs/docker-compose.yml --env-file srcs/.env up -d

build:
	@echo "Building ${name}\n"
	@bash srcs/requirements/wordpress/tools/make_dir.sh
	@docker-compose -f ./srcs/docker-compose.yml --env-file srcs/.env up -d --build

stop:
	@echo "Stopping ${name}\n"
	@docker-compose -f ./srcs/docker-compose.yml --env-file srcs/.env down

re: clean all

clean: stop
	@echo "Cleaning ${name}\n"
	@docker system prune -a				# remove all unused images
	@sudo rm -rf ~/data/mariadb/*
	@sudo rm -rf ~/data/wordpress/*

fclean:
	@echo "Cleaning everythingi that's got anything to do with ${name}!\n"
	@docker stop $$(docker ps -qa)			# stop all running containers
	@docker system prune --all --force --volumes	# remove all (also used) images
	@docker network prune --force			# remove all networks
	@docker volume prune --force			# remove all connected partitions
	@sudo rm -rf ~/data/mariadb/*
	@sudo rm -rf ~/data/wordpress/*

.PHONY: all build stop re clean fclean
