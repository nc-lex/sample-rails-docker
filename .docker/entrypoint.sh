#!/usr/bin/env bash

INIT_FILE=tmp/init
if [ ! -f $INIT_FILE ]; then
  echo "Initializing Database..."

  .docker/wait-for-it.sh -h $INFO_DATABASE_HOST -p $INFO_DATABASE_PORT -t 15
  if [ $? == "0" ]; then
    rake db:create
    rake db:schema:load
  fi

  touch $INIT_FILE
fi

# Remove server pid file that may be left by an unexpected shutdown
rm tmp/pids/server.pid

# Prefix `bundle` with `exec` so unicorn shuts down gracefully on SIGTERM (i.e. `docker stop`)
exec bundle exec rails s -p 3000 -b 0.0.0.0
