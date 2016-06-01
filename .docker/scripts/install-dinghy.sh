#!/usr/bin/env bash

# Install dinghy, a custom virtual machine for Docker to run on Mac OS X
brew tap codekitchen/dinghy
brew install dinghy

# Start dinghy virtual machine
dinghy create --provider virtualbox
