#!/usr/bin/env sh
DIR="$(
  cd "$(dirname "$0")"
  pwd -P
)"

ENV=${DIR}/../.env.build

if [ -z $ALT_VERSION ]; then
  ALT_VERSION=$(awk -F "=" '/^ALT_VERSION/ {print $2}' ${ENV})
fi

echo $ALT_VERSION
