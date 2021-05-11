#!/bin/bash

port=9090
#url="http://localhost:$port/users"
url="http://35.245.163.14/users"

curl -X POST -H "Content-Type: application/json" -d '{"username": "test", "password": "secret", "email": "test@example.org"}' $url

