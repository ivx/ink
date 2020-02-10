#!/bin/sh

if [ "$1" = 'test' ]; then
  set -e
  mix format --check-formatted
  mix credo --strict
  mix test
else
  exec "$@"
fi
