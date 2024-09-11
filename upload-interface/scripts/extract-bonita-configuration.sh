#!/usr/bin/env bash

# Extract the YAML configuration file from a Bonita project configuration archive `.bconf` file into the specified target `.yml` file
# Usage:
#     extract-bonita-configuration.sh [Options] Project_Configuration_Archive_Path Project_Configuration_Target_Path
#
# Required environment variables or options:
# - BONITA_VERSION: Bonita version (e.g. 7.15.2)
# - BCD_VERSION: Bonita Continuous Delivery version (e.g. 3.6.1)

TMPDIR="/tmp"

DEFAULT_BONITA_VERSION="7.15.2"
DEFAULT_BCD_VERSION="3.6.1"

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

PROJECT_CONFIGURATION_TEMPLATE_PATH=$1
PROJECT_CONFIGURATION_TARGET_PATH=$2

# Set the variable named $1 to $2 value if the variable is empty
function defaultIfEmpty() {
    if [[ -z "${!1}" ]]; then
        export "$1"="$3"
        echo "Missing $1 environment variable or $2 argument. Defaults to: ${!1}"
    fi
}

defaultIfEmpty "BONITA_VERSION" "--bonita-version" "${DEFAULT_BONITA_VERSION}"
defaultIfEmpty "BCD_VERSION" "--bcd-version" "${DEFAULT_BCD_VERSION}"

# Validate arguments

if ! [[ "${PROJECT_CONFIGURATION_TEMPLATE_PATH}" ]]; then
    echo "Missing project configuration template (.bconf) path argument." 1>&2
    exit 1
fi

if ! [[ "${PROJECT_CONFIGURATION_TARGET_PATH}" ]]; then
    echo "Missing project configuration target (.yml) path argument." 1>&2
    exit 1
fi

# Install the BCD zip package

BCD_HOME="${TMPDIR}/bonita-continuous-delivery_${BCD_VERSION}_$(date +%s)"
echo "Installing BCD into $BCD_HOME"
curl "https://nexus-master-si.jouve.com/nexus/repository/thirdparty/com/bonita/bonita-continuous-delivery/${BCD_VERSION}/bonita-continuous-delivery-${BCD_VERSION}.zip" --output "${TMPDIR}/bonita-continuous-delivery-${BCD_VERSION}.zip" || exit $?
# ⚠ The zip archive contains a root directory named `bonita-continuous-delivery_${BCD_VERSION}` (with an underscore before the version number)
unzip -o "${TMPDIR}/bonita-continuous-delivery-${BCD_VERSION}.zip" -d "${TMPDIR}"
mv "${TMPDIR}/bonita-continuous-delivery_${BCD_VERSION}" "${BCD_HOME}"

### Configure the Bonita deployment

echo "Configuring the Bonita deployment"
cp "${BCD_HOME}/scenarios/build_and_deploy.yml.EXAMPLE" "${BCD_HOME}/scenarios/build_and_deploy.yml"
sed -i -e "s@bonita_version:.*\$@bonita_version: ${BONITA_VERSION}@g" "${BCD_HOME}/scenarios/build_and_deploy.yml"
sed -i -e "s@bonita_url:.*\$@bonita_url: ${BONITA_URL}@g" "${BCD_HOME}/scenarios/build_and_deploy.yml"
sed -i -e "s@bonita_technical_username:.*\$@bonita_technical_username: ${BONITA_TECHNICAL_USERNAME}@g" "${BCD_HOME}/scenarios/build_and_deploy.yml"
sed -i -e "s@bonita_technical_password:.*\$@bonita_technical_password: ${BONITA_TECHNICAL_PASSWORD}@g" "${BCD_HOME}/scenarios/build_and_deploy.yml"

# Initialize the BCD `docker-compose.yml` file

echo "Initializing the BCD \`docker-compose.yml\` file"
cp "${BCD_HOME}/docker-compose.yml.EXAMPLE" "${BCD_HOME}/docker-compose.yml"
sed -i -e "s@A.B.C@${BONITA_VERSION}@g" "${BCD_HOME}/docker-compose.yml"
sed -i -e "s@D.E.F@${BCD_VERSION}@g" "${BCD_HOME}/docker-compose.yml"
sed -i -e "s@quay.io@nexus-docker.jouve.com@g" "${BCD_HOME}/docker-compose.yml"

# Setup the project configuration to extract

echo "Setting up the project configuration to extract"
cp "$PROJECT_CONFIGURATION_TEMPLATE_PATH" "${BCD_HOME}/project.template.bconf"

# Extracting the project configuration

echo "Extracting the project configuration"

## Start docker container

## Change permissions on files created by host user (rundeck) so that container user can access them
chmod -R 777 "${BCD_HOME}"
docker compose --file "${BCD_HOME}/docker-compose.yml" down --volumes || exit $?
docker compose --file "${BCD_HOME}/docker-compose.yml" up bcd -d || exit $?

## Extract the template configuration

COMMAND="bcd --scenario scenarios/build_and_deploy.yml --yes livingapp extract-conf --path project.template.bconf --output project.template.yml"
docker compose --file "${BCD_HOME}/docker-compose.yml" exec --user bonita --workdir "/home/bonita/bonita-continuous-delivery" bcd "/bin/bash" -c "source ~/.bashrc && ${COMMAND}"

## Change permissions on files created by bonita user so that host can access them

COMMAND="chmod -R 777 ."
docker compose --file "${BCD_HOME}/docker-compose.yml" exec --user bonita --workdir "/home/bonita/bonita-continuous-delivery" bcd "/bin/bash" -c "source ~/.bashrc && ${COMMAND}"
docker compose --file "${BCD_HOME}/docker-compose.yml" down --volumes

## Move the template configuration to the target

mv -f "${BCD_HOME}/project.template.yml" "${PROJECT_CONFIGURATION_TARGET_PATH}"

# Clean up

echo "Cleaning up"
rm -rf "${BCD_HOME}"
rm "${TMPDIR}/bonita-continuous-delivery-${BCD_VERSION}.zip"
