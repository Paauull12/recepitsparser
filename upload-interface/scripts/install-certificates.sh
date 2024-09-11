#!/usr/bin/env bash

# Retrieve and install the certificate corresponding to the provided FQDN in the Java cacerts store
# Usage:
#     install-certificates.sh my_fqdn

TMPDIR="/tmp"

if ! [[ "$1" ]]; then
    echo "Missing FQDN argument"
    exit 1
fi

FQDN=$1
TMP_CERTIFICATE="$TMPDIR/$FQDN.crt"

JDK_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")

openssl s_client -connect "$FQDN":443 2>/dev/null </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "$TMP_CERTIFICATE" || exit 1
cat "$TMP_CERTIFICATE"
"$JDK_HOME/bin/keytool" -delete -noprompt -alias "$FQDN" -keystore "$JDK_HOME/lib/security/cacerts" -storepass changeit
"$JDK_HOME/bin/keytool" -import -trustcacerts -keystore "$JDK_HOME/lib/security/cacerts" -storepass changeit -noprompt -alias "$FQDN" -file "$TMP_CERTIFICATE" || exit 1

rm "$TMP_CERTIFICATE"
