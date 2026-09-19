ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
COMPOSE := docker compose -f $(ROOT_DIR)/.opencode/docker-compose.yml

.PHONY: run web build stop clean

# Interactive terminal UI. Works for any host UID/GID — no configuration.
run:
	$(COMPOSE) run --rm opencode

# Web UI on the host (http://localhost:5174). Override port: OPENCODE_WEB_PORT=8080 make web
web:
	$(COMPOSE) up opencode-web

build:
	$(COMPOSE) build

stop:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v
