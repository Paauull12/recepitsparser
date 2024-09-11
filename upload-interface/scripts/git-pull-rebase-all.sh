#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

echo "Searching for Git projects in $ROOT_DIR..."

PROJECTS=$(find "$ROOT_DIR" -mindepth 1 -maxdepth 1 -type d -regex "[^.]*" -printf "%f ")

for PROJECT in $PROJECTS; do
    if ! [[ -e "$ROOT_DIR/$PROJECT/.git" ]]; then
        echo "$PROJECT is not a Git workspace"
        continue
    fi
    echo "Pulling $PROJECT"
    git -C "$ROOT_DIR/$PROJECT" pull --rebase
done
