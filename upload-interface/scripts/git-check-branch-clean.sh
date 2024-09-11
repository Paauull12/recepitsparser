#!/usr/bin/env bash

# Tests if all commits have been pushed on the specified branch

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

if ! [ "$1" ]; then
    echo "Missing branch argument"
    exit 1
fi

if ! "$SCRIPT_DIR/git-check-working-directory-clean.sh"; then
    exit 1
fi

if ! "$SCRIPT_DIR/git-check-branch-up-to-date.sh" "$1"; then
    exit 1
fi
