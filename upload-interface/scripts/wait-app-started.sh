#!/bin/bash
# wait-app-started
#
# Wait that in application is started and check application URL response
#
# @author: TPE
#
# debug
# set -x

# print usage
usage() {
  printf "Wait that in application is started and check application URL response.\n\n"
  printf "usage: %s <app-url> \n\n" "$(basename "$0")"
}

checkUrl() {
    ddone="false"
    dmax=60
    dc=0

    while [[ $ddone == "false" && $dc -lt $dmax ]]; do

        healthhttpcode=$(curl --connect-timeout 10 -k -s -o /dev/null -I -w "%{http_code}" "$HEALTH_URL")

        if [[ $healthhttpcode == "404" || $healthhttpcode == "503" || $healthhttpcode == "000" ]]; then
            echo "unmodifed $healthhttpcode, sleep 2..."
            sleep 2
        elif [[ $healthhttpcode == "200" ]]; then
            healthresponse=$(curl -k -s "$HEALTH_URL")
            if echo "$healthresponse" | grep --quiet '"status":"UP"'; then
                echo "[$SCRIPT_NAME] $APP_URL successfully started !! "
                ddone="true"
            else
                echo "[$SCRIPT_NAME][ERROR] $HEALTH_URL returned $healthresponse"
                exit 2
            fi
        else
            echo "[$SCRIPT_NAME][ERROR] $HEALTH_URL returned error code $healthhttpcode"
            exit 2
        fi
        dc=$(( dc + 1 ))

    done

    if [[ $ddone != "true" ]]; then
        echo "[$SCRIPT_NAME] ERROR: not all output was received in $dc requests"
        exit 2
    fi
}

# MAIN

# Options managements
while getopts "dswh" opt;do
  case $opt in
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
APP_URL=$1
if [ -z "$APP_URL" ];then
  usage
  exit 1
fi

SCRIPT_NAME=$(basename "$0")

HEALTH_URL="$APP_URL"

checkUrl