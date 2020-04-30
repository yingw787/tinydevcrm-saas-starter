.PHONY: version run-dev run-prod clean-dev clean-prod aws-login

export APP_VERSION ?= $(shell git rev-parse --short HEAD)
export GIT_REPO_ROOT ?= $(shell git rev-parse --show-toplevel)

version:
	@ echo '{"Version": "$(APP_VERSION)"}'

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

aws-login:
	$$(aws ecr get-login --no-include-email)

aws-create-ecr:
	aws cloudformation create-stack --stack-name tinydevcrm-ecr --template-body file://aws-ecr.yaml --capabilities CAPABILITY_NAMED_IAM

aws-deploy-ecr:
	aws cloudformation deploy --stack-name tinydevcrm-ecr --template-file aws-ecr.yaml --capabilities CAPABILITY_NAMED_IAM

aws-delete-ecr:
	aws cloudformation delete-stack --stack-name tinydevcrm-ecr
