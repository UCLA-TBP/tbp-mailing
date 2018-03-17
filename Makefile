mkfile_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
backend := $(shell cd /opt/tbpsite; docker-compose ps -q backend)
postfix := $(shell docker-compose ps -q postfix)

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
	
update_virtual_domains: 
	docker exec $(backend) mkdir -p /etc/postfix_conf
	docker cp $(mkfile_dir)tbp-postfix/update_virtual_conf/. $(backend):/etc/postfix_conf
	docker exec $(backend) python /etc/postfix_conf/update_virtual_domains.py
	docker cp $(backend):/etc/postfix_conf/virtual $(mkfile_dir)tbp-postfix/config/virtual
	docker cp $(backend):/etc/postfix_conf/vmailbox $(mkfile_dir)tbp-postfix/config/vmailbox
	docker cp $(backend):/etc/postfix_conf/restrict_classes/tbponly $(mkfile_dir)tbp-postfix/config/restrict_classes/tbponly
	docker cp $(backend):/etc/postfix_conf/restrict_classes/houseleaders $(mkfile_dir)tbp-postfix/config/restrict_classes/houseleaders
	
update: update_virtual_domains rebuild

