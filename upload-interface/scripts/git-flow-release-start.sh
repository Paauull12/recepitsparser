#!/usr/bin/env bash

# Perform a release start of the project based on Git flow
# $1: Optional version number. If not set, the latest Git tag version is used and patch number is incremented

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

"$SCRIPT_DIR/require.sh" git || exit 1

echo "Checking develop branch state in $ROOT_DIR"
"$SCRIPT_DIR/git-fetch-branch-fast-forward.sh" develop || exit 1
if ! "$SCRIPT_DIR/git-check-branch-clean.sh" develop; then
    exit 1
fi
git -C "$ROOT_DIR" checkout develop || exit 1

if [[ "$1" ]]; then
    VERSION=$1
else
    VERSION=$("$SCRIPT_DIR/git-next-version.sh")
fi
echo "Release version is ${VERSION}"

echo "Ensuring git flow is initialized in $ROOT_DIR"
"$SCRIPT_DIR/git-flow-init.sh" || exit 1

echo "Starting release $VERSION in $ROOT_DIR"
git -C "$ROOT_DIR" flow release start "$VERSION" || exit 1

echo "Publishing release branch"
git -C "$ROOT_DIR" flow publish || exit 1
