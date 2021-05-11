FROM openjdk:8-jdk-alpine
WORKDIR /app
RUN apk update && apk add bash coreutils curl
COPY ./target/quarkus-db-0.0.1-SNAPSHOT-runner.jar app.jar
COPY ./entrypoint.sh .
EXPOSE 9090
ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]

