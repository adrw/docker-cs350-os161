DOCKER_COMPOSE=$(shell which docker-compose)
DOCKER_COMPOSE_TARGETS=-f docker-compose.yml

define DOCKER_NICE
  trap '$(DOCKER_COMPOSE) $(DOCKER_COMPOSE_TARGETS) down' SIGINT SIGTERM && \
  $(DOCKER_COMPOSE) $(DOCKER_COMPOSE_TARGETS)
endef

export DOCKER_NICE

default: run

init:
	bash -c "./setup.sh"

build: init
	bash -c "$$DOCKER_NICE build"

rebuild: init
	bash -c "$$DOCKER_NICE build --no-cache"

run: init
	bash -c "$$DOCKER_NICE up"
	bash -c "docker run -it -v $(shell pwd)/src:/root/cs350-os161 --entrypoint /bin/bash andrewparadi/os161"

down:
	bash -c "$$DOCKER_NICE down"

.PHONY: init
.PHONY: build
.PHONY: rebuild
.PHONY: run
