#!/usr/bin/env bash

# Empty the list of users and corresponding memberships in the organisation files

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

"$SCRIPT_DIR/require.sh" xmlstarlet || exit 1

for ORGANIZATION_FILE in "${ROOT_DIR}/organizations/"*.organization; do
    echo "Emptying organization ${ORGANIZATION_FILE}..."

    xmlstarlet edit --inplace \
        -N organization="http://documentation.bonitasoft.com/organization-xml-schema/1.1" \
        --delete "//user" \
        --delete "//membership" \
        "${ORGANIZATION_FILE}"
done
