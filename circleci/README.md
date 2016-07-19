# CIRCLECI script auto_deploy.sh

CircleCI package deploy is used to auto build and auto deploy a package to a debian repository by connecting on the `autodeploy-shell`. Packages are build using `fpm` tool version 1.4.0 (`gem install fpm -v 1.4.0`).

## Stage


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

## Environment variables

Environment variables are used to configure the build and deploy process. Any variable that start with `CIRCLE_` are CIRCLECI environment variable and should not be overriden. Variable starting with `DEPLOY_` are script's own environment variable and can be overriden.

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

### CIRCLECI
A flag that indicates if the environment is a circleci environment or not. This is needed to trigger the deploying phase of `auto_deploy.sh`.

### DEPLOY_PREFIX
The `--prefix` fpm option overrides. Default is `/srv/kronos/${CIRCLE_PROJECT_REPONAME}`.

### DEPLOY_DIRECTORIES
The `--directories` fpm option overrides. Default is `/srv/kronos/${CIRCLE_PROJECT_REPONAME}/ /etc/kronos/${CIRCLE_PROJECT_REPONAME}/`.

### DEPLOY_DESCRIPTION
The `--description` fpm option overrides. Default is the reponame provided by `CIRCLE_PROJECT_REPONAME`.

### DEPLOY_FILES
The fpm argument overrides. By default, this is set to `.` which includes ALL file from the directory. You will usually want to override this setting by specifying directories and files.

### DEPLOY_OTHER_OPTIONS
Any additional options for fpm that are not included in this script may be specified by this environment variable. See https://github.com/jordansissel/fpm/wiki#usage for a complete list or `fpm --help`.

### DEPLOY_PACKAGE_NAME
Specify the package name. Default value is the value of $CIRCLE_PROJECT_REPONAME.

### DEPLOY_VERSION_PROVIDER
Specify how the version number is generated. This value can take one value i.e. `GIT` or multiple space separated value i.e. `PACKAGEJSON GIT`. Default value is `GIT`.

#### PACKAGEJSON
Tries to read the version number of `package.json` file. Whatever the version number is, that is what will be used to generate the package version unless the version is empty.

#### GIT
The `GIT` setting will use `git` as it's version provider. If the `CIRCLE_TAG` is set, the `CIRCLE_TAG` environment variable is used as it's version. Otherwise, `GIT` will try to find the latest tag, increment it's minor version by one, append `~` and add the number of commit since the last tag.

For example, if a tag `v1.0.0` exist and a commit is pushed on master, the version of the package will be `1.1.0~1`. If another commit is made, `1.1.0~2` and so on.

  > Because `GIT` fallback on version `0.0.0~$number_of_commit_since_begining_of_project`, it is recommended to set this provider as last.

## Autodeploy-Shell Environment Variable

Below are the environment variable that are sent to the deploy shell.

  - DEPLOY_PACKAGE_NAME

## Testing the autodeploy

The script `build.py` is used to test the building process and autodeployment. It will parse your project's circle.yml, export it's environment variable and trigger the `auto_deploy.sh`. Fortunately, any `CIRCLE_*` comes from circleci itself so these variable will never be set. This will cause the `auto_deploy.sh` script to skip the deploying phase.

Simple usage:
```
./build.py ~/path/to/my/project/root
```
