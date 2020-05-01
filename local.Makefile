#!/usr/bin/env make
#
# In order to run this non-default Makefile, use `make -f local.Makefile` and
# then apply targets.

.PHONY: version run-dev run-prod clean-dev clean-prod aws-login

export GIT_REPO_ROOT ?= $(shell git rev-parse --show-toplevel)

run-dev:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.development.yaml --verbose up -d --build
	sleep 5
	xdg-open http://localhost:8000/admin

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
