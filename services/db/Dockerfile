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

FROM postgres:12.0-alpine
