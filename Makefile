DOCKER_COMPOSE=$(shell which docker-compose)
DOCKER_COMPOSE_TARGETS=-f docker-compose.yml

define DOCKER_NICE
  trap '$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_TARGETS) down' SIGINT SIGTERM && \
  $(DOCKER_COMPOSE) $(DOCKER_COMPOSE_TARGETS)
endef

export DOCKER_NICE

default: run

init:

build-downloads: init
	bash -c "wget https://raw.githubusercontent.com/andrewparadi/docker-os161/master/docker-compose.yml -O docker-compose.yml"
	bash -c "wget https://raw.githubusercontent.com/andrewparadi/docker-os161/master/Dockerfile -O Dockerfile"
	bash -c "wget -r -l 1 -nd -nH -A gz https://www.student.cs.uwaterloo.ca/~cs350/common/Install161NonCS.html"

build: build-downloads
	bash -c "$$DOCKER_NICE build"
	bash -c "rm *.gz"
	bash -c "docker run -it -v $(shell pwd)/src:/root/cs350-os161 --entrypoint /bin/bash dockeros161_api"

rebuild: build-downloads
	bash -c "$$DOCKER_NICE build --no-cache"
	bash -c "rm *.gz"
	bash -c "docker run -it -v $(shell pwd)/src:/root/cs350-os161 --entrypoint /bin/bash dockeros161_api"

run: init
	bash -c "docker run -it -v $(shell pwd)/src:/root/cs350-os161 --entrypoint /bin/bash andrewparadi/os161:latest"

down:
	bash -c "$$DOCKER_NICE down"

.PHONY: init
.PHONY: build
.PHONY: rebuild
.PHONY: run
