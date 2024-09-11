#!/usr/bin/env bash

# Set the process versions to the specified version

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

"$SCRIPT_DIR/require.sh" xmlstarlet || exit 1

if ! [ "$1" ]; then
    echo "Missing version argument"
    exit 1
fi

VERSION="$1"

for DIAGRAM_FILE in "${ROOT_DIR}/diagrams/"*.proc; do
    echo "Setting process versions to ${VERSION} in ${DIAGRAM_FILE}..."

    xmlstarlet edit --inplace \
        -N process="http://www.bonitasoft.org/ns/studio/process" \
        -N xmi="http://www.omg.org/XMI" \
        --insert "//elements[@xmi:type='process:Pool'][not(@version)]" --type attr -n "version" --value "${VERSION}" \
        --update "//elements[@xmi:type='process:Pool']/@version" --value "${VERSION}" \
        "${DIAGRAM_FILE}"
done

