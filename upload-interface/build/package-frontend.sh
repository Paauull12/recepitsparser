#!/bin/bash
# package-frontend.sh
#
# Build the front end app with node and npm
#
# @author: TPE
#
# debug
#set -x

BUILD_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT_DIR="$( cd ${BUILD_SCRIPT_DIR} && cd ../ && pwd )"

echo ${BUILD_SCRIPT_DIR}
echo ${REPO_ROOT_DIR}

NPM_CACHE_PATH="/projet/build-cache/npm"

DIST="$REPO_ROOT_DIR/dist"
DIST_TMP="$REPO_ROOT_DIR/dist-tmp"

# print usage
usage() {
  printf "Build the front end app with node and npm.\n\n"
  printf "usage: %s [<options>] <version> <my-component> [<npm commands>]\n\n" "$(basename $0)"
  #printf "usage: %s [<options>] </path/to/component/sources> <my-component> [<npm commands>]\n\n" "$(basename $0)"
  printf "npm commands: default is: build\n\n"
  printf "options:\n\
  -d: Use docker to wrap the build.\n\
  -s: Skip cleans
  \n"
}

# ###################
# Check requirements
# ###################
checkRequirements() {
    if [ ! -d $FRONTEND_DIR ];then
        echo "The sources of the frontend as not been found"
        exit 1
    fi
    if [ ! -f "$FRONTEND_DIR/package.json" ];then
        echo "The package.json as not been found in $FRONTEND_DIR"
        exit 1
    fi
}

# ###########
# Pre clean
# ###########
preClean() {
    rm -rf $FRONTEND_DIR/dist
    if [ ! -d "${REPO_ROOT_DIR}/dist" ]; then mkdir ${REPO_ROOT_DIR}/dist; else rm -rf ${REPO_ROOT_DIR}/dist/${FRONTEND_NAME}/; fi
    if [ -d ${DIST_TMP} ]; then rm -rf ${DIST_TMP}; fi
}

# ##################
# Build front end
# ##################
buildNpm() {
    cd ${FRONTEND_DIR}
    npm install
    rc=$?
    if [ "$rc" != 0 ]; then
        exit $rc
    fi
    npm run ${NPM_CMD}
    rc=$?
    if [ "$rc" != 0 ]; then
        exit $rc
    fi
}

buildDocker() {
    docker run --name ${DOCKER_CONTAINER_NAME} --rm \
        -ti --tty=false \
        -u $(id -u) \
        -v ${NPM_CACHE_PATH}:/var/npm/cache -e npm_config_cache=/var/npm/cache \
        -v ${FRONTEND_DIR}:/src/ -w /src \
        node:10-alpine \
        sh -c "npm install && npm run ${NPM_CMD}"
    rc=$?
    if [ "$rc" != 0 ]; then
        exit $rc
    fi
}

# ###################################################
# Create the actifact
# ###################################################
zipFiles() {
    echo "[%s] Zip :"
    echo "[%s] Rename ${DIST}/${FRONTEND_NAME} to ${DIST_TMP}"
    mv ${DIST}/${FRONTEND_NAME} ${DIST_TMP}
    rc=$?
    if [ "$rc" != 0 ]; then
        exit $rc
    fi
    # check these nothing else that have been generated
    echo "[%s] Remove ${DIST}"
    rmdir ${DIST}
    rc=$?
    if [ "$rc" != 0 ]; then
        exit $rc
    fi
    echo "[%s] Create ${DIST}"
    mkdir ${DIST}
    rc=$?
    if [ "$rc" != 0 ]; then
        exit $rc
    fi
    echo "[%s] move into ${DIST_TMP}"
    cd ${DIST_TMP}
    # delete server config file example
    if [ -e "config" ]; then
        echo "[%s] Remove default server config"
        rmdir config
    fi
    echo "[%s] Folder to zip :"
    ls -la .
    echo "[%s] Create Zip :"
    tar -czf ${DIST}/${FRONTEND_NAME}.tgz *
    rc=$?
    if [ "$rc" != 0 ]; then
        exit $rc
    fi
}

# MAIN
SKIP_CLEAN=false
WITH_DOCKER=false
# Options managements
while getopts "dswh" opt;do
  case $opt in
    d) WITH_DOCKER=true;;
    s) SKIP_CLEAN=true;;
    h) usage
      exit 0
      ;;
    ?) echo "unknown option ${opt}"
       usage
       exit 1
    ;;
  esac
done

shift $((OPTIND-1))

# Argument management
# FRONTEND_PROJECT_PATH=$1
# if [ -z "$FRONTEND_PROJECT_PATH" ];then
#   usage
#   exit 1
# fi

VERSION=$1
if [ -z "$VERSION" ];then
  usage
  exit 1
fi

shift 1

FRONTEND_NAME=$1
if [ -z "$FRONTEND_NAME" ];then
  usage
  exit 1
fi

shift 1
NPM_CMD=$*

if [ -z "$NPM_CMD" ];then
  NPM_CMD="build"
fi
FRONTEND_PROJECT_PATH=''
DOCKER_CONTAINER_NAME="build-${FRONTEND_NAME}"
FRONTEND_DIR="${REPO_ROOT_DIR}/${FRONTEND_PROJECT_PATH}"

#MAIN
checkRequirements

# #Write version
# echo "export const VERSION = \"$VERSION\";" > ${FRONTEND_DIR}/src/environments/version.ts
# echo "{\"VERSION\":\"$VERSION\"}" > ${FRONTEND_DIR}/src/assets/version.json
# export VERSION=$VERSION
# #date +'%d/%m/%Y %H:%M:%S:%3N'
# export VERSION_DATE=`date +'%d/%m/%Y'`
# echo "export const VERSION_DATE = \"$VERSION_DATE\";" >> ${FRONTEND_DIR}/src/environments/version.ts

# It's a trap !!!
trap "rm -rf ${DIST_TMP}" EXIT

if [ $SKIP_CLEAN != "true" ];then
    preClean
fi
if [ $WITH_DOCKER != "true" ];then
    buildNpm
else
    buildDocker
fi
zipFiles
echo "[%s] dist/${FRONTEND_NAME}.tgz package successfully generated !!"