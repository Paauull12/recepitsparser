#!/usr/bin/env bash

# Outputs the project property ($1) for the optional module path ($2), or the root project if not specified
# $1: the property name
# $2: Optional module path. If not set, the property is retrieved from the root project

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

if [[ "$2" ]]; then
    ROOT_DIR="$ROOT_DIR/$2"
fi

"$SCRIPT_DIR/require.sh" mvn || exit 1

# `build-helper:parse-version` adds useful version properties
mvn -U -P jvnexusrepo -q build-helper:parse-version help:evaluate -DforceStdout -Dexpression="$1" -f "$ROOT_DIR/pom.xml"
