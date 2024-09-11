#!/usr/bin/env bash

# Outputs the Bonita process list

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

for FILE in "${ROOT_DIR}/target/project/processes"/*; do
    FILENAME=$(basename "$FILE")
    if [[ "$FILENAME" =~ ^(.*)--(.*).bar$ ]]; then 
        PROCESS_NAME=${BASH_REMATCH[1]}
        PROCESS_VERSION=${BASH_REMATCH[2]}
        echo "$PROCESS_NAME;$PROCESS_VERSION;$FILENAME;$FILE"
    fi
done
