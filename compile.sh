#!/usr/bin/env bash

DIR="$(
  cd "$(dirname "$0")"
  pwd -P
)"
sourceImage=$(${DIR}/support/sourceImage.sh)
targetImage=$(${DIR}/support/targetImage.sh)
archiveFile=$DIR/archive.tar
VERSION=$(${DIR}/support/VERSION.sh)
DOCKER_FILE=${DOCKER_FILE:-Dockerfile}

list() {
  docker images | head -10
}

tag() {
  tag=$1
  if [ -z "$tag" ]; then
    if [ -z "$VERSION" ]; then
      tag=latest
    else
      tag=$VERSION
    fi
  fi
  echo "* <!-- Start to tag: ${tag}"
  echo $tag
  docker tag $sourceImage ${targetImage}:$tag
  list
  echo "* Finish tag -->"
}

push() {
  PUSH_VERSION=${1:-$VERSION}
  LATEST_TAG=${2:-latest}
  if [ -z "$PUSH_VERSION" ]; then
    tag=latest
  else
    tag=$PUSH_VERSION
    if [ "x$LATEST_TAG" != "xlatest" ]; then
      tag=$LATEST_TAG-$PUSH_VERSION
    fi
  fi
  echo "* <!-- Start to push ${targetImage}:$tag"
  echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_LOGIN" --password-stdin
  docker push ${targetImage}:$tag
  echo "* Finish to push -->"
  echo ""
  if [ ! -z "$1" ]; then
    if [ "x$VERSION" == "x$PUSH_VERSION" ]; then
      echo "* <!-- Start to auto push ${targetImage}:${LATEST_TAG}"
      docker tag ${targetImage}:$tag ${targetImage}:${LATEST_TAG}
      docker push ${targetImage}:${LATEST_TAG}
      echo "* Finish to push -->"
    fi
  fi
}

build() {
  if [ -z "$1" ]; then
    NO_CACHE=""
  else
    NO_CACHE="--no-cache"
  fi
  if [ -z "$VERSION" ]; then
    BUILD_ARG=""
  else
    BUILD_ARG="--build-arg VERSION=${VERSION}"
  fi
  echo build: ${DIR}/${DOCKER_FILE}
  docker build ${BUILD_ARG} ${NO_CACHE} -f ${DIR}/${DOCKER_FILE} -t $sourceImage ${DIR}
  list
}

save() {
  echo save
  docker save $sourceImage > $archiveFile
}

restore() {
  echo restore
  docker save --output $archiveFile $sourceImage
}

case "$1" in
  save)
    save
    ;;
  restore)
    restore
    ;;
  p)
    push $2 $3
    ;;
  t)
    tag $2
    ;;
  nocache)
    build --no-cache
    ;;
  auto)
    build
    tag
    ;;
  b)
    build
    ;;
  l)
    list
    ;;
  *)
    echo "$0 [save|restore|p|t|nocache|auto|b|l]"
    exit
    ;;
esac

exit $?
