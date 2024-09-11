#!/usr/bin/env bash

# Perform a release of all sub-projects based on Git flow
# $1: Optional version number. If not set, the latest Git tag version is used and patch number is incremented in each sub-project

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

"$SCRIPT_DIR/git-flow-release-start-all.sh" "$1" || exit 1
"$SCRIPT_DIR/git-flow-release-finish-all.sh" || exit 1

echo "Release done for all projects"
