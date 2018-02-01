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
