#!/usr/bin/env bash

# Update the `src/assets/app-info.json` file with the specified version ($1) or the one from `package.json` if not specified

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

if [[ "${1}" ]]; then
    VERSION=$1
else
    VERSION=$("$SCRIPT_DIR/npm-version.sh")
fi

INFO_PATH="$ROOT_DIR/src/assets/app-info.json"

echo "{\"version\":\"$VERSION\"}" > "$INFO_PATH"
