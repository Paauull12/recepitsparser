#!/usr/bin/env bash

# Deploy a Bonita project from a local Git repository
# Usage:
#     deploy-bonita-application.sh [Options] Project_Package_Path Project_Default_Configuration_Archive_Path Target_Environment_Configuration_Path
#
# Required options or environment variables:
# --bcd-version or BCD_VERSION : Bonita Continuous Delivery version (e.g. 3.6.1)
# --bcd-development-mode : Enable the development mode policies during the deployment (disabled by default)
# --bcd-disable-certificate-check : Disable all certificate validation when connecting to a Bonita stack over HTTPS. This option may be used when a self-signed certificate is installed on the target Bonita stack
# --bcd-verbose : Enable Ansible verbose mode for BCD
# --bcd-debug : Enable debug mode
# --bonita-version or BONITA_VERSION : Bonita version (e.g. 7.15.2)
# --bonita-technical-username or BONITA_TECHNICAL_USERNAME : Bonita technical user's username (e.g. install)
# --bonita-technical-password or BONITA_TECHNICAL_PASSWORD : Bonita technical user's password (e.g. install)
# --bonita-url or BONITA_URL : Bonita runtime target URL
# --docker-network-mode : Network driver (e.g. bridge, host)
# --docker-runuser : Use runuser with the specified user to execute docker commands
# --docker-sudo : Use sudo to execute docker commands
# --verbose : Enable Ansible verbose mode

TMPDIR="/tmp"

DEFAULT_BCD_VERSION="3.6.1"
DEFAULT_BONITA_VERSION="7.15.2"
DEFAULT_BONITA_TECHNICAL_USERNAME="install"
DEFAULT_BONITA_TECHNICAL_PASSWORD="install"
DEFAULT_BONITA_URL="http://localhost:8080/bonita"

BCD_DEVELOPMENT_MODE=""
BCD_DISABLE_CERTIFICATE_CHECK=""
BCD_VERBOSE=""
BCD_DEBUG=""
DOCKER_COMMAND_PREFIX=""
DOCKER_NETWORK_MODE=""

# Read arguments

POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --bcd-version)
            shift
            BCD_VERSION=$1
            shift
            ;;
        --bcd-development-mode)
            shift
            BCD_DEVELOPMENT_MODE="--development-mode"
            ;;
        --bcd-disable-certificate-check)
            shift
            BCD_DISABLE_CERTIFICATE_CHECK="--disable-certificate-check"
            ;;
        --bcd-verbose)
            shift
            BCD_VERBOSE="--verbose"
            ;;
        --bcd-debug)
            shift
            BCD_DEBUG="--debug"
            ;;
        --bonita-version)
            shift
            BONITA_VERSION=$1
            shift
            ;;
        --bonita-url)
            shift
            BONITA_URL=$1
            shift
            ;;
        --bonita-technical-username)
            shift
            BONITA_TECHNICAL_USERNAME=$1
            shift
            ;;
        --bonita-technical-password)
            shift
            BONITA_TECHNICAL_PASSWORD=$1
            shift
            ;;
        --docker-runuser)
            shift
            echo "docker will be run with user $1"
            DOCKER_COMMAND_PREFIX="runuser -u \"$1\" --"
            shift
            ;;
        --docker-sudo)
            shift
            echo "docker will be run as root"
            DOCKER_COMMAND_PREFIX="sudo"
            ;;
        --docker-network-mode)
            shift
            DOCKER_NETWORK_MODE=$1
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

PROJECT_PACKAGE_PATH=$1
PROJECT_CONFIGURATION_TEMPLATE_PATH=$2
PROJECT_CONFIGURATION_TARGET_PATH=$3

# Set the variable named $1 to $2 value if the variable is empty
function defaultIfEmpty() {
    if [[ -z "${!1}" ]]; then
        export "$1"="$3"
        echo "Missing $1 environment variable or $2 argument. Defaults to: ${!1}"
    fi
}

defaultIfEmpty "BCD_VERSION" "--bcd-version" "${DEFAULT_BCD_VERSION}"
defaultIfEmpty "BONITA_VERSION" "--bonita-version" "${DEFAULT_BONITA_VERSION}"
defaultIfEmpty "BONITA_TECHNICAL_USERNAME" "--bonita-technical-username" "${DEFAULT_BONITA_TECHNICAL_USERNAME}"
defaultIfEmpty "BONITA_TECHNICAL_PASSWORD" "--bonita-technical-password" "${DEFAULT_BONITA_TECHNICAL_PASSWORD}"
defaultIfEmpty "BONITA_URL" "--bonita-url" "${DEFAULT_BONITA_URL}"

# Validate arguments

if ! [[ "${PROJECT_PACKAGE_PATH}" ]]; then
    echo "Missing project package (.zip) path argument." 1>&2
    exit 1
fi

if ! [[ "${PROJECT_CONFIGURATION_TEMPLATE_PATH}" ]]; then
    echo "WARNING! Missing project configuration template (.bconf) path argument." 1>&2
fi

if ! [[ "${PROJECT_CONFIGURATION_TARGET_PATH}" ]]; then
    echo "WARNING! Missing project configuration target (.yml) path argument." 1>&2
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
if [[ "${DOCKER_NETWORK_MODE}" ]]; then
    sed -i -e "s@  bcd:@  bcd:\n    network_mode: ${DOCKER_NETWORK_MODE}@g" "${BCD_HOME}/docker-compose.yml"
fi

# Setup the project to deploy

echo "Setting up the project to deploy"
cp "$PROJECT_PACKAGE_PATH" "${BCD_HOME}/project.zip"
if [[ "$PROJECT_CONFIGURATION_TEMPLATE_PATH" ]]; then
    cp "$PROJECT_CONFIGURATION_TEMPLATE_PATH" "${BCD_HOME}/project.template.bconf"
fi
if [[ "$PROJECT_CONFIGURATION_TARGET_PATH" ]]; then
    cp "$PROJECT_CONFIGURATION_TARGET_PATH" "${BCD_HOME}/project.yml"
fi

# Deploy the project

echo "Deploying the project"

function cleanUpOnExit {
    echo "Shutting docker container down"
    DOCKER_COMMAND="docker compose --file \"${BCD_HOME}/docker-compose.yml\" down --volumes"
    eval "$DOCKER_COMMAND_PREFIX $DOCKER_COMMAND"

    echo "Cleaning up"
    rm -rf "${BCD_HOME}"
    rm "${TMPDIR}/bonita-continuous-delivery-${BCD_VERSION}.zip"
}
trap cleanUpOnExit EXIT

## Change permissions on files created by host user (rundeck) so that container user can access them
chmod -R 777 "${BCD_HOME}"
DOCKER_COMMAND="docker compose --file \"${BCD_HOME}/docker-compose.yml\" down --volumes"
eval "$DOCKER_COMMAND_PREFIX $DOCKER_COMMAND" || exit $?
DOCKER_COMMAND="docker compose --file \"${BCD_HOME}/docker-compose.yml\" up bcd -d"
eval "$DOCKER_COMMAND_PREFIX $DOCKER_COMMAND" || exit $?

## Create the configuration archive for the target environment

if [[ "$PROJECT_CONFIGURATION_TEMPLATE_PATH" ]]; then
    COMMAND="bcd ${BCD_VERBOSE} --scenario scenarios/build_and_deploy.yml --yes livingapp merge-conf --path project.template.bconf --input project.yml --output project.bconf"
    DOCKER_COMMAND="docker compose --file \"${BCD_HOME}/docker-compose.yml\" exec --user bonita --workdir \"/home/bonita/bonita-continuous-delivery\" bcd \"/bin/bash\" -c \"source ~/.bashrc && ${COMMAND}\""
    eval "$DOCKER_COMMAND_PREFIX $DOCKER_COMMAND" || exit $?
fi

## Deploy the project and the environment configuration with BCD

COMMAND="bcd ${BCD_VERBOSE} --scenario scenarios/build_and_deploy.yml --yes livingapp deploy ${BCD_DEVELOPMENT_MODE} ${BCD_DISABLE_CERTIFICATE_CHECK} ${BCD_DEBUG} --path project.zip"
if [[ "$PROJECT_CONFIGURATION_TEMPLATE_PATH" ]]; then
    COMMAND+=" --configuration-path project.bconf"
fi
DOCKER_COMMAND="docker compose --file \"${BCD_HOME}/docker-compose.yml\" exec --user bonita --workdir \"/home/bonita/bonita-continuous-delivery\" bcd \"/bin/bash\" -c \"source ~/.bashrc && ${COMMAND}\""
eval "$DOCKER_COMMAND_PREFIX $DOCKER_COMMAND" || exit $?

## Change permissions on files created by bonita user so that host can access them

COMMAND="chmod -R 777 ."
DOCKER_COMMAND="docker compose --file \"${BCD_HOME}/docker-compose.yml\" exec --user bonita --workdir \"/home/bonita/bonita-continuous-delivery\" bcd \"/bin/bash\" -c \"source ~/.bashrc && ${COMMAND}\""
eval "$DOCKER_COMMAND_PREFIX $DOCKER_COMMAND"

echo "Deployment done"
