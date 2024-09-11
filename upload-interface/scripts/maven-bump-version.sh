#!/usr/bin/env bash

# Bumps the version number
# $1: [major|minor|patch], defaults to patch if not set

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

if [[ "$1" == "major" ]]; then
    MAJOR_VERSION=$("$SCRIPT_DIR/maven-property.sh" parsedVersion.nextMajorVersion)
    MINOR_VERSION=0
    PATCH_VERSION=0
elif [[ "$1" == "minor" ]]; then
    MAJOR_VERSION=$("$SCRIPT_DIR/maven-property.sh" parsedVersion.majorVersion)
    MINOR_VERSION=$("$SCRIPT_DIR/maven-property.sh" parsedVersion.nextMinorVersion)
    PATCH_VERSION=0
else
    # defaults to patch version
    MAJOR_VERSION=$("$SCRIPT_DIR/maven-property.sh" parsedVersion.majorVersion)
    MINOR_VERSION=$("$SCRIPT_DIR/maven-property.sh" parsedVersion.minorVersion)
    PATCH_VERSION=$("$SCRIPT_DIR/maven-property.sh" parsedVersion.nextIncrementalVersion)
fi

BUMPED_VERSION=$MAJOR_VERSION.$MINOR_VERSION.$PATCH_VERSION-SNAPSHOT

"$SCRIPT_DIR/maven-version.sh" "$BUMPED_VERSION"
