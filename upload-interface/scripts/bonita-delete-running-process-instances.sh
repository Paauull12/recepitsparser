#!/usr/bin/env bash

# Delete either all running process instances or the ones with the optional version ($1)
#
# Environment variables / options:
# - BONITA_SIDECAR_URI / --bonita-sidecar-uri (required): The Bonita Sidecar URI
# - TOKEN_URI / --token-uri (optional): The token URI. Default: https://login.lsnc1.luminess.eu/auth/realms/public/protocol/openid-connect/token
# - CLIENT_ID / --client-id (required): a client ID authorized to access the Bonita Sidecar API
# - CLIENT_SECRET / --client-secret (required): the client secret

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Read arguments
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --bonita-sidecar-uri)
            shift
            BONITA_SIDECAR_URI=$1
            shift
            ;;
        --token-uri)
            shift
            TOKEN_URI=$1
            shift
            ;;
        --client-id)
            shift
            CLIENT_ID=$1
            shift
            ;;
        --client-secret)
            shift
            CLIENT_SECRET=$1
            shift
            ;;
        -*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done
set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

QUERY_STRING=""

if [[ "$1" ]]; then
    VERSION="$1"
    QUERY_STRING+="version=${VERSION}"
fi

if ! [[ "${BONITA_SIDECAR_URI}" ]]; then
    echo "Missing Bonita Sidecar URI"
    exit 1
fi

if ! [[ "${TOKEN_URI}" ]]; then
    echo "Missing token URI"
    exit 1
fi

if ! [[ "${CLIENT_ID}" ]]; then
    echo "Missing client ID"
    exit 1
fi

if ! [[ "${CLIENT_SECRET}" ]]; then
    echo "Missing client secret"
    exit 1
fi

"${SCRIPT_DIR}/authenticate.sh" --token-uri "${TOKEN_URI}" --client-id "${CLIENT_ID}" --client-secret "${CLIENT_SECRET}" || exit 1

ACCESS_TOKEN=$(cat "/tmp/${CLIENT_ID}.access-token")
echo "Deleting running process instances with version ${VERSION:-unspecified}"
echo "${BONITA_SIDECAR_URI}"

RESPONSE=$(curl --fail-with-body -X DELETE \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    "${BONITA_SIDECAR_URI}/api/bpm/process-definitions/running-instances?${QUERY_STRING}")
# shellcheck disable=SC2181
if ! [[ $? == 0 ]]; then
    echo "Deletion failure: ${RESPONSE}"
    exit 1
fi

echo "${RESPONSE}"
