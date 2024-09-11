#!/usr/bin/env bash

# Performs the release start of all sub-projects based on Git flow
# $1: Optional version number. If not set, the latest Git tag version is used and patch number is incremented in each sub-project

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

RELEASE_VERSION="$1"

echo "Searching for supported projects in $ROOT_DIR..."

PROJECTS=$(find "$ROOT_DIR" -mindepth 1 -maxdepth 1 -type d -regex "[^.]*" -printf "%f ")

SUPPORTED_PROJECTS=()

for PROJECT in $PROJECTS; do
    if ! [[ -e "$ROOT_DIR/$PROJECT/.git" ]]; then
        echo "Skipping project '$PROJECT': not a Git workspace"
        continue
    fi
    if ! [[ -f "$ROOT_DIR/$PROJECT/scripts/git-flow-release.sh" ]]; then
        echo "Skipping project '$PROJECT': no 'scripts/git-flow-release.sh' found"
        continue
    fi
    echo "Supported project '${PROJECT}' found"
    SUPPORTED_PROJECTS+=(${PROJECT})
    echo "Checking develop branch out of '${PROJECT}'"
    git -C "$ROOT_DIR/$PROJECT" checkout develop
done

"$SCRIPT_DIR/validate-directory-structure.sh" develop || exit 1

echo
echo "Start release of following projects with version ${RELEASE_VERSION:-unspecified}:"
for SUPPORTED_PROJECT in ${SUPPORTED_PROJECTS[@]}; do
    echo "- $SUPPORTED_PROJECT"
done

for SUPPORTED_PROJECT in ${SUPPORTED_PROJECTS[@]}; do
    echo "Starting release start of project ${SUPPORTED_PROJECT} with version ${RELEASE_VERSION:-unspecified}"
    "$ROOT_DIR/$SUPPORTED_PROJECT/scripts/git-flow-release-start.sh" "${RELEASE_VERSION}" || exit 1
done

echo "Release start done for all projects"
