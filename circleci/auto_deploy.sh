#!/bin/bash

set -u

git_number_of_commit() {
  git rev-list HEAD --count 2>/dev/null
}

git_number_of_commit_since_tag() {
  tag=$1;shift
  output=$(git rev-list $tag..HEAD --count 2>/dev/null)
  if [ -z "$output" ]; then
    return 1
  fi
  echo "$output"
}

git_tag_last() {
  output=$(git describe --abbrev=0 2>/dev/null)
  if [ -z "$output" ]; then
    return 1
  fi
  echo "$output"
}

git_tag_increment_minor() {
  tag=$1;shift
  version_numbers=($(echo "$tag" | grep -oP '[0-9]*'))
  echo "v${version_numbers[0]}.$((${version_numbers[1]}+1)).${version_numbers[2]}"
}

retreive_version_number_from_tag() {
  echo "$1" | grep -oP '([0-9]*\.*)*'
}

get_version_from_packagejson() {
  echo "Using 'PACKAGEJSON' version provider," 1>&2
  if [ -f "package.json" ]; then
    echo $(grep -m1 version package.json | awk -F: '{ print $2 }' | sed 's/[", ]//g' | sed 's/-/~/g')
  else
    echo "File 'package.json' does not exist." 1>&2
  fi
}

get_version_from_git() {
  echo "Using 'GIT' version provider" 1>&2
  if git rev-parse --git-dir > /dev/null 2>&1; then # are we n a git repository ?
    if [ $1 == "stable" ]; then
      #parse tag and generate version
      echo "$(retreive_version_number_from_tag ${CIRCLE_TAG})";
      return 0
    elif [ $1 == "release" ]; then
      # create release tag from last tag.
      current_tag_name=$(git_tag_last)
      if [ -z "$current_tag_name" ]; then
        echo "It seems that there is no tag yet in this project. Consider creating a tag with 'git tag -a v1.0.0 -m \"Initial release\"'. For now, using version '0.0.0'." 1>&2
        echo "0.0.0~$(git_number_of_commit)"
        return 0
      else
        next_tag_name=$(git_tag_increment_minor "$current_tag_name")
        echo "$(retreive_version_number_from_tag ${next_tag_name})~$(git_number_of_commit_since_tag ${current_tag_name})"
        return 0
      fi
    fi
  else
    echo 'Not a git repository.' 1>&2
  fi
}

get_version() {
  # $1 = version provisions (AUTO, PACKAGEJSON, GIT)
  # $2 = stage (testing, release, stable)
  local version
  for provider in $1; do
    case "$provider" in
      'PACKAGEJSON')
        version="$(get_version_from_packagejson)"
        ;;
      'GIT')
        version="$(get_version_from_git $2)"
        ;;
    esac
    if [ -n "$version" ]; then
      echo $version;
      return 0
    fi
  done
  echo '0.0.0~0';
}

check_variable() {
  # why +x : http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
  if [ -z ${CIRCLE_PROJECT_REPONAME+x} ]; then
    echo "Environment variable 'CIRCLE_PROJECT_REPONAME' is not set. Using default value 'reponame'" 1>&2
    CIRCLE_PROJECT_REPONAME='reponame'
  fi

  if [ -z ${CIRCLE_REPOSITORY_URL+x} ]; then
    echo "Environment variable 'CIRCLE_REPOSITORY_URL' is not set. Using default value 'repourl'" 1>&2
    CIRCLE_REPOSITORY_URL='repourl'
  fi

  if [ -z ${DEPLOY_PREFIX+x} ]; then
    echo "Environment variable 'DEPLOY_PREFIX' is not set. Using default value '/srv/kronos/${CIRCLE_PROJECT_REPONAME}'" 1>&2
    DEPLOY_PREFIX="/srv/kronos/${CIRCLE_PROJECT_REPONAME}/"
  fi

  if [ -z ${DEPLOY_DIRECTORIES+x} ]; then
    echo "Environment variable 'DEPLOY_DIRECTORIES' is not set. Using default value '/srv/kronos/${CIRCLE_PROJECT_REPONAME}/ /etc/kronos/${CIRCLE_PROJECT_REPONAME}/'" 1>&2
    DEPLOY_DIRECTORIES="/srv/kronos/${CIRCLE_PROJECT_REPONAME}/ /etc/kronos/${CIRCLE_PROJECT_REPONAME}/"
  fi

  if [ -z ${DEPLOY_DESCRIPTION+x} ]; then
    echo "Environment variable 'DEPLOY_DESCRIPTION' is not set. Using default value '${CIRCLE_PROJECT_REPONAME}'" 1>&2
    DEPLOY_DESCRIPTION='repourl'
  fi

  if [ -z ${DEPLOY_FILES+x} ]; then
    echo "Environment variable 'DEPLOY_FILES' is not set. Using default value '.'" 1>&2
    DEPLOY_FILES='.'
  fi

  if [ -z ${DEPLOY_OTHER_OPTIONS+x} ]; then
    echo "Environment variable 'DEPLOY_OTHER_OPTIONS' is not set. Using default value ''" 1>&2
    DEPLOY_OTHER_OPTIONS=''
  fi

  if [ -z ${CIRCLECI+x} ]; then
    echo "Environment variable 'CIRCLECI' is not set. Initializing 'CIRCLECI' variable to bool 'false'" 1>&2
    CIRCLECI=false
  fi

  if [ -z ${DEPLOY_PACKAGE_NAME+x} ]; then
    echo "Environment variable 'DEPLOY_PACKAGE_NAME' is not set. Initializing 'DEPLOY_PACKAGE_NAME' to '${CIRCLE_PROJECT_REPONAME}' (CIRCLE_PROJECT_REPONAME variable value)" 1>&2
    DEPLOY_PACKAGE_NAME=$CIRCLE_PROJECT_REPONAME
  fi

  if [ -z ${DEPLOY_VERSION_PROVIDER+x} ]; then
    echo "Environment variable 'DEPLOY_VERSION_PROVIDER' is not set. Initializing 'DEPLOY_VERSION_PROVIDER' to 'GIT'" 1>&2
    DEPLOY_VERSION_PROVIDER='GIT'
  fi
}

#
# main
#

if ! command -v fpm >/dev/null 2>&1; then
  echo "'fpm' is not installed. Consider adding 'gem install fpm -v 1.4.0' under the 'dependencies' section of your circle.yml file." 1>&2
  apt-get install ruby-dev
  gem install fpm -v 1.4.0
fi

check_variable

if [ ! -z ${CIRCLE_TAG+x} ]; then # why +x : http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
  echo 'Building stable version.' 1>&2
  STAGE='stable'
else
  echo "Building release version." 1>&2
  STAGE='release'
fi

VERSION="$(get_version $DEPLOY_VERSION_PROVIDER $STAGE)"

if [ -f "./package/${DEPLOY_PACKAGE_NAME}_${VERSION}_all.deb" ]; then
  rm -f "./package/${DEPLOY_PACKAGE_NAME}_${VERSION}_all.deb"
fi

if [ ! -d "./package" ]; then
  mkdir package
fi

fpm -s dir -t deb -v "$VERSION" -n "${DEPLOY_PACKAGE_NAME}" \
--prefix "${DEPLOY_PREFIX}" \
--deb-priority "optional" \
--directories "${DEPLOY_DIRECTORIES}" \
--maintainer "System Administrator <sysadmin@kronostechnologies.com>" \
--url "${CIRCLE_REPOSITORY_URL}" \
--vendor "Kronos Technologies" \
--architecture "all" \
--package "./package/" \
--description "${DEPLOY_DESCRIPTION}" \
${DEPLOY_OTHER_OPTIONS} \
${DEPLOY_FILES};

if $CIRCLECI; then
    echo "Deploying './package/${DEPLOY_PACKAGE_NAME}_${VERSION}_all.deb' to 'repo.ktech.io' for '${STAGE}'"
    scp -o SendEnv=DEPLOY_PACKAGE_NAME -i ~/.ssh/id_circleci_github "./package/${DEPLOY_PACKAGE_NAME}_${VERSION}_all.deb" kronostechnologies-build@repo.ktech.io:
    ssh -o SendEnv=DEPLOY_PACKAGE_NAME -i ~/.ssh/id_circleci_github kronostechnologies-build@repo.ktech.io "freight add ${STAGE}"
fi

echo 'done'
