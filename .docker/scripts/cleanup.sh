#!/usr/bin/env bash

#Make sure that exited containers are deleted.
docker rm -v $(docker ps -a -q -f status=exited)

#Remove unwanted ‘dangling’ images.  
docker rmi $(docker images -f "dangling=true" -q)
