#!/usr/bin/env bash

echo "Starting server..."

# Prefix `bundle` with `exec` so the server shuts down gracefully on SIGTERM (i.e. `docker stop`)
exec bundle exec rails s -p 3000 -b 0.0.0.0
