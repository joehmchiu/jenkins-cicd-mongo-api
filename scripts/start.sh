#!/bin/bash

TOKEN_FILE=/etc/.token

if [ ! -s "$TOKEN_FILE" ]; then
  if [ -z "$USER" ]; then
    echo 1>&2 "error: missing USER environment variable"
    exit 1
  fi
  if [ -z "$TOKEN" ]; then
    echo 1>&2 "error: missing TOKEN environment variable"
    exit 1
  fi

  echo -n "{\"user\":\"$USER\",\"token\":\"$TOKEN\"}" > $TOKEN_FILE

  unset USER
  unset TOKEN
fi

python3 api.py > /tmp/api-dump-$(date +'%F').log 2>&1 


