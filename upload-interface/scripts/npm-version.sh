#!/usr/bin/env bash

# Outputs the project version or set the project version if version ($1) is specified

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

if [ "$1" ]; then
    npm --prefix "$ROOT_DIR" version --allow-same-version --git-tag-version=false "$1"
else
    awk -F\" '/"version":/ {print $4}' "$ROOT_DIR/package.json"
fi
