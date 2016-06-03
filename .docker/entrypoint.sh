#!/usr/bin/env bash

# Initialize the database
INIT_FILE=tmp/init
if [ ! -f $INIT_FILE ]; then
  .docker/wait-for-it.sh -h $INFO_DATABASE_HOST -p $INFO_DATABASE_PORT -t 15
  if [ $? == "0" ]; then
    echo "Initializing Database..."

    bundle exec rake db:create
    bundle exec rake db:migrate

    touch $INIT_FILE
  fi
fi

# Remove server pid file that may be left by an unexpected shutdown
rm tmp/pids/server.pid

# Prefix `bundle` with `exec` so unicorn shuts down gracefully on SIGTERM (i.e. `docker stop`)
exec bundle exec rails s -p 3000 -b 0.0.0.0
