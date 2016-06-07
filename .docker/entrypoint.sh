#!/usr/bin/env bash

SIGWAITBASH=31

printPrompt() {
  echo "Run \"kill 1\" in bash to start the server"
}

waitBash() {
  trap "printPrompt" $SIGWAITBASH
  echo "Waiting for bash..."
  printPrompt

  trap "startServer" SIGTERM
  while true ; do sleep 1 ; done
}

startServer() {
  trap - $SIGWAITBASH SIGTERM

  # Initialize the database
  INIT_FILE=tmp/init
  if [ ! -f $INIT_FILE ]; then
    .docker/wait-for-it.sh -h $INFO_DATABASE_HOST -p $INFO_DATABASE_PORT -t 30
    if [ $? == "0" ]; then
      echo "Initializing Database..."

      bundle exec rake db:create
      bundle exec rake db:schema:load

      touch $INIT_FILE
    fi
  fi

  # Remove server pid file that may be left by an unexpected shutdown
  rm -f tmp/pids/server.pid

  echo "Starting server..."
  # Prefix `bundle` with `exec` so unicorn shuts down gracefully on SIGTERM (i.e. `docker stop`)
  exec bundle exec rails s -p 3000 -b 0.0.0.0
}

trap "waitBash" $SIGWAITBASH
sleep 2

startServer
