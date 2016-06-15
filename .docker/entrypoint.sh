#!/usr/bin/env bash
# A Docker entrypoint for a development-friendly container

SIGSKIPBASH=30
FOLDER_TEMP=tmp/docker
FILE_ARGUMENT=$FOLDER_TEMP/args

trap "startServer" $SIGSKIPBASH
trap "exitScript" SIGTERM

exitScript() { exit 0 ; }

printPrompt() {
  echo "Run \"kill -$SIGSKIPBASH 1\" in bash to start the server"
  echo "Run \"kill 1\" in bash to stop the container"
}

waitBash() {
  echo "Waiting for bash..."
  printPrompt

  while true ; do sleep 1 ; done
}

startServer() {
  trap - $SIGSKIPBASH

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

interactiveBash() {
  exec /usr/bin/env bash
}

ARG_ACTION="startServer"
while [[ $# > 0 ]]
do
  key="$1"
  case $key in
    -a|--arguments)
      if [ -f "$FILE_ARGUMENT" ]; then
        exec $0 $(<"$FILE_ARGUMENT")
      fi
    ;;
    -b|--bash)
      ARG_ACTION="waitBash"
    ;;
    -h|--help)
      ARG_HELP=YES
    ;;
    -i|--interactive)
      ARG_ACTION="interactiveBash"
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

if [[ -n "$ARG_HELP" ]]; then
  echo "Entrypoint for a Docker container"
  echo "Usage:  $0 [OPTIONS]"
  echo "  -a, --arguments            Read arguments from $FILE_ARGUMENT"
  echo "  -b, --bash                 Wait for bash to connect"
  echo "  -i, --interactive          Start a bash console"
  echo "  -s, --server               Start app server"
  echo "  -t, --timezone [TIMEZONE]  Set timezone"
  exit 0
fi

$ARG_ACTION
