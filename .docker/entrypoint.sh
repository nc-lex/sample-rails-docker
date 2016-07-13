#!/usr/bin/env bash
# A Docker entry point for a development-friendly container

SIGSKIPBASH=30
FOLDER_TEMP=tmp/docker
FILE_ARGUMENT=${FOLDER_TEMP}/args

mkdir -p ${FOLDER_TEMP}

trap "startServer" ${SIGSKIPBASH}
trap "exitScript" SIGTERM

exitScript() { exit 0 ; }

printPrompt() {
  echo "Run \"kill -${SIGSKIPBASH} 1\" in bash to start the server"
  echo "Run \"kill 1\" in bash to stop the container"
}

waitBash() {
  printPrompt

  while true ; do sleep 1 ; done
}

startServer() {
  trap - ${SIGSKIPBASH}

  # Initialize the app
  .docker/config/init.sh || exit

  # Prefix `bundle` with `exec` so the server shuts down gracefully on SIGTERM (i.e. `docker stop`)
  exec .docker/config/server.sh
}

interactiveBash() {
  exec /usr/bin/env bash
}

ARG_ACTION="waitBash"
while [[ $# > 0 ]] ; do
  case $1 in
    -a|--arguments)
      if [ -f "${FILE_ARGUMENT}" ]; then
        exec $0 $(<"${FILE_ARGUMENT}")
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

if [[ -n "${ARG_HELP}" ]]; then
  echo "Entry point for a Docker container"
  echo "Usage:  $0 [OPTIONS]"
  echo "  -a, --arguments            Read arguments from $FILE_ARGUMENT"
  echo "  -b, --bash                 Wait for bash to connect"
  echo "  -i, --interactive          Start a bash console"
  echo "  -s, --server               Start app server"
  echo "  -t, --timezone [TIMEZONE]  Set timezone"
  exit 0
fi

${ARG_ACTION}
