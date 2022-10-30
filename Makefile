ifneq (,$(wildcard ./.env))
    include .env
    export
endif

webpack: webpack-clear-assets clear-assets webpack-build webpack
deploy-local: pull config-local composer-install cache webpack
deploy-test: pull config-test composer-install cache webpack
deploy-docker: docker-pull config-docker docker-composer-install cache docker-webpack

docker: config-docker docker-build docker-up cache docker-webpack
docker-rebuild: docker-mysqldump docker-stop dumpmv docker
docker-webpack: clear-assets docker-webpack-install docker-webpack-build webpack-copy

mysqlimport: drop import

composer-install:
	cd $(COMPOSER_DIR) && composer install

docker-composer-install:
	docker exec -ti $(shell docker ps --filter name=$(PROJECT_NAME)-php-fpm -a -q) sh -c "cd $(COMPOSER_DIR) && composer install"

push:
	git add . && git commit -m "update" && git push

pull:
	git pull

docker-pull:
	sudo -u www-data git pull

cache:
	rm -rf $(ROOT_DIR)/bitrix/cache/
	rm -rf $(ROOT_DIR)/bitrix/managed_cache/
	rm -rf $(ROOT_DIR)/bitrix/stack_cache/

mysqldump:
	mysqldump -h $(DB_HOST) -u $(DB_USER) -p$(DB_PWD) $(DB_NAME) | gzip > $(DB_BACKUP_PATH)

docker-mysqldump:
	docker exec -ti $(shell docker ps --filter name=php-fpm -a -q) sh -c "mysqldump -h $(DB_HOST) -u $(DB_USER) -p$(DB_PWD) $(DB_NAME) | gzip > $(DB_BACKUP_PATH)"

dumpmv:
	mv $(DB_BACKUP_PATH) $(DB_START_FILE_PATH)

drop:
	mysql -h $(DB_HOST) -u $(DB_USER) -p$(DB_PWD) $(DB_NAME) --execute="drop database $(DB_NAME); CREATE DATABASE $(DB_NAME) DEFAULT CHARACTER SET utf8 COLLATE UTF8_UNICODE_CI;"

import:
	gunzip <  $(DB_BACKUP_PATH) | mysql -h $(DB_HOST) -u $(DB_USER) -p$(DB_PWD) $(DB_NAME)

webpack-build:
	cd $(MARKUP) && npm run build

webpack-clear-assets:
	rm -rf $(MARKUP)/build

clear-assets:
	rm -rf $(ASSETS)

docker-webpack-install:
	docker exec -ti $(shell docker ps --filter name=$(PROJECT_NAME)-markup -a -q) sh -c "cd $(MARKUP) && npm install"

docker-webpack-build:
	docker exec -ti $(shell docker ps --filter name=$(PROJECT_NAME)-markup -a -q) sh -c "cd $(MARKUP) && npm run build"

webpack-copy:
	cp -R $(MARKUP)/build/js $(ASSETS)
	cp -R $(MARKUP)/build/assets/images $(ASSETS)
	cp -R $(MARKUP)/build/css $(ASSETS)

config-local:
	cp $(ROOT_DIR)/bitrix/.settings.local.php $(ROOT_DIR)/bitrix/.settings.php
	cp $(ROOT_DIR)/bitrix/php_interface/dbconn.local.php $(ROOT_DIR)/bitrix/php_interface/dbconn.php
	cp $(ROOT_DIR)/bitrix/php_interface/after_connect_d7.local.php $(ROOT_DIR)/bitrix/php_interface/after_connect_d7.php
	cp $(ROOT_DIR)/bitrix/php_interface/after_connect.local.php $(ROOT_DIR)/bitrix/php_interface/after_connect.php
	cp $(ROOT_DIR)/.htaccess.local $(ROOT_DIR)/.htaccess

config-test:
	cp $(ROOT_DIR)/bitrix/.settings.test.php $(ROOT_DIR)/bitrix/.settings.php
	cp $(ROOT_DIR)/bitrix/php_interface/dbconn.test.php $(ROOT_DIR)/bitrix/php_interface/dbconn.php
	cp $(ROOT_DIR)/bitrix/php_interface/after_connect_d7.test.php $(ROOT_DIR)/bitrix/php_interface/after_connect_d7.php
	cp $(ROOT_DIR)/bitrix/php_interface/after_connect.test.php $(ROOT_DIR)/bitrix/php_interface/after_connect.php
	cp $(ROOT_DIR)/.htaccess.test $(ROOT_DIR)/.htaccess

config-docker:
	cp $(ROOT_DIR)/bitrix/.settings.docker.php $(ROOT_DIR)/bitrix/.settings.php
	cp $(ROOT_DIR)/bitrix/php_interface/dbconn.docker.php $(ROOT_DIR)/bitrix/php_interface/dbconn.php
	cp $(ROOT_DIR)/bitrix/php_interface/after_connect_d7.docker.php $(ROOT_DIR)/bitrix/php_interface/after_connect_d7.php
	cp $(ROOT_DIR)/bitrix/php_interface/after_connect.docker.php $(ROOT_DIR)/bitrix/php_interface/after_connect.php
	cp $(ROOT_DIR)/.htaccess.docker $(ROOT_DIR)/.htaccess

docker-build:
	docker-compose build

docker-up:
	docker-compose up -d

docker-stop:
	docker stop $(shell docker ps --filter name=$(PROJECT_NAME) -q)
	docker rm $(shell docker ps --filter name=$(PROJECT_NAME) -a -q)

# В архиве лежат фотки из готового решения.
upload:
	rm -rf $(UPLOAD_PATH) && cd $(ROOT_DIR) && unzip upload.zip && chmod -R 0777 $(UPLOAD_DIR)

fix-owner:
	find $(ROOT_DIR) -type d -exec chown www-data:www-data {} \;
	find $(ROOT_DIR) -type f -exec chown www-data:www-data {} \;