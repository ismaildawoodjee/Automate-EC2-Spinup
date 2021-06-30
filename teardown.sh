#!/bin/bash
# Author: Ismail Dawoodjee

# > ./logs/setup.log
rm -r logs
rm -f docker-ec2.pem
aws ec2 delete-key-pair --key-name docker-ec2
aws ec2 delete-security-group --group-name docker-ec2-sg
# teardown instance as well