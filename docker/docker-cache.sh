#!/bin/bash

if [ $# -lt 1 ]; then
  echo "USAGE: $0 [save|load]"
  exit 1
fi

mkdir -p ~/docker
cd ~/docker

reload() {
  source ${BASH_SOURCE[0]}
}
alias r=reload

get-image-field() {
  local imageId=$1
  local field=$2
  : ${imageId:? required}
  : ${field:? required}

  docker images --no-trunc|sed -n "/${imageId}/ s/ \+/ /gp"|cut -d" " -f $field
}

get-image-name() {
  get-image-field $1 1
}

get-image-tag() {
  get-image-field $1 2
}

save() {
  local dangling ids name safename tag

  dangling=`docker images -f "dangling=true" -q`
  if [[ -n $dangling ]]; then
    echo [DEBUG] removing dangling image $dangling
    docker rmi $dangling 2>&1 > /dev/null
  fi

  ids=$(docker images -q)
  for id in $ids; do
    name=$(get-image-name $id)
    tag=$(get-image-tag $id)
    if [[  $name =~ / ]] ; then
       dir=${name%/*}
       mkdir -p $dir
    fi
    echo [DEBUG] save $name:$tag with id $id ...
    (time  docker save -o $name.$tag.dim $name:$tag) 2>&1|grep real
  done
}

load() {
  local name safename noextension tag

  for image in $(find . -name \*.dim); do
    echo [DEBUG] load $image
    tar -Oxf $image repositories
    echo
    docker load -i $image
  done
}

$@
