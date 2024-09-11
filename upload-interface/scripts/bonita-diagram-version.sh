#!/usr/bin/env bash

# Set the diagram versions to the specified version

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(realpath "$SCRIPT_DIR/..")

"$SCRIPT_DIR/require.sh" xmlstarlet || exit 1

if ! [ "$1" ]; then
    echo "Missing version argument"
    exit 1
fi

VERSION="$1"

for DIAGRAM_FILE in "${ROOT_DIR}/diagrams/"*.proc; do
    echo "Setting diagram version to ${VERSION} in ${DIAGRAM_FILE}..."

    xmlstarlet edit --inplace \
        -N process="http://www.bonitasoft.org/ns/studio/process" \
        -N xmi="http://www.omg.org/XMI" \
        --insert "//process:MainProcess[not(@version)]" --type attr -n "version" --value "${VERSION}" \
        --update "//process:MainProcess/@version" --value "${VERSION}" \
        "${DIAGRAM_FILE}"

    NEW_DIAGRAM_FILE="$(xmlstarlet select \
        -N process="http://www.bonitasoft.org/ns/studio/process" \
        -N xmi="http://www.omg.org/XMI" \
        -t -v "//process:MainProcess/@name" \
        "${DIAGRAM_FILE}")-${VERSION}.proc"

    echo "Renaming diagram file ${DIAGRAM_FILE} to ${NEW_DIAGRAM_FILE}..."
    git -C "$ROOT_DIR" mv "${DIAGRAM_FILE}" "${ROOT_DIR}/diagrams/${NEW_DIAGRAM_FILE}"

done

