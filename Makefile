
name = inception

all:
	@echo "Configuring ${name}\n"
	@bash srcs/requirements/wordpress/tools/make_dir.sh
	@docker-compose -f ./srcs/docker-compose.yml --env-file srcs/.env up -d --build 
#	--build needed to force the compilation to create the image instead of getting it from docker hub which would be the default due to the same name

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
	@docker system prune -a --force	# remove all unused images
#	@sudo rm -rf ~/data/db-volume/*
#	@sudo rm -rf ~/data/www-vol/*
#	@sudo rm -rf ~/data

fclean:
	@echo "Cleaning everything that's got anything to do with ${name}!\n"
	@CONTAINERS=$$(docker ps -qa); if [ -n "$$CONTAINERS" ]; then docker stop $$CONTAINERS; fi
	@docker system prune --all --force --volumes	# remove all (also used) images
	@docker network prune --force	# remove all networks
	@docker volume prune --force	# remove all connected partitions
	@sudo rm -rf ~/data/db-volume/*
	@sudo rm -rf ~/data/www-vol/*
	@sudo rm -rf ~/data

.PHONY: all build stop re clean fclean
