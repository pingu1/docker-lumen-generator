BUILDDIR=$(shell pwd)
ENV ?= local

# Looks ugly in your editor, but the formatting directives used are:
# * \33[1m -- start bold
# * \33[4m -- start underline
# * \33[1;4m -- start bold and underline
# * \33[0m -- reset formatting
# See: https://misc.flogisoft.com/bash/tip_colors_and_formatting

help:
	@printf "\33[1mAvailable make commands\33[0m:\n \
* \33[1;4mup\33[0m: initialize and start containers\n \
* \33[1;4mdown\33[0m: stop running containers\n \
* \33[1;4mreload\33[0m: restart containers\n \
* \33[1;4mrebuild\33[0m: rebuild images\n \
* \33[1;4minit\33[0m: init a Lumen PHP application available on http://tinyapi.local\n"

up-silent:
	mkdir -p docker/mysql/dbdata
	docker-compose up --force-recreate -V -d --remove-orphan

up: up-silent
	@echo
	@docker-compose ps
	@docker-compose exec php php -r 'echo "\33[4mApp\33[0m: PHP " . phpversion() . "\n";'

down:
	docker-compose down --remove-orphan

reload: down up

restart:
	docker-compose restart

rebuild:
	${MAKE} down
	@docker-compose build --no-cache --pull --force-rm --parallel
	${MAKE} up

init:
	@if find ./app_src/ -mindepth 1 -print -quit 2>/dev/null | grep -q .; then \
		printf "\n"; \
		printf "\33[1;91mDirectory not empty, cannot init project\33[0m\n"; \
		printf "\n"; \
	else \
		${MAKE} down; \
		rm -rf ./docker/mysql/dbdata; \
		mkdir -p ./docker/mysql/dbdata; \
		docker-compose build --no-cache --pull --force-rm --parallel; \
		docker-compose up -V -d; \
		docker-compose exec php composer create-project --prefer-dist laravel/lumen /var/www/; \
		printf "\n"; \
		printf "\33[1;4mApplication initalized with success\33[0m\n\n"; \
		printf "Add     \"127.0.0.1 tinyapi.local\"    as well as    \"127.0.0.1 db\"to your /etc/hosts file and visit http://tinyapi.local\n\n"; \
		printf "\n"; \
		cp ./.env.api.example ./app_src/.env; \
		cp ./.env.example ./.env; \
	fi;

