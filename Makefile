DOCKER_COMPOSE=$(shell which docker-compose)
DOCKER_COMPOSE_TARGETS=-f docker-compose.yml

define DOCKER_NICE
  trap '$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_TARGETS) down' SIGINT SIGTERM && \
  $(DOCKER_COMPOSE) $(DOCKER_COMPOSE_TARGETS)
endef

export DOCKER_NICE

default: run

init:

build:
	bash -c "$$DOCKER_NICE build"
	bash -c "docker run -it -v $(shell pwd)/src:/root/cs350-os161 --entrypoint /bin/bash dockeros161_api"

rebuild:
	bash -c "$$DOCKER_NICE build --no-cache"
	bash -c "docker run -it -v $(shell pwd)/src:/root/cs350-os161 --entrypoint /bin/bash dockeros161_api"

run: init
	bash -c "$$DOCKER_NICE up"
	bash -c "docker run -it -v $(shell pwd)/src:/root/cs350-os161 --entrypoint /bin/bash andrewparadi/os161:latest"

down:
	bash -c "$$DOCKER_NICE down"

.PHONY: init
.PHONY: build
.PHONY: rebuild
.PHONY: run
