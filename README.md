# Bash Scripts to Automatically Spin Up an EC2 Instance

The main motivation of this mini-project was to practice my Bash scripting
skills and get familiar with using the AWS CLI to automate tasks on the command
line. This particular repo has a setup script to automatically spin up an EC2
instance, SSH into it, install dependencies, and host a simple Flask app using
the image pulled from Docker Hub. At a high level, the process of this deployment
is shown below:

![A high-level overview of the architecture](/assets/images/infrastructure.png)

[Running on EC2!](http://ec2-54-169-122-216.ap-southeast-1.compute.amazonaws.com:5000) (powered down for now)

![Simple Flask app running on EC2](/assets/images/running_on_ec2.png)
