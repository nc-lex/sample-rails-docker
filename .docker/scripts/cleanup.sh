#!/usr/bin/env bash

# Cleans up unnecessary Docker images and containers

# Make sure that exited containers are deleted.
docker rm -v $(docker ps -a -q -f status=exited)

# Remove unwanted ‘dangling’ images.
docker rmi $(docker images -f "dangling=true" -q)

# Remove unwanted ‘dangling’ volumes.
docker volume rm $(docker volume ls -qf dangling=true)
