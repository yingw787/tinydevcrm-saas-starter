.PHONY: version run-dev run-prod clean-dev clean-prod

export APP_VERSION ?= $(shell git rev-parse --short HEAD)
export GIT_REPO_ROOT ?= $(shell git rev-parse --show-toplevel)

version:
	@ echo '{"Version": "$(APP_VERSION)"}'

run-dev:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.development.yaml --verbose up -d --build
	xdg-open http://localhost:8000/admin

run-prod:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.production.yaml --verbose up -d --build
	xdg-open http://localhost:1337/admin

clean-dev:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.development.yaml down -v
	docker images -q -f dangling=true -f label=application=todobackend | xargs -I ARGS docker rmi -f --no-prune ARGS

clean-prod:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.production.yaml down -v
	docker images -q -f dangling=true -f label=application=todobackend | xargs -I ARGS docker rmi -f --no-prune ARGS
