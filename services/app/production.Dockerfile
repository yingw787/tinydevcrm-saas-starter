# Dockerized production environment.

###########
# BUILDER #
###########
#
# This references Docker's ability to generate intermediate images to build
# items, then discard them in production to reduce final image size:
# https://docs.docker.com/develop/develop-images/multistage-build/

# pull official base image
FROM python:3.8.0-alpine as builder

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install psycopg2 dependencies
RUN apk update && \
    apk add postgresql-dev gcc python3-dev musl-dev

# lint
RUN pip install --upgrade pip
RUN pip install flake8
COPY . /usr/src/app/
# RUN flake8 --ignore=E501,F401 .

# install dependencies
COPY ./conf/requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/app/wheels -r requirements.txt


#########
# FINAL #
#########

# pull official base image
FROM python:3.8.0-alpine

# create directory for the app user
RUN mkdir -p /home/app

# create the app user
#
# This is important for security considerations; Docker runs container processes
# as root inside of a container. This is a bad practice since attackers can gain
# root access to the Docker host if they manage to break out of the container.
# If you're root in the container, you'll be root on the host.
RUN addgroup -S app && adduser -S app -G app

# create the home directory
ENV HOME=/home/app
ENV APP_HOME=/home/app/web
RUN mkdir $APP_HOME
# Need to create the directory here, since we're using a non-root user, we'll
# get a permission denied error when collectstatic command is run on a
# non-existent directory. We can either create the directory beforehand, or
# change the permissions of the directory after mounting (this is former
# solution).
RUN mkdir $APP_HOME/staticfiles
RUN mkdir $APP_HOME/mediafiles
WORKDIR $APP_HOME

# install dependencies
RUN apk update && apk add libpq
COPY --from=builder /usr/src/app/wheels /wheels
COPY --from=builder /usr/src/app/requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache /wheels/*

# copy entrypoint.production.sh
COPY ./conf/entrypoint.production.sh $APP_HOME

# copy project
COPY ./src $APP_HOME

# chown all the files to the app user
RUN chown -R app:app $APP_HOME

# change to the app user
USER app

# run entrypoint.prod.sh
ENTRYPOINT [ "/home/app/web/entrypoint.production.sh" ]
