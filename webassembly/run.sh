#!/usr/bin/env bash

export DBUS_SESSION_BUS_ADDRESS=autolaunch:
export DISPLAY=:0

set -euo pipefail

echo "Running dbus..."
mkdir /run/dbus
dbus-daemon --system

echo "Running Xvfb..."
Xvfb $DISPLAY -screen 0 640x480x8 -nolisten tcp &

echo "Executing user command..."
sh -c "$*"
