#!/usr/bin/env bash

# Remove server pid file that may be left by an unexpected shutdown
# rm tmp/pids/server.pid

# Prefix `bundle` with `exec` so unicorn shuts down gracefully on SIGTERM (i.e. `docker stop`)
exec bundle exec rails s -p 3000 -b 0.0.0.0
