#!/bin/bash

DOCKERFILE=$1

echo "> linting '$DOCKERFILE'"
docker run --rm -i lukasmartinelli/hadolint < $DOCKERFILE
