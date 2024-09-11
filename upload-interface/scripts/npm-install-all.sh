#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/../..")

PROJECTS=$(find $ROOT_DIR -mindepth 1 -maxdepth 1 -type d -regex "[^.]*" -printf "%f ")

for PROJECT in $PROJECTS; do
    if ! [[ -f "$ROOT_DIR/$PROJECT/package.json" ]]; then
        echo "$PROJECT is not a Node project"
        continue
    fi
    echo "Installing $PROJECT"
    # FIXME this command does not work: npm --prefix "$ROOT_DIR/$PROJECT" install
    cd $ROOT_DIR/$PROJECT
    npm install
done

cd $ROOT_DIR
