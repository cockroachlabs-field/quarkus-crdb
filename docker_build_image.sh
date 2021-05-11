#!/bin/bash

. ./include.sh

docker build -t $dockerhub_id/$img_name .

