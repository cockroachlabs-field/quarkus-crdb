#!/bin/bash

java -Djdk.tls.client.protocols=TLSv1.2 \
  -Dquarkus.datasource.url=$JDBC_URL \
  -Dquarkus.datasource.username=$PGUSER \
  -Dquarkus.datasource.password=$PGPASSWORD \
  -Dquarkus.http.port=$HTTP_PORT \
  -jar app.jar

