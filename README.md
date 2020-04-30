# `tinydevcrm-saas-starter`: Starter backend for TinyDevCRM (and other possible SaaS-based products)

## Get started

1.  Clone this repository:

    ```bash
    git clone https://github.com/yingw787/tinydevcrm-saas-starter.git /path/to/repository
    cd /path/to/repository
    ```

2.  Run:

    ```bash
    make run-dev
    ```

    Go to `localhost:8000` and see the debug screen.

## Overview

This starter template defines skeleton services on top of AWS infrastructure
learnings such as `tinydevcrm-infra`.

Some features include:

-   Token-based authentication using JSON Web Tokens
-   API-first backend using Django REST Framework
-   Operations separation using Docker and `docker-compose`.
-   Deployment to AWS using Elastic Container Registry, and automated
    deployments using CodeBuild and CodePipeline.

## System environment assumptions

-   Operating system: Ubuntu 20.04 LTS:

    ```bash
    $ lsb_release -a
    No LSB modules are available.
    Distributor ID: Ubuntu
    Description:    Ubuntu 20.04 LTS
    Release:        20.04
    Codename:       focal
    ```

-   `docker`, Linux container runtime:

    ```bash
    $ docker -v
    Docker version 19.03.8, build afacb8b7f0
    ```

-   `docker-compose`, multi-container single-host Docker runtime addition:

    ```bash
    $ docker-compose -v
    docker-compose version 1.23.2, build 1110ad01
    ```

-   `make`, `Makefile` execution runtime:

    ```bash
    $ make --version
    GNU Make 4.2.1
    Built for x86_64-pc-linux-gnu
    Copyright (C) 1988-2016 Free Software Foundation, Inc.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.
    ```
