#!/usr/bin/env bash

# Tests if all commits have been pushed on the specified branch

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

"$SCRIPT_DIR/require.sh" git || exit 1

if ! [ "$1" ]; then
    echo "Missing branch argument"
    exit 1
fi

LOG=$(git -C "$ROOT_DIR" log "origin/$1..$1")
if [ -n "$LOG" ]; then
    echo "$1 branch is not up-to-date in $ROOT_DIR"
    echo "$LOG"
    exit 1
else
    echo "$1 branch is up-to-date in $ROOT_DIR"
fi
