#!/usr/bin/env bash

MACHINE_NAME="dinghy"
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

eval "$(docker-machine env $MACHINE_NAME)"
