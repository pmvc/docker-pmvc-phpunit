#!/usr/bin/env bash

DIR="$( cd "$(dirname "$0")" ; pwd -P )"

do_build() {
  VER=$1
  SED_REPLACE_VER=$VER
  if [ "x$VER" == "xlatest" ]; then
    SED_REPLACE_VER=8
  fi
  DEST_FOLDER=${DIR}/php-$VER
  mkdir -p ${DEST_FOLDER}
  echo "building --- Version: " $VER "-->";
  DEST_FILE=${DEST_FOLDER}/Dockerfile
  cp Dockerfile ${DEST_FILE}
  sed -i -e "s|\[VERSION\]|$SED_REPLACE_VER|g" ${DEST_FILE}
  if [ -e "${DEST_FILE}-e" ]; then rm ${DEST_FILE}-e; fi;
}

do_build $1 
