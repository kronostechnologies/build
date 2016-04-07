# CIRCLECI script auto_deploy.sh

CircleCI package deploy is used to auto build and auto deploy a package to a debian repository. Packages are build using `fpm` tool version 1.4.0 (`gem install fpm -v 1.4.0`).

## Tag inference

This script is able to infer the tag and generate a package version from it. If no tag are set at all, version 0.0.0 is used. Tags should be of the form `v[0-9]\.[0-9]\.[0-9]` i.e. `v1.1.0`.

If the `CIRCLE_TAG` is set, a stable package is built using the `CIRCLE_TAG` as it's version.

If the `CIRCLE_TAG` is not set, a release package is built. A release package will try to find the latest tag, increment it's minor version by one, append `~` at the end and append the number of commit since the last tag. For example, if a tag `v1.0.0` exist and a commit is pushed on master, the version of the package will be `1.1.0~1`. If another commit is made, `1.1.0~2` and so on.

## CIRCLECI circle.yml deploy example

For this script to work properly, you will need two deployment configuration in `circle.yml`. One which triggers on a branch and one which triggers on tags.

This deployment sample will create a release package on every commit made on master. For every tag, a stable package will be generated using the tag version.

```
deployment:
  release:
    branch: master
    commands:
      - wget https://raw.githubusercontent.com/kronostechnologies/build/master/circleci/auto_deploy.sh 
      - chmod +x auto_deploy.sh
      - ./auto_deploy.sh
  stable:
    tag: /v[0-9]+\.[0-9]+\.[0-9]+/
    commands:
      - wget https://raw.githubusercontent.com/kronostechnologies/build/master/circleci/auto_deploy.sh 
      - chmod +x auto_deploy.sh
      - ./auto_deploy.sh
```

Note that the `wget` command needs to point a download miror of the auto_deploy.sh script. This can be github.

See https://circleci.com/docs/configuration/#deployment for more details.

## Environment variable

Environment variable are used to configure the build and deploy process. Any variable that start with `CIRCLE_` are CIRCLECI environment variable and should not be overriden. Variable starting with `DEPLOY_` are script's own environment variable and should be overriden.

Below an example of overriding environment variable.

```
machine:
  environment:
    DEPLOY_FILES: /bin /test app.js
    DEPLOY_PREFIX: /srv/kronos/
    DEPLOY_DESCRIPTION: Description of the package
```

See https://circleci.com/docs/configuration/#modifiers for more details about circleci environment variable.

Below is the list of all environment variable used by this script.

### CIRCLE_TAG
The tag version that will be build. Whenever a tag is pushed, `package_deploy.sh` will generate a package using this specific tag. Otherwise, tag inference is used.

### CIRCLE_PROJECT_REPONAME
The repo name of the project. This variable is auto set by circleci.

### CIRCLE_REPOSITORY_URL
The repo url. This variable is auto set by circleci.

### DEPLOY_PREFIX
The `--prefix` fpm option overrides. Default is `/srv/kronos/${CIRCLE_PROJECT_REPONAME}`.

### DEPLOY_DIRECTORIES
The `--directories` fpm option overrides. Default is `/srv/kronos/${CIRCLE_PROJECT_REPONAME}/ /etc/kronos/${CIRCLE_PROJECT_REPONAME}/`.

### DEPLOY_DESCRIPTION
The `--description` fpm option overrides. Default is the reponame provided by `CIRCLE_PROJECT_REPONAME`.

### DEPLOY_FILES
The fpm argument overrides. By default, this is set to `.` which includes ALL file from the directory. You will usually want to override this setting by specifying directories and files.

