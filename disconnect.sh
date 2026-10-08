#!/usr/bin/env bash
set -u

PIDFILE="/run/openvpn-bs.pid"

if [[ -s "$PIDFILE" ]]; then
  pid=$(<"$PIDFILE")
  if [[ "$pid" =~ ^[0-9]+$ ]] && sudo kill -0 "$pid" 2>/dev/null; then
    sudo kill -TERM "$pid"
  fi
fi

