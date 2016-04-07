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

check_variable() {
  if [ -z ${CIRCLE_PROJECT_REPONAME+x} ]; then # why +x : http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
    echo "Environment variable 'CIRCLE_PROJECT_REPONAME' is not set. Using default value 'reponame'" 1>&2
    CIRCLE_PROJECT_REPONAME='reponame'
  fi

  if [ -z ${CIRCLE_REPOSITORY_URL+x} ]; then # why +x : http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
    echo "Environment variable 'CIRCLE_REPOSITORY_URL' is not set. Using default value 'repourl'" 1>&2
    CIRCLE_REPOSITORY_URL='repourl'
  fi

  if [ -z ${DEPLOY_PREFIX+x} ]; then # why +x : http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
    echo "Environment variable 'DEPLOY_PREFIX' is not set. Using default value '/srv/kronos/${CIRCLE_PROJECT_REPONAME}'" 1>&2
    DEPLOY_PREFIX="/srv/kronos/${CIRCLE_PROJECT_REPONAME}/"
  fi

  if [ -z ${DEPLOY_DIRECTORIES+x} ]; then # why +x : http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
    echo "Environment variable 'DEPLOY_DIRECTORIES' is not set. Using default value '/srv/kronos/${CIRCLE_PROJECT_REPONAME}/ /etc/kronos/${CIRCLE_PROJECT_REPONAME}/'" 1>&2
    DEPLOY_DIRECTORIES="/srv/kronos/${CIRCLE_PROJECT_REPONAME}/ /etc/kronos/${CIRCLE_PROJECT_REPONAME}/"
  fi

  if [ -z ${DEPLOY_DESCRIPTION+x} ]; then # why +x : http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
    echo "Environment variable 'DEPLOY_DESCRIPTION' is not set. Using default value '${CIRCLE_PROJECT_REPONAME}'" 1>&2
    DEPLOY_DESCRIPTION='repourl'
  fi

  if [ -z ${DEPLOY_FILES+x} ]; then # why +x : http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
    echo "Environment variable 'DEPLOY_FILES' is not set. Using default value '.'" 1>&2
    DEPLOY_FILES='.'
  fi
}

if [ ! command -v foo >/dev/null 2>&1 ]; then
  echo "'fpm' is not installed. Consider adding 'gem install fpm -v 1.4.0' under the 'dependencies' section of your circle.yml file." 1>&2
  gem install fpm -v 1.4.0
fi

check_variable

if [ ! -z ${CIRCLE_TAG+x} ]; then # why +x : http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
  echo 'Building stable version.' 1>&2
  #parse tag and generate version
  VERSION="$(retreive_version_number_from_tag ${CIRCLE_TAG})"
else
  echo "Building release version." 1>&2
  # create release tag from last tag.
  tag_name=$(git_tag_last)
  if [ -z "$tag_name" ]; then
    echo "It seems that there is no tag yet in this project. Consider creating a tag with 'git tag -a v1.0.0 -m \"Initial release\"'. For now, using version '0.0.0'." 1>&2
    VERSION="0.0.0~$(git_number_of_commit)"
  else
    tag_name=$(git_tag_increment_minor "$tag_name")
    VERSION="$(retreive_version_number_from_tag ${tag_name})~$(git_number_of_commit_since_tag ${tag_name})"
  fi
fi

if [ -f "./package/${CIRCLE_PROJECT_REPONAME}_${VERSION}_all.deb" ]; then
  rm -f "./package/${CIRCLE_PROJECT_REPONAME}_${VERSION}_all.deb"
fi

if [ ! -d "./package" ]; then
  mkdir package
fi

fpm -s dir -t deb -v "$VERSION" -n "${CIRCLE_PROJECT_REPONAME}" \
--prefix "${DEPLOY_PREFIX}" \
--deb-priority "optional" \
--directories "${DEPLOY_DIRECTORIES}" \
--maintainer "System Administrator <sysadmin@kronostechnologies.com>" \
--url "${CIRCLE_REPOSITORY_URL}" \
--vendor "Kronos Technologies" \
--architecture "all" \
--package "./package/" \
--description "${DEPLOY_DESCRIPTION}" \
${DEPLOY_FILES};

echo 'done'
