mkfile_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

build:
	docker-compose build

run:
	docker-compose up -d
  
stop:
	docker-compose kill
  
clean: stop
	docker-compose rm
	
clear:
	docker-compose down -v

rebuild: clean build run
	
update_email_aliases:
	python $(mkfile_dir)tbp-postfix/update_email_aliases.py