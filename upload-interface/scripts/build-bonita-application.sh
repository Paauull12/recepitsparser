#!/usr/bin/env bash

# Build a Bonita project from a local Git repository
#
# Required environment variables or options:
# - BONITA_VERSION: Bonita version (e.g. 7.15.2)
# - BCD_VERSION: Bonita Continuous Delivery version (e.g. 3.6.1)
# - BONITA_ENVIRONMENT: Bonita environment (e.g. Production)
# - PROJECT_PATH: Bonita project path

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
TMPDIR="/tmp"

DEFAULT_BONITA_VERSION="7.15.2"
DEFAULT_BCD_VERSION="3.6.1"
DEFAULT_BONITA_ENVIRONMENT="Production"
DEFAULT_PROJECT_PATH=$(realpath ".")

# Read arguments

POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --bonita-version)
            shift
            BONITA_VERSION=$1
            shift
            ;;
        --bcd-version)
            shift
            BCD_VERSION=$1
            shift
            ;;
        --bonita-environment)
            shift
            BONITA_ENVIRONMENT=$1
            shift
            ;;
        --project-path)
            shift
            PROJECT_PATH=$1
            shift
            ;;
        --verbose)
            set -x
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

defaultIfEmpty "BONITA_VERSION" "--bonita-version" "${DEFAULT_BONITA_VERSION}"
defaultIfEmpty "BCD_VERSION" "--bcd-version" "${DEFAULT_BCD_VERSION}"
defaultIfEmpty "BONITA_ENVIRONMENT" "--bonita-environment" "${DEFAULT_BONITA_ENVIRONMENT}"
defaultIfEmpty "PROJECT_PATH" "--project-path" "${DEFAULT_PROJECT_PATH}"

# Validate arguments

if ! [ -f "${PROJECT_PATH}/pom.xml" ]; then
    echo "Unexpected project directory structure. Expecting ${PROJECT_PATH}/pom.xml file to exist" 1>&2
    exit 1
fi

# Extract properties from pom.xml

ARTIFACT_ID=$("${SCRIPT_DIR}/maven-property.sh" "project.artifactId" || exit 1)

# Install the BCD zip package

BCD_HOME="${TMPDIR}/bonita-continuous-delivery_${BCD_VERSION}_$(date +%s)"
echo "Installing BCD into $BCD_HOME"
curl "https://nexus-master-si.jouve.com/nexus/repository/thirdparty/com/bonita/bonita-continuous-delivery/${BCD_VERSION}/bonita-continuous-delivery-${BCD_VERSION}.zip" --output "${TMPDIR}/bonita-continuous-delivery-${BCD_VERSION}.zip" || exit $?
# ⚠ The zip archive contains a root directory named `bonita-continuous-delivery_${BCD_VERSION}` (with an underscore before the version number)
unzip -o "${TMPDIR}/bonita-continuous-delivery-${BCD_VERSION}.zip" -d "${TMPDIR}"
mv "${TMPDIR}/bonita-continuous-delivery_${BCD_VERSION}" "${BCD_HOME}"

### Configure the Bonita build

echo "Configuring the Bonita build"
cp "${BCD_HOME}/scenarios/build_and_deploy.yml.EXAMPLE" "${BCD_HOME}/scenarios/build_and_deploy.yml"
sed -i -e "s@bonita_version:.*\$@bonita_version: ${BONITA_VERSION}@g" "${BCD_HOME}/scenarios/build_and_deploy.yml"

# Initialize the BCD `docker-compose.yml` file

echo "Initializing the BCD \`docker-compose.yml\` file"
cp "${BCD_HOME}/docker-compose.yml.EXAMPLE" "${BCD_HOME}/docker-compose.yml"
sed -i -e "s@A.B.C@${BONITA_VERSION}@g" "${BCD_HOME}/docker-compose.yml"
sed -i -e "s@D.E.F@${BCD_VERSION}@g" "${BCD_HOME}/docker-compose.yml"
sed -i -e "s@quay.io@nexus-docker.jouve.com@g" "${BCD_HOME}/docker-compose.yml"

# Setup the project to build

echo "Setting up the project to build"
rsync --delete -az "${PROJECT_PATH}/" "${BCD_HOME}/project"

# Build the project

echo "Building the project"

function cleanUpOnExit {
    echo "Shutting docker container down"
    docker compose --file "${BCD_HOME}/docker-compose.yml" down --volumes

    echo "Cleaning up"
    rm -rf "${BCD_HOME}"
    rm "${TMPDIR}/bonita-continuous-delivery-${BCD_VERSION}.zip"
}
trap cleanUpOnExit EXIT

## Start docker container

## Change permissions on files created by host user (jenkins) so that container user can access them
chmod -R 777 "${BCD_HOME}"
docker compose --file "${BCD_HOME}/docker-compose.yml" down --volumes || exit $?
docker compose --file "${BCD_HOME}/docker-compose.yml" up bcd -d || exit $?

## Build the project with BCD

COMMAND="export MAVEN_OPTS=\"-Dhttp.proxyHost=10.11.2.16 -Dhttp.proxyPort=3128 -Dhttps.proxyHost=10.11.2.16 -Dhttps.proxyPort=3128\" && bcd --scenario scenarios/build_and_deploy.yml --yes livingapp build --path project --environment ${BONITA_ENVIRONMENT}"
docker compose --file "${BCD_HOME}/docker-compose.yml" exec --user bonita --workdir "/home/bonita/bonita-continuous-delivery" bcd "/bin/bash" -c "source ~/.bashrc && ${COMMAND}"
## Change permissions on files created by bonita user so that host can access them
COMMAND="chmod -R 777 ."
docker compose --file "${BCD_HOME}/docker-compose.yml" exec --user bonita --workdir "/home/bonita/bonita-continuous-delivery" bcd "/bin/bash" -c "source ~/.bashrc && ${COMMAND}"
docker compose --file "${BCD_HOME}/docker-compose.yml" down --volumes

# Move the created project package and default configuration archive into the original project location

echo "Moving the created project package and configuration into the original project location"
mkdir -p "${PROJECT_PATH}/target/project/processes"

PROJECT_ZIP=$(find "${BCD_HOME}/project/target/" -maxdepth 1 -name "project-${BONITA_ENVIRONMENT}-*.zip")
PROJECT_BCONF=$(find "${BCD_HOME}/project/target/" -maxdepth 1 -name "project-${BONITA_ENVIRONMENT}-*.bconf")
BDM_CLIENT=$(find "${BCD_HOME}/project/target/generated-jars/" -maxdepth 1 -name "bdm-client-*.jar")
BDM_DAO=$(find "${BCD_HOME}/project/target/generated-jars/" -maxdepth 1 -name "bdm-dao-*.jar")

cp "${PROJECT_ZIP}" "${PROJECT_PATH}/target/${ARTIFACT_ID}.zip"
if [[ "$PROJECT_BCONF" ]]; then
    cp "${PROJECT_BCONF}" "${PROJECT_PATH}/target/${ARTIFACT_ID}.bconf"
fi
if [[ "$BDM_CLIENT" ]]; then
    cp "${BDM_CLIENT}" "${PROJECT_PATH}/target/${ARTIFACT_ID}.bdm-client.jar"
fi
if [[ "$BDM_DAO" ]]; then
    cp "${BDM_DAO}" "${PROJECT_PATH}/target/${ARTIFACT_ID}.bdm-dao.jar"
fi

# Move individual `.bar` processes into the original project location

cp "${BCD_HOME}/project/target/project/processes/"* "${PROJECT_PATH}/target/project/processes"

echo "Build done"
