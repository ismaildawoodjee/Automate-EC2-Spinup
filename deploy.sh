#!/bin/bash
# Author: Ismail Dawoodjee
# Bash script to update EC2, install and start Docker, pull image and run
# the Flask container.

set -euo pipefail

mkdir logs
LOG_LOCATION="./logs"
exec > >(tee -a $LOG_LOCATION/dockerize.log)
exec 2>&1

START_TIME=$(date +"%s")
DATE_TIME=$(date +"%x %r %S %Z")
echo -e "Started deployment at $DATE_TIME \n"

USER_NAME="ismaildawoodjee"
REPO_NAME="flask-app"

function update_and_install () {
    # Update, install, start, pull, and run
    echo -e "INFO: Updating EC2, installing Docker and starting it up \n"
    sudo yum -y -q update
    sudo yum -y -q install docker
    sudo service docker start
    sudo docker pull "$USER_NAME/$REPO_NAME:ec2"
    sudo docker run -d \
        --name flask-container \
        -p 5000:5000 \
        "$USER_NAME/$REPO_NAME:ec2"
}

update_and_install

END_TIME=$(date +"%s")
DURATION=$((END_TIME - START_TIME))
echo -e "INFO: Completed deployment within $DURATION seconds. Exiting... \n"
exit