#!/usr/bin/env bash

# Set the called process versions to the specified version

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

"$SCRIPT_DIR/require.sh" xmlstarlet || exit 1

if ! [ "$1" ]; then
    echo "Missing version argument"
    exit 1
fi

VERSION="$1"
CONFIGURATION_ERB_TEMPLATE="${ROOT_DIR}/bpm-configuration.yml.erb"

echo "Setting process versions to ${VERSION} in ${CONFIGURATION_ERB_TEMPLATE}..."

sed -i -e "s@\\s\\sversion:\\s\"[^\"]*\"@  version: \"${VERSION}\"@g" "${CONFIGURATION_ERB_TEMPLATE}"
