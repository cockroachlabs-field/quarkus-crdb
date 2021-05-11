#!/bin/bash

kubectl create secret generic cc-ca --from-file=./certs/cc-ca.crt

