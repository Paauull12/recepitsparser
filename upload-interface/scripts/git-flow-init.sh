#!/usr/bin/env bash

# Initialise the Git project using Git flow in non interactive mode

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

"$SCRIPT_DIR/require.sh" git || exit 1

# Ensure main and develop branches are present locally before executing `git flow init`
git -C "$ROOT_DIR" checkout main || exit 1
git -C "$ROOT_DIR" checkout develop || exit 1

git -C "$ROOT_DIR" flow init -d
