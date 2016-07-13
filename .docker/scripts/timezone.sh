#!/usr/bin/env bash

ARG_HELP=
ARG_TIMEZONE=

while [[ $# > 0 ]] ; do
  case $1 in
    -h|--help)
      ARG_HELP=YES
    ;;
    *)
      ARG_TIMEZONE=$1
    ;;
  esac
  shift
done

if [[ -n "${ARG_HELP}" ]]; then
  echo "Get or set timezone (sudo required)"
  echo "Usage:  $0 [TIMEZONE]"
  exit 0
fi

# Don't use sudo if not available
SUDO="$(which sudo)"

getTimeZone() {
  case "${OSTYPE}" in
    darwin*)  ls -lah /etc/localtime | awk 'BEGIN {FS="zoneinfo/"} { print $2 }' ;; 
    linux*)   echo "$(</etc/timezone)" ;;
    *)        echo "UTC" ;;
  esac
}

setTimeZone() {
  case "${OSTYPE}" in
    darwin*)  ${SUDO} systemsetup -settimezone $1 ;;
    linux*)   ${SUDO} echo "$1" > /etc/timezone && ${SUDO} dpkg-reconfigure -f noninteractive tzdata ;;
    *)        echo "${OSTYPE} is not supported" ;;
  esac
}

if [[ -n "${ARG_TIMEZONE}" ]]; then
  setTimeZone ${ARG_TIMEZONE}
else
  getTimeZone
fi
