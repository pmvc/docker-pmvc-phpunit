#!/usr/bin/env sh
DIR="$(
  cd "$(dirname "$0")"
  pwd -P
)"

ENV=${DIR}/../.env.build

if [ -z $VERSION ]; then
  VERSION=$(awk -F "=" '/^VERSION/ {print $2}' ${ENV})
fi

if [ -z $ALT_VERSION ]; then
  ALT_VERSION=$(awk -F "=" '/^ALT_VERSION/ {print $2}' ${ENV})
  # The pinned Alpine tag is only published for versions upstream still
  # rebuilds. PHP 8.1 and older are end of life and stay on fpm-alpine.
  if [ "$(echo "$VERSION" | awk -F. '{print ($1 < 8 || ($1 == 8 && $2 < 2)) ? 1 : 0}')" = "1" ]; then
    ALT_VERSION=fpm-alpine
  fi
fi

echo $ALT_VERSION
