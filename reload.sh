#!/bin/sh

set -e

rebuild

nsd-control reconfig

echo "nsd reloading..."
nsd-control reload
