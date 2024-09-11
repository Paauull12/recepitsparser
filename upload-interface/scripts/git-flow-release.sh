#!/usr/bin/env bash

# Perform a release of the project based on Git flow
# $1: Optional version number. If not set, the latest Git tag version is used and patch number is incremented

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

"$SCRIPT_DIR/git-flow-release-start.sh" "$1" || exit 1
"$SCRIPT_DIR/git-flow-release-finish.sh" || exit 1
