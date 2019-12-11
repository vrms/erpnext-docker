#!/usr/bin/env bash

if ! [ "$1" = 'bash' ]; then
  for file in /entrypoints/*
  do
    bash "$file"
  done
fi

exec "$@"
