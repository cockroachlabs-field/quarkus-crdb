#!/bin/bash

. ./include.sh

img="$dockerhub_id/$img_name:$tag"

export JDBC_URL="jdbc:postgresql://free-tier.gcp-us-central1.cockroachlabs.cloud:26257/mgoddard-eta-1966.defaultdb?sslmode=require"
export PGUSER="michael"
export PGPASSWORD="nEOPc6dC1DsVg6Xp"
export HTTP_PORT="9090"

#docker pull $img:$tag
echo "docker run -e JDBC_URL -e PGUSER -e PGPASSWORD -e HTTP_PORT --publish $HTTP_PORT:$HTTP_PORT $img"
docker run -e JDBC_URL -e PGUSER -e PGPASSWORD -e HTTP_PORT --publish $HTTP_PORT:$HTTP_PORT $img

