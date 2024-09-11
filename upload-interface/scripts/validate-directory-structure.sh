#!/usr/bin/env bash

# Validates the directory structure and ensure each supported checked-out branch starts with the given prefix ($1)

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

echo "Searching for Git workspaces in $ROOT_DIR..."

if ! [[ "$1" ]]; then
    echo "Missing branch prefix argument"
    exit 1
fi
EXPECTED_BRANCH_PREFIX=$1

PROJECTS=$(find "$ROOT_DIR" -mindepth 1 -maxdepth 1 -type d -regex "[^.]*" -printf "%f ")

for PROJECT in $PROJECTS; do
    if ! [[ -e "$ROOT_DIR/$PROJECT/.git" ]]; then
        echo "Skipping $PROJECT: not a Git workspace"
        continue
    fi
    if ! [[ -f "$ROOT_DIR/$PROJECT/scripts/git-flow-release.sh" ]]; then
        echo "Skipping $PROJECT: no 'scripts/git-flow-release.sh' found"
        continue
    fi
    ACTUAL_BRANCH=$("$ROOT_DIR/$PROJECT/scripts/git-branch-name.sh")
    if ! [[ "${ACTUAL_BRANCH%%/*}" == ${EXPECTED_BRANCH_PREFIX} ]]; then
        echo "Actual branch '${ACTUAL_BRANCH}' does not match expected branch prefix '${EXPECTED_BRANCH_PREFIX}' in $PROJECT"
        exit 1
    fi
    if ! "$ROOT_DIR/$PROJECT/scripts/git-check-branch-clean.sh" "${ACTUAL_BRANCH}"; then
        echo "'${ACTUAL_BRANCH}' branch is not clean in $PROJECT"
        exit 1
    fi
done
