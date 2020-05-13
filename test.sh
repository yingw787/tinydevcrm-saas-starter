#!/bin/bash

# Register a new test user.
curl --header "Content-Type: application/json" -X POST http://localhost:1337/v1/auth/users/register/ --data '{"primary_email": "me@yingw787.com", "password": "test1234"}'

#
