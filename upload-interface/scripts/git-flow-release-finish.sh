#!/usr/bin/env bash

# Perform a release finish of the project based on Git flow

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

"$SCRIPT_DIR/require.sh" git || exit 1

BRANCH_NAME=$("$SCRIPT_DIR/git-branch-name.sh")

if ! [[ $BRANCH_NAME == release* ]]; then
    echo "Not a release branch: ${BRANCH_NAME}"
    exit 1
fi

VERSION=${BRANCH_NAME#*/}

echo "Checking ${BRANCH_NAME} branch state in $ROOT_DIR"
"$SCRIPT_DIR/git-fetch-branch-fast-forward.sh" "${BRANCH_NAME}" || exit 1
if ! "$SCRIPT_DIR/git-check-branch-clean.sh" "${BRANCH_NAME}"; then
    exit 1
fi
"$SCRIPT_DIR/git-fetch-branch-fast-forward.sh" main || exit 1

echo "Updating changelog"
"$SCRIPT_DIR/update-changelog.sh" || exit 1

echo "Finishing release $VERSION in $ROOT_DIR"
export GIT_MERGE_AUTOEDIT=no
git -C "$ROOT_DIR" flow release finish "$VERSION" -m "Version $VERSION" -T "$VERSION" || exit 1
unset GIT_MERGE_AUTOEDIT

echo "Pushing main and develop branches with tags"
git -C "$ROOT_DIR" push --tags || exit 1
git -C "$ROOT_DIR" push origin main || exit 1
git -C "$ROOT_DIR" push origin develop || exit 1
