.PHONY: version run-dev run-prod clean-dev clean-prod aws-login

export APP_VERSION ?= $(shell git rev-parse --short HEAD)
export GIT_REPO_ROOT ?= $(shell git rev-parse --show-toplevel)

# In order to run these commands, make sure that `tinydevcrm-infra` is set up
# and `awscli` is installed, and `aws configure` is properly run according to
# `SETUP.md`.
export AWS_ACCOUNT_ID ?= $(shell aws sts get-caller-identity --query Account --output text)
export AWS_REGION ?= $(shell aws configure get region)

# Change to your AWS ECR app repository name, after configuring in
# `aws-ecr.yaml` in this repository.
export AWS_ECR_APP_REPOSITORY_NAME=tinydevcrm-ecr/app
export AWS_ECR_DB_REPOSITORY_NAME=tinydevcrm-ecr/db
export AWS_ECR_NGINX_REPOSITORY_NAME=tinydevcrm-ecr/nginx

version:
	@ echo '{"Version": "$(APP_VERSION)"}'

# Local compute commands #

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

run-aws-config:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.aws.yaml config

run-aws-test:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.aws.yaml --verbose build --pull release
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.aws.yaml --verbose build
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.aws.yaml --verbose run test

# AWS-specific commands #

aws-login:
	$$(aws ecr get-login --no-include-email)

aws-create-ecr:
	aws cloudformation create-stack --stack-name tinydevcrm-ecr --template-body file://aws-ecr.yaml --capabilities CAPABILITY_NAMED_IAM

aws-deploy-ecr:
	aws cloudformation deploy --stack-name tinydevcrm-ecr --template-file aws-ecr.yaml --capabilities CAPABILITY_NAMED_IAM

aws-delete-ecr:
	aws cloudformation delete-stack --stack-name tinydevcrm-ecr

aws-create-ecs:
	aws cloudformation create-stack --stack-name tinydevcrm-ecs --template-body file://aws-ecs.yaml --capabilities CAPABILITY_NAMED_IAM

aws-deploy-ecs:
	aws cloudformation deploy --stack-name tinydevcrm-ecs --template-file aws-ecs.yaml --capabilities CAPABILITY_NAMED_IAM

aws-delete-ecs:
	aws cloudformation delete-stack --stack-name tinydevcrm-ecs
