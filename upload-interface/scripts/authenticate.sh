#!/usr/bin/env bash

# Authenticate and store the token and access token respectively in /tmp/${CLIENT_ID}.token and /tmp/${CLIENT_ID}.access-token
# Environment variables / options:
# - TOKEN_URI / --token-uri (optional): The token URI. Default: https://login.lsnc1.luminess.eu/auth/realms/public/protocol/openid-connect/token
# - CLIENT_ID / --client-id (required): the client ID
# - CLIENT_SECRET / --client-secret (required): the client secret

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

"$SCRIPT_DIR/require.sh" jq || exit 1

DEFAULT_TOKEN_URI="https://login.lsnc1.luminess.eu/auth/realms/public/protocol/openid-connect/token"

# Read arguments
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
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

# Set the variable named $1 to $2 value if the variable is empty
function defaultIfEmpty() {
    if [[ -z "${!1}" ]]; then
        export "$1"="$3"
        echo "Missing $1 environment variable or $2 argument. Defaults to: ${!1}"
    fi
}

defaultIfEmpty "TOKEN_URI" "--token-uri" "${DEFAULT_TOKEN_URI}"

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

echo "Authenticating with '${CLIENT_ID}'"

TOKEN=$(curl --fail-with-body \
    --data client_id="${CLIENT_ID}" \
    --data client_secret="${CLIENT_SECRET}" \
    --data grant_type=client_credentials \
    "${TOKEN_URI}")
# shellcheck disable=SC2181
if ! [[ $? == 0 ]]; then
    echo "Authentication failure: ${TOKEN}"
    exit 1
fi

echo "${TOKEN}" > "/tmp/${CLIENT_ID}.token"

ACCESS_TOKEN=$(echo "${TOKEN}" | jq -r ".access_token")
# shellcheck disable=SC2181
if ! [[ $? == 0 ]]; then
    echo "Access token extraction failure"
    exit 1
fi

echo "${ACCESS_TOKEN}" > "/tmp/${CLIENT_ID}.access-token"
