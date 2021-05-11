#!/bin/bash

#port=9090
#url="http://localhost:$port/users"
url="http://$LB_EXT_IP/users"

curl -X POST -H "Content-Type: application/json" -d '{"username": "test", "password": "secret", "email": "test@example.org"}' $url

