#!/usr/bin/env bash

initialize() {
  echo "Generating config files from example files..."

  .docker/env/gen

  .docker/scripts/wait-for-it.sh -h ${INFO_DATABASE_HOST} -p ${INFO_DATABASE_PORT} -t 30

  echo "Initializing Database..."

  bundle exec rake db:create
  bundle exec rake db:schema:load
}

FOLDER_TEMP=tmp/docker
FILE_INIT=${FOLDER_TEMP}/init

ARG_HELP=
ARG_FORCE=

while [[ $# > 0 ]] ; do
  case $1 in
    -h|--help)
      ARG_HELP=YES
    ;;
    -f|--force)
      ARG_FORCE=YES
    ;;
  esac
  shift
done

if [[ -n "${ARG_HELP}" ]]; then
  echo "Initialize the app"
  echo "Usage:  $0 [OPTIONS]"
  echo "  -f, --force          Force an initialization even if one has already been done successfully"
  exit 0
fi

[[ -z "${ARG_FORCE}" ]] && [[ -f "${FILE_INIT}" ]] && exit 0

set -e

initialize

touch ${FILE_INIT}
