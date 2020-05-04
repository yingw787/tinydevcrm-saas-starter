# Flight rules for Git

## What are "flight rules"?

A guide for astronauts (now, programmers using Git) about what to do when things go wrong.

>  *Flight Rules* are the hard-earned body of knowledge recorded in manuals that list, step-by-step, what to do if X occurs, and why. Essentially, they are extremely detailed, scenario-specific standard operating procedures. [...]

> NASA has been capturing our missteps, disasters and solutions since the early 1960s, when Mercury-era ground teams first started gathering "lessons learned" into a compendium that now lists thousands of problematic situations, from engine failure to busted hatch handles to computer glitches, and their solutions.

&mdash; Chris Hadfield, *An Astronaut's Guide to Life*.

## Operations

### `make aws-login` fails with MFA token

#### Problem

This failure assumes an IAM user has been configured for the command line as per
instructions in `SETUP.md` in `tinydevcrm-infra`.

Sometimes, given a long enough session, the MFA token will become invalid, and
ECR logins will fail as a result, instead of `awscli` requesting a new token:

```bash
$ make aws-login
An error occurred (UnrecognizedClientException) when calling the GetAuthorizationToken operation: The sec
urity token included in the request is invalid.
make: *** [Makefile:28: aws-login] Error 255
```

#### Resolution

Re-export `AWS_PROFILE`, and try again:

```bash
$ export AWS_PROFILE=tinydevcrm-user
$ make aws-login
$(aws ecr get-login --no-include-email)
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /home/yingw787/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

### `make publish-app` fails with authentication error

#### Problem

When running `make publish-app` or otherwise pushing Docker images to AWS ECR,
sometimes the process errors out:

This is different from having `awscli` properly configured and having an MFA
token for the AWS IAM user.

```bash
ERROR: compose.cli.main.main: denied: Your authorization token has expired. Reauthenticate and try again.
```

#### Resolution

AWS ECR requires its own login.

Re-run `make aws-login` and then re-try the push:

```bash
make aws-login
make publish-app
```

This should be templated out in the `Makefile` using dependent targets.

### `make publish-app` fails with tag not found error

#### Problem

Publishing `app`, `db`, and `nginx` Docker images requires the latest commit
tag. If those tagged images don't exist on the local compute instance, then
`docker push` will error out:

```bash
ERROR: compose.cli.main.main: tag does not exist: 267131297086.dkr.ecr.us-east-1.amazonaws.com/tinydevcrm-ecr/app:aafc2c5
```

#### Resolution

Ensure that the `docker build` process is run before every push. This should be
templated out in the `Makefile`.
