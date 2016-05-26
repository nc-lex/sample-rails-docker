#!/usr/bin/env bash

# Install dinghy, a custom virtual machine for Docker to run on Mac OS X
brew tap codekitchen/dinghy
brew install dinghy

# Start dinghy virtual machine
dinghy create --provider virtualbox

# Let Docker locate the dinghy virtual machine
export DOCKER_HOST=tcp://192.168.99.101:2376
export DOCKER_CERT_PATH=/Users/lex/.docker/machine/machines/dinghy
export DOCKER_TLS_VERIFY=1
export DOCKER_MACHINE_NAME=dinghy
