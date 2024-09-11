#!/usr/bin/env bash

# Bumps the version number by incrementing the minor version

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

"$SCRIPT_DIR/require.sh" npm || exit 1

npm --prefix "$ROOT_DIR" version --git-tag-version=false minor
