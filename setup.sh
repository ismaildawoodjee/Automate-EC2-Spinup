#!/bin/bash
# Author: Ismail Dawoodjee
# Bash script to automate setup for an EC2 instance using the AWS CLI commands.
# Can add more variables and options as necessary for the commands.

set -eou pipefail

if [ $# -eq 0 ]; then
    echo 'ERROR: Unspecified profile name.' \
        'You must enter your profile name as "bash setup.sh profile-name".'
    exit 0
fi

# reference: Stackoverflow-Redirect echo output in shell script to logfile
mkdir logs
LOG_LOCATION="./logs"
exec > >(tee -a $LOG_LOCATION/setup.log)
exec 2>&1

START_TIME=$(date +"%s")
DATE_TIME=$(date +"%x %r %S %Z")
echo "INFO: Started setup at $DATE_TIME"

# PROFILE_NAME="ismaildawoodjee"
POLICY_NAME="AmazonEC2FullAccess"
POLICY_ARN="arn:aws:iam::aws:policy/$POLICY_NAME"

KEYPAIR_NAME="docker-ec2"
SG_NAME="docker-ec2-sg"
EC2_TYPE="t2.micro"
IMAGE_ID="ami-018c1c51c7a13e363"
TAG_KEY="docker"
TAG_VALUE="ec2"

function attach_policy () {

    # Assign IAM permission for user to have full EC2 access
    echo "INFO: Attaching user policy $POLICY_NAME to $1"
    aws iam attach-user-policy \
        --policy-arn $POLICY_ARN \
        --user-name "$1"
}

function create_authorize_security_group () {

    echo "INFO: Creating security group $SG_NAME"
    aws ec2 create-security-group \
        --group-name $SG_NAME \
        --description "Security group to host Docker container"

    # Authorize security group to allow public/private SSH access into EC2
    echo "INFO: Authorizing security group $SG_NAME for SSH access"
    aws ec2 authorize-security-group-ingress \
        --group-name $SG_NAME \
        --protocol tcp \
        --port 22 \
        --cidr 1.2.3.4/0  # your IP, but can set 0.0.0.0/0 for public access
}

function create_keypair () {

    # Create a key pair for the EC2 launch
    echo "INFO: Creating a key pair with name $KEYPAIR_NAME"
    aws ec2 create-key-pair \
        --key-name $KEYPAIR_NAME \
        --query "KeyMaterial" \
        --output text \
        > $KEYPAIR_NAME.pem

    # Change permissions to read-only for user, others should not have access
    chmod 400 $KEYPAIR_NAME.pem
}

function launch_ec2 () {

    echo "INFO: Launching an instance of type $EC2_TYPE in security group $SG_NAME"
    aws ec2 run-instances \
        --image-id $IMAGE_ID \
        --count 1 \
        --instance-type $EC2_TYPE \
        --key-name $KEYPAIR_NAME \
        --security-groups $SG_NAME \
        --tag-specifications \
            "ResourceType=instance,Tags=[{Key=$TAG_KEY,Value=$TAG_VALUE}]"
}

function access_with_ssh () {

    # Assuming there is ONLY one instance with a unique key-value for tag
    echo "INFO: Getting public IP address for EC2 instance"
    EC2_PUBLIC_DNS=$(aws ec2 describe-instances \
        --filters "Name=tag:$TAG_KEY,Values=$TAG_VALUE" \
        --query "Reservations[].Instances[].PublicDnsName" \
        --output text
    )

    # Wait 30 seconds to allow EC2 to fully boot up
    sleep 30
    echo "INFO: Waiting 30 seconds, then accessing EC2 instance using SSH"
    ssh -i "$KEYPAIR_NAME.pem" "ec2-user@$EC2_PUBLIC_DNS"
}

# ssh into EC2 instance and run updates, install docker, pull docker image, etc

attach_policy "$@"
create_keypair
create_authorize_security_group
launch_ec2
access_with_ssh

END_TIME=$(date +"%s")
DURATION=$((END_TIME - START_TIME))
echo "INFO: Completed setup within $DURATION seconds."
