#!/bin/bash

image=$1
region=$2

# Backtick (`) are required for the login session to be kept alive thoughout the execution of this script
`aws ecr get-login --region $region` > /dev/null 2>&1
docker tag $image:latest 611542441284.dkr.ecr.$region.amazonaws.com/$image:latest
aws ecr describe-repositories --region $region --repository-name $image > /dev/null 2>&1
if [ $? -ne 0 ]; then
  aws ecr create-repository --region $region --repository-name $image
fi
docker push 611542441284.dkr.ecr.$region.amazonaws.com/$image:latest
