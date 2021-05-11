#!/bin/bash

. ./include.sh

docker tag $dockerhub_id/$img_name $dockerhub_id/$img_name:$tag

docker image tag $dockerhub_id/$img_name:$tag $dockerhub_id/$img_name:latest

docker push $dockerhub_id/$img_name:$tag

