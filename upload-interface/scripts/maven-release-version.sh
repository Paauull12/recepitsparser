#!/usr/bin/env bash

# Outputs the next release version (= current version without "-SNAPSHOT" suffix)

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

VERSION=$("$SCRIPT_DIR/maven-version.sh")
RELEASE_VERSION=${VERSION%"-SNAPSHOT"}

echo "$RELEASE_VERSION"
