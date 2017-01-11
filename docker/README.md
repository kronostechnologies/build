#Docker

This folder contains every script needed to deploy a docker image

## aws-push.sh

This script push an image to a given region.

Usage:

```
  $ ./aws-push.sh image/name us-east-1
```

## docker-cache.sh

This script cache docker images so they don't have to be rebuilt everytime.

Usage:

```
  $ ./docker-cache.sh save # Save every docker in files to the current directory
  $ ./docker-cache.sh load # Scan the current folder and load any saved docker image file
```
