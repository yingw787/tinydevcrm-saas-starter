# Production environment to be shipped to AWS.

# TESTING STAGE #

# Pull official base image
FROM python:3.8.0-alpine as builder

# Install build dependencies

# Copy requirements

# Build and install requirements

# Copy source code

# Test entrypoint

# RELEASE STAGE #

# Install operating system dependencies

# Create app user

# Copy and install application source and pre-built dependencies.

# Create Docker volume.

# Entrypoint script.
COPY ./conf/entrypoint.aws.sh /usr/bin/entrypoint
RUN chmod +x /usr/bin/entrypoint
ENTRYPOINT [ "/sr/bin/entrypoint" ]

# Set working directory and application user.
WORKDIR /usr/src/app
USER app
