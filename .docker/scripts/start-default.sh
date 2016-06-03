#!/usr/bin/env bash

export DOCKER_HOST=tcp://$(docker-machine ip):2376
export DOCKER_CERT_PATH=~/.docker/machine/machines/default
export DOCKER_TLS_VERIFY=1
export DOCKER_MACHINE_NAME=default
