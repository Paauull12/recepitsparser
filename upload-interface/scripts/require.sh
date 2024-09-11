#!/usr/bin/env bash

# Tests if a command is available

if ! [ "$1" ]; then
    echo "Missing command argument"
    exit 1
fi

command -v "$1" >/dev/null 2>&1 || { echo >&2 "$1 is required. Aborting."; exit 1; }
