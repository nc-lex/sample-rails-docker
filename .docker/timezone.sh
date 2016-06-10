#!/usr/bin/env bash

ARG_HELP=
ARG_TIMEZONE=

while [[ $# > 0 ]]
do
  key="$1"
  case $key in
    -h|--help)
      ARG_HELP=YES
    ;;
    *)
      ARG_TIMEZONE=$key
    ;;
  esac
  shift
done

if [[ -n "$ARG_HELP" ]]; then
  echo "Get or set timezone (sudo required)"
  echo "Usage:  $0 [TIMEZONE]"
  exit 0
fi

SUDO="$(which sudo)"

getTimeZone() {
  case "$OSTYPE" in
    darwin*)  $SUDO systemsetup -gettimezone | awk 'BEGIN {FS=": "} { print $2 }' ;; 
    linux*)   $SUDO echo "$(</etc/timezone)" ;;
    *)        echo "UTC" ;;
  esac
}

setTimeZone() {
  case "$OSTYPE" in
    darwin*)  $SUDO systemsetup -settimezone $1 ;; 
    linux*)   $SUDO echo "$1" > /etc/timezone && $SUDO dpkg-reconfigure -f noninteractive tzdata ;;
    *)        echo "$OSTYPE is not supported" ;;
  esac
}

if [[ -n "$ARG_TIMEZONE" ]]; then
  setTimeZone $ARG_TIMEZONE
else
  getTimeZone
fi
