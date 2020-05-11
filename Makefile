#!/usr/bin/env make

export APP_VERSION ?= $(shell git rev-parse --short HEAD)
export GIT_REPO_ROOT ?= $(shell git rev-parse --show-toplevel)

# In order to run these commands, make sure that `tinydevcrm-infra` is set up
# and `awscli` is installed, and `aws configure` is properly run according to
# `SETUP.md`.
export AWS_ACCOUNT_ID ?= $(shell aws sts get-caller-identity --query Account --output text)
export AWS_REGION ?= $(shell aws configure get region)

# Change to your AWS IAM profile, set up as part of `aws-iam.yaml`..
export AWS_PROFILE=tinydevcrm-user

# Change to your AWS ECR app repository name, after configuring in
# `aws-ecr.yaml` in this repository.
export AWS_ECR_APP_REPOSITORY_NAME=tinydevcrm-ecr/app
export AWS_ECR_DB_REPOSITORY_NAME=tinydevcrm-ecr/db
export AWS_ECR_NGINX_REPOSITORY_NAME=tinydevcrm-ecr/nginx

export AWS_NLB_DNS_NAME ?= $(shell aws cloudformation describe-stacks --stack-name tinydevcrm-db --query "Stacks[0].Outputs[?OutputKey=='DatabaseNLBDNSName'].OutputValue" --output text)

version:
	@ echo '{"Version": "$(APP_VERSION)"}'

# Local compute commands #

local-config:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.aws.yaml config

local-up:
	# docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.aws.yaml --verbose up --build --abort-on-container-exit migrate
	# docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.aws.yaml --verbose run app python3 manage.py collectstatic --no-input
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.aws.yaml --verbose up -d --build db
	# sleep 5
	# xdg-open http://localhost:1337/admin

local-down:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.aws.yaml down -v
	docker images -q -f dangling=true -f label=application=tinydevcrm | xargs -I ARGS docker rmi -f --no-prune ARGS

local-createsuperuser:
	docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.aws.yaml exec app python3 manage.py createsuperuser

# Change PGPASSWORD, --username, and --db values to match those in
# db/conf/.env.aws
local-psql:
	PGPASSWORD=tinydevcrm docker-compose -f ${GIT_REPO_ROOT}/services/docker-compose.aws.yaml exec db psql --username=tinydevcrm --db=tinydevcrm_api_prod

publish-app: aws-login
	docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_APP_REPOSITORY_NAME}:${APP_VERSION} -f ${GIT_REPO_ROOT}/services/app/aws.Dockerfile ${GIT_REPO_ROOT}/services/app
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_APP_REPOSITORY_NAME}:${APP_VERSION}

	docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_APP_REPOSITORY_NAME}:latest -f ${GIT_REPO_ROOT}/services/app/aws.Dockerfile ${GIT_REPO_ROOT}/services/app
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_APP_REPOSITORY_NAME}:latest

publish-db: aws-login
	docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_DB_REPOSITORY_NAME}:${APP_VERSION} -f ${GIT_REPO_ROOT}/services/db/Dockerfile ${GIT_REPO_ROOT}/services/db
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_DB_REPOSITORY_NAME}:${APP_VERSION}

	docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_DB_REPOSITORY_NAME}:latest -f ${GIT_REPO_ROOT}/services/db/Dockerfile ${GIT_REPO_ROOT}/services/db
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_DB_REPOSITORY_NAME}:latest

publish-nginx: aws-login
	docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_NGINX_REPOSITORY_NAME}:${APP_VERSION} -f ${GIT_REPO_ROOT}/services/nginx/aws.Dockerfile ${GIT_REPO_ROOT}/services/nginx
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_NGINX_REPOSITORY_NAME}:${APP_VERSION}

	docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_NGINX_REPOSITORY_NAME}:latest -f ${GIT_REPO_ROOT}/services/nginx/aws.Dockerfile ${GIT_REPO_ROOT}/services/nginx
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_NGINX_REPOSITORY_NAME}:latest

# AWS remote commands #

aws-login:
	$$(aws ecr get-login --no-include-email)

aws-create-ecr:
	aws cloudformation create-stack --stack-name tinydevcrm-ecr --template-body file://aws-ecr.yaml --capabilities CAPABILITY_NAMED_IAM

aws-deploy-ecr:
	aws cloudformation deploy --stack-name tinydevcrm-ecr --template-file aws-ecr.yaml --capabilities CAPABILITY_NAMED_IAM

aws-delete-ecr:
	aws cloudformation delete-stack --stack-name tinydevcrm-ecr

aws-create-ecs: publish-app publish-db
	aws cloudformation create-stack --stack-name tinydevcrm-ecs --template-body file://aws-ecs.yaml --parameters file://aws-ecs-params.json --capabilities CAPABILITY_NAMED_IAM

aws-deploy-ecs:
	aws cloudformation deploy --stack-name tinydevcrm-ecs --template-file aws-ecs.yaml --capabilities CAPABILITY_NAMED_IAM

aws-delete-ecs:
	aws cloudformation delete-stack --stack-name tinydevcrm-ecs

aws-db-create:
	aws cloudformation create-stack --stack-name tinydevcrm-db --template-body file://db.yaml --parameters file://db-params.json --capabilities CAPABILITY_NAMED_IAM

aws-db-deploy:
	aws cloudformation deploy --stack-name tinydevcrm-db --template-file db.yaml --capabilities CAPABILITY_NAMED_IAM

aws-db-terminate:
	aws cloudformation delete-stack --stack-name tinydevcrm-db

# Conditioned on having a deployed database up and running.
aws-psql:
	PGPASSWORD=my-secret-pw psql -U postgres -h $(AWS_NLB_DNS_NAME) -d postgres
