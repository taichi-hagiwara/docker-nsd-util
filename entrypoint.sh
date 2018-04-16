#!/bin/sh

set -e

start() {
  nsd-control-setup
  /usr/local/bin/rebuild
  nsd -d
}

case "$1" in
  "start")
    start
    ;;
  *)
    exec $*
    ;;
esac
