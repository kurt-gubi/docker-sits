#!/bin/bash

docker build -t oracle:11.2.0.3 ./oracle-11.2.0.3 && \
docker build -t oracle:12.2.0.1 ./oracle-12.2.0.1 && \
docker build -t oracle:sits_970 ./oracle-sits_970 && \
docker build -t oracle:sits_990 ./oracle-sits_990 && \
docker build -t sits:app_970 ./sits-app_970 && \
docker build -t sits:app_990 ./sits-app_990 && \
docker build -t sits:webapp ./sits-webapp && \
docker build -t sits:web ./sits-web && \
docker system prune -f && \
docker volume prune -f
