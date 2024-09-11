#!/usr/bin/env bash

# Outputs the latest version tag

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

"$SCRIPT_DIR/require.sh" git || exit 1

git -C "$ROOT_DIR" tag | grep -E '^[0-9].*' | sort -V | tail -1
