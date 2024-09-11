#!/usr/bin/env bash

# Return current checked out branch name

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

BRANCH_NAME=$(git -C "$ROOT_DIR" rev-parse --abbrev-ref HEAD)

echo "${BRANCH_NAME}"
