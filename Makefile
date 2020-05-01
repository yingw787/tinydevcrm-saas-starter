#!/usr/bin/env make

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

config-aws:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.aws.yaml config

run-aws-release:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.aws.yaml --verbose up --build --abort-on-container-exit migrate
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.aws.yaml --verbose run app python3 manage.py collectstatic --no-input
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.aws.yaml --verbose up -d --build

publish-aws:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.aws.yaml --verbose push release app db nginx

clean-aws:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.aws.yaml down -v
	docker images -q -f dangling=true -f label=application=tinydevcrm | xargs -I ARGS docker rmi -f --no-prune ARGS

# AWS remote commands #

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
