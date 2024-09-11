#!/usr/bin/env bash

# Fetches and fast-forwards the specified branch

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

"$SCRIPT_DIR/require.sh" git || exit 1

if ! [ "$1" ]; then
    echo "Missing branch argument"
    exit 1
fi

echo "Fetching and fast-forwarding $1 branch in $ROOT_DIR"
git -C "$ROOT_DIR" fetch --update-head-ok origin "$1:$1"
