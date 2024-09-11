#!/usr/bin/env bash

# Script adapted from https://gist.github.com/rishabh9/183cc0c4c3ada4f8df94d65fcd73a502

# Reference: http://roboojack.blogspot.in/2014/12/bulk-upload-your-local-maven-artifacts.html

if [ "$#" -ne 3 ] || ! [ -d "$1" ]; then
    echo "Usage:"
    echo "       bash run.sh <repoRootFolder> <repositoryId> <repositoryUrl>"
    echo ""
    echo ""
    echo "       Where..."
    echo "       repoRootFolder: The folder containing the repository tree."
    echo "                       Ensure you move the repository outside of ~/.m2 folder"
    echo "                       or whatever is configured in settings.xml"
    echo "       repositoryId:   The repositoryId from the <server> configured for the repositoryUrl in settings.xml."
    echo "                       Ensure that you have configured username and password in settings.xml."
    echo "       repositoryUrl:  The URL of the repository where you want to upload the files."
    exit 1
fi

while read -r line ; do
    echo "Processing file $line"
    pomLocation=${line}
    fileLocation=${line}
    fileLocation=${fileLocation/pom/jar}
    if ! [[ -f "$fileLocation" ]]; then
        echo "Single pom $pomLocation detected"
        fileLocation=$pomLocation
    fi
    mvn deploy:deploy-file -DpomFile="$pomLocation" -Dfile="$fileLocation" -DrepositoryId="$2" -Durl="$3"
done < <(find "$1" -name "*.pom")
