#!/usr/bin/env bash

# Outputs the `project.artifactId` property for the optional module path ($1), or the root project if not specified
# $1: Optional module path. If not set, the `project.artifactId` property is retrieved from the root project

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

"$SCRIPT_DIR/maven-property.sh" project.artifactId "$1"
