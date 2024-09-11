#!/usr/bin/env bash

# Outputs the next version based on latest version tag

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

"$SCRIPT_DIR/require.sh" git || exit 1

LATEST_GIT_VERSION=$("$SCRIPT_DIR/git-latest-version.sh")
if ! [[ "$LATEST_GIT_VERSION" ]]; then
    RELEASE_VERSION="1.0.0"
else
    RELEASE_VERSION=$(echo "${LATEST_GIT_VERSION}" | awk -F. -v OFS=. '{$NF=$NF+1;print}')
fi

echo "${RELEASE_VERSION}"
