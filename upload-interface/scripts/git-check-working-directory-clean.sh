#!/usr/bin/env bash

# Tests if the working directory is clean

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

"$SCRIPT_DIR/require.sh" git || exit 1

STATUS=$(git -C "$ROOT_DIR" status --porcelain)
if [ -n "$STATUS" ]; then
    echo "Git working directory is not clean in $ROOT_DIR"
    echo "$STATUS"
    exit 1
else
    echo "Git working directory is clean in $ROOT_DIR"
fi
