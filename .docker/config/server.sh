#!/usr/bin/env bash

echo "Starting server..."

# Remove server pid file that may be left by an unexpected shutdown
rm -f tmp/pids/server.pid

# Prefix `bundle` with `exec` so the server shuts down gracefully on SIGTERM (i.e. `docker stop`)
exec bundle exec rails s -p 3000 -b 0.0.0.0
