#!/usr/bin/env bash

echo "Initializing Database..."

bundle exec rake db:create
bundle exec rake db:schema:load
