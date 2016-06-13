#!/usr/bin/env bash

# SIGWAITBASH=31
SIGSKIPBASH=30
FOLDER_TEMP=tmp/docker

# trap "waitBash" $SIGWAITBASH
trap "startServer" $SIGSKIPBASH
trap "exitScript" SIGTERM

exitScript() { exit 0 ; }

printPrompt() {
  echo "Run \"kill -$SIGSKIPBASH 1\" in bash to start the server"
  echo "Run \"kill 1\" in bash to stop the container"
}

waitBash() {
  # trap "printPrompt" $SIGWAITBASH

  echo "Waiting for bash..."
  printPrompt

  while true ; do sleep 1 ; done
}

startServer() {
  # trap - $SIGWAITBASH $SIGSKIPBASH

  # Initialize the database
  FILE_INIT=$FOLDER_TEMP/init
  if [ ! -f $FILE_INIT ]; then
    .docker/scripts/wait-for-it.sh -h $INFO_DATABASE_HOST -p $INFO_DATABASE_PORT -t 30
    if [ $? == "0" ]; then
      echo "Initializing Database..."

      bundle exec rake db:create
      bundle exec rake db:schema:load

      touch $FILE_INIT
    fi
  fi

  # Remove server pid file that may be left by an unexpected shutdown
  rm -f tmp/pids/server.pid

  echo "Starting server..."
  # Prefix `bundle` with `exec` so unicorn shuts down gracefully on SIGTERM (i.e. `docker stop`)
  exec bundle exec rails s -p 3000 -b 0.0.0.0
}

waitSignal() {
  sleep 2 &
  wait $!

  startServer
}

if [[ $# == 0 ]]; then
  FILE_ARGUMENT=$FOLDER_TEMP/args
  if [ -f "$FILE_ARGUMENT" ]; then
    ARGS=$(<"$FILE_ARGUMENT")

    exec $0 -a $ARGS
  else
    waitSignal
  fi
fi

ARG_ACTION="waitSignal"
while [[ $# > 0 ]]
do
  key="$1"
  case $key in
    -a|--arguments)
    ;;
    -b|--bash)
      ARG_ACTION="waitBash"
    ;;
    -s|--server)
      ARG_ACTION="startServer"
    ;;
    -t|--timezone)
      .docker/scripts/timezone.sh $2
      shift
    ;;
  esac
  shift
done

$ARG_ACTION
