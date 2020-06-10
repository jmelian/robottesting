#!/bin/bash

docker rm -f robot6 && \
docker build -t robottest . && \ 
docker run -dit -p 8001:80 --name robot6 robottest:latest && \
docker exec -it robot6 bash


