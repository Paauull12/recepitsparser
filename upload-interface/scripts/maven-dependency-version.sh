#!/usr/bin/env bash

# Outputs the version of the specified dependency [groupId:]artifactId[:packaging] 
# or sets the specified version of the specified dependency groupId:artifactId

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

"$SCRIPT_DIR/require.sh" mvn || exit 1

if ! [ "$1" ]; then
    echo "Missing [groupId:]artifactId[:packaging] argument"
    exit 1
elif ! [ "$2" ]; then
    SEPARATOR_COUNT="${1//[^\\:]}"
    SEPARATOR_COUNT="${#SEPARATOR_COUNT}"

    if [ "$SEPARATOR_COUNT" -eq 0 ]; then
        DEPENDENCY=".*:$1:.*"
    elif [ "$SEPARATOR_COUNT" -eq 1 ]; then
        DEPENDENCY="$1:.*"
    else
        DEPENDENCY="$1"
    fi

    mvn -U -P jvnexusrepo dependency:list -f "$ROOT_DIR/pom.xml" | grep "$DEPENDENCY" | sed "s/.*$DEPENDENCY:\\([^:]\\+\\):.*/\\1/"
else
    echo "Upgrading $1 dependency to version $2 in $ROOT_DIR/pom.xml"
    mvn -q versions:use-dep-version -f "$ROOT_DIR/pom.xml" -Dincludes="$1" -DdepVersion="$2" -DforceVersion=true -DgenerateBackupPoms=false
fi
