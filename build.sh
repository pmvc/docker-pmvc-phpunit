#!/usr/bin/env bash

DIR="$( cd "$(dirname "$0")" ; pwd -P )"

do_build() {
  VER=$1
  echo "building --- Version: " $VER "-->";
  DEST_FILE=${DIR}/php$VER/Dockerfile
  cp Dockerfile ${DEST_FILE}
  sed -i '' -e "s|\[VERSION\]|$VER|g" ${DEST_FILE}
}

do_build 8
do_build 5.6
do_build 7.2 
