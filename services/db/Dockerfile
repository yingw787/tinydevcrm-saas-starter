# Dockerfile to build
#
# A custom Dockerfile is required in order to build 'pg_cron', the data-driven
# colocated job scheduler. Using 'pg_cron' is important for this project to sync
# state between job scheduling and database views with minimal memory and
# complexity footprint.
#
# TODO: Use a multistage Docker build in order to create an Alpine build for
# 'pg_cron' from source without bloating the production image size:
# https://docs.docker.com/develop/develop-images/multistage-build/
#
# TODO: Use a non-root user in order to run PostgreSQL.

FROM postgres:12.0-alpine AS builder
LABEL application="tinydevcrm-db"

# Install dependencies.
RUN apk add gcc
RUN apk add git
RUN apk add make
RUN apk add musl-dev

# Clone the repository and checkout a specific commit.
RUN git clone https://github.com/tinydevcrm/pg_cron.git /home/pg_cron
# Set work directory.
WORKDIR /home/pg_cron

RUN git checkout 2262d9fadedc9fe0ff16b7690b1d4d95772318cb

# Build.
RUN make

FROM postgres:12.0-alpine AS release
LABEL application="tinydevcrm-db"

# Flatten `make install` commands to reduce build needs.

RUN mkdir -p '/usr/local/lib/postgresql'
RUN mkdir -p '/usr/local/share/postgresql/extension'

# TODO: Might want to change `chown` and not run `postgres` as the default user
# for security purposes.
WORKDIR /home

COPY --from=builder /home/pg_cron/pg_cron.so /home/pg_cron.so
COPY --from=builder /home/pg_cron/pg_cron.control /home/pg_cron.control
COPY --from=builder /home/pg_cron/pg_cron--1.1--1.2.sql /home/pg_cron--1.1--1.2.sql
COPY --from=builder /home/pg_cron/pg_cron--1.0--1.1.sql /home/pg_cron--1.0--1.1.sql
COPY --from=builder /home/pg_cron/pg_cron--1.0.sql /home/pg_cron--1.0.sql

RUN /usr/bin/install -c -m 755 /home/pg_cron.so '/usr/local/lib/postgresql/pg_cron.so'
RUN /usr/bin/install -c -m 644 /home/pg_cron.control '/usr/local/share/postgresql/extension/'
RUN /usr/bin/install -c -m 644 /home/pg_cron--1.1--1.2.sql '/usr/local/share/postgresql/extension/'
RUN /usr/bin/install -c -m 644 /home/pg_cron--1.0--1.1.sql '/usr/local/share/postgresql/extension/'
RUN /usr/bin/install -c -m 644 /home/pg_cron--1.0.sql '/usr/local/share/postgresql/extension/'
