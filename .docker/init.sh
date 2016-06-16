#!/usr/bin/env bash

.docker/scripts/wait-for-it.sh -h $INFO_DATABASE_HOST -p $INFO_DATABASE_PORT -t 30 || exit

echo "Initializing Database..."
bundle exec rake db:create
bundle exec rake db:schema:load
