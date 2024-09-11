#!/usr/bin/env bash

# Performs the release finish of all sub-projects

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

"$SCRIPT_DIR/validate-directory-structure.sh" release || exit 1

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
done

echo
echo "Finish release of following projects:"
for SUPPORTED_PROJECT in ${SUPPORTED_PROJECTS[@]}; do
    echo "- $SUPPORTED_PROJECT"
done

for SUPPORTED_PROJECT in ${SUPPORTED_PROJECTS[@]}; do
    echo "Starting release finish of project ${SUPPORTED_PROJECT}"
    "$ROOT_DIR/$SUPPORTED_PROJECT/scripts/git-flow-release-finish.sh" || exit 1
done

echo "Release finish done for all projects"
