.PHONY: dev clean

export APP_VERSION ?= $(shell git rev-parse --short HEAD)
export GIT_REPO_ROOT ?= $(shell git rev-parse --show-toplevel)

version:
	@ echo '{"Version": "$(APP_VERSION)"}'

# Runs development environment locally.
dev:
	docker-compose -f $(GIT_REPO_ROOT)/services/app/development.Dockerfile --verbose up -d --build

clean:
	docker-compose down -v
	docker images -q -f dangling=true -f label=application=todobackend | xargs -I ARGS docker rmi -f --no-prune ARGS
