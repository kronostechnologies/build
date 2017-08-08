#!/bin/bash

image=$1
region=$2
tag=$3
aws_id=$4

DOCKER_VERSION=`docker version -f '{{.Server.Version}}'`

# Backtick (`) are required for the login session to be kept alive throughout the execution of this script
if [[ $DOCKER_VERSION = '1.9.1-circleci-cp-workaround' ]]; then
  `aws ecr get-login --region $region` > /dev/null 2>&1
else
  `aws ecr get-login --region $region --no-include-email` > /dev/null 2>&1
fi
docker tag $image $aws_id.dkr.ecr.$region.amazonaws.com/$image:$tag
aws ecr describe-repositories --region $region --repository-name $image > /dev/null 2>&1
if [ $? -ne 0 ]; then
  aws ecr create-repository --region $region --repository-name $image
fi
docker push $aws_id.dkr.ecr.$region.amazonaws.com/$image:$tag
