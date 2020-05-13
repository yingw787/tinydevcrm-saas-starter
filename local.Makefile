#!/usr/bin/env make
#
# In order to run this non-default Makefile, use `make -f local.Makefile` and
# then apply targets.

.PHONY: version run-dev run-prod clean-dev clean-prod aws-login

export GIT_REPO_ROOT ?= $(shell git rev-parse --show-toplevel)

# NOTE: Don't run the web Docker container in detached mode, since `python -m
# ipdb` will hook within `settings.py` and cause the container to fail to start.
run-dev:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.development.yaml --verbose up -d --build db
	@echo "Open http://localhost:8000 to see results."
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.development.yaml --verbose run --service-ports web

run-prod:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.production.yaml --verbose up -d --build
	sleep 5
	xdg-open http://localhost:1337/admin

clean-dev:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.development.yaml down -v
	docker images -q -f dangling=true -f label=application=todobackend | xargs -I ARGS docker rmi -f --no-prune ARGS

clean-prod:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.production.yaml down -v
	docker images -q -f dangling=true -f label=application=todobackend | xargs -I ARGS docker rmi -f --no-prune ARGS
