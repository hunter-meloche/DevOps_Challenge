#!/bin/bash

# Find the instance's IP if it is not given
if [ $# == 0 ]; then
  IP=$(aws ec2 describe-instances \
    --filter Name=instance.group-name,Values=nginx_sg \
    --query 'Reservations[*].Instances[*].PublicIpAddress' \
    --output text)
else
  IP=$1
fi

# Prints the IP address
echo "The IP address of the instance is $IP"

# Assigns a command to 'getCode' that gets the status code of an address
getCode="curl -s -o /dev/null -w \"%{http_code}\""

# Gets the status code for the instance on port 80
HTTP_CODE=$($getCode $IP)

# Waits for nginx to start by periodically asking for a status code from the instance IP address
time=0
while [ "$HTTP_CODE" == "\"000\"" ];
do
    echo "Waiting for nginx container to start in EC2 instance ($time""s/~95s)"
    sleep 15
    time=$(($time+15))
    if [ "$time" == "300" ]; then
        echo "Timeout - Something is broken"
        exit
    fi
    HTTP_CODE=$($getCode $IP)
done

# Code 301 indicates a redirect to HTTPS
if [ "$HTTP_CODE" == "\"301\"" ]; then
    echo "Redirect of HTTP to HTTPS works"
else
    echo "Redirect of HTTP to HTTPS is NOT working $HTTP_CODE"
fi

# Gets the status code for HTTPS
HTTPS_CODE=$($getCode -k https://$IP)

# Code 200 indicates HTTPS is functioning
if [ "$HTTPS_CODE" == "\"200\"" ]; then
    echo "HTTPS works"
else
    echo "HTTPS is NOT working $HTTPS_CODE"
fi

# Gets the HTML from the instance's HTTPS address
getHTML=$(curl -k -s https://$IP)

# Defines the expected Hello World HTML
expectedHTML=("<html> <head> <title>Hello World</title> </head> <body> <h1>Hello World!</h1> </body> </html>")

# Checks that the retrieved Hello World HTML page is the same as was expected
if [ "$getHTML" == "$expectedHTML" ]; then
    echo "Hello World works"
else
    echo "The retrieved HTML does not match expected Hello World"
fi
