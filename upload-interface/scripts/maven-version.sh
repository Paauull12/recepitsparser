#!/usr/bin/env bash

# Outputs or set the project version

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

"$SCRIPT_DIR/require.sh" mvn || exit 1

if [ "$1" ]; then
    # Versions prior to 2.9.0 returns exit code 1 instead of 0 in MinGW (see https://github.com/mojohaus/versions-maven-plugin/issues/483)
    echo "Setting version $1 in $ROOT_DIR/pom.xml"
    mvn -q org.codehaus.mojo:versions-maven-plugin:2.9.0:set -DgenerateBackupPoms=false -DprocessAllModules=true -DnewVersion="$1" -f "$ROOT_DIR/pom.xml"
else
    "$SCRIPT_DIR/maven-property.sh" project.version
fi
