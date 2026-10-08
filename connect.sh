#!/usr/bin/env bash
set -u

CONFIG="$PWD/client.ovpn"
AUTH="$PWD/auth"
PIDFILE="/run/openvpn-bs.pid"

if [[ ! -f $CONFIG ]]; then
  echo "client.ovpn is missing"
  exit 1
fi

if [[ ! -f "$AUTH" ]] || [[ $(wc -l < "$AUTH") -ne 2 ]]; then
  echo "Auth file ($AUTH) must contain your name on the first line and a random string on the second" >&2
  exit 1
fi

if [[ -s "$PIDFILE" ]]; then
  pid=$(<"$PIDFILE")
  if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null \
     && [[ -r "/proc/$pid/comm" ]] \
     && [[ $(<"/proc/$pid/comm") == openvpn ]]; then
    echo "OpenVPN is already running (PID $pid)."
    exit 0
  fi
  rm -f "$PIDFILE"
fi

sudo openvpn \
  --config $CONFIG \
  --auth-user-pass $AUTH \
  --daemon \
  --log-append openvpn.log \
  --writepid $PIDFILE || exit 1

echo "Testing connection..."

sleep 2

if ping -c 1 -W 2 10.8.0.1 >/dev/null 2>&1; then
  echo "Connected"
else
  echo "Something went wrong" >&2
  exit 1
fi
