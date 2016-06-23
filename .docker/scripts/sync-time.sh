#!/usr/bin/env bash

MACHINE_NAME="$DOCKER_MACHINE_NAME"
while [[ $# > 0 ]]
do
  key="$1"
  case $key in
    *)
      MACHINE_NAME="$2"
      shift
    ;;
  esac
  shift
done

docker-machine ssh $MACHINE_NAME 'sudo ntpclient -s -h pool.ntp.org'
