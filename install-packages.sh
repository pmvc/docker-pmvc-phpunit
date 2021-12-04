#!/bin/bash

PREPARE="postgresql-libs"

BUILD_DEPS="$PHPIZE_DEPS musl-dev build-base postgresql-dev"

PHP_EXT="pcntl sockets pdo_pgsql pdo_mysql"

PHP_EXT_ENABLE=""

PECL=""

if [[ $(echo "$INSTALL_VERSION == 7.4" | bc -l) == 1 ]]; then
  # svm librar (libgomp, libstdc++, libgcc)
  PREPARE="$PREPARE libgomp libstdc++ libgcc"

  # tensor
  # PREPARE="$PREPARE lapack libexecinfo openblas"
  # BUILD_DEPS="$BUILD_DEPS lapack-dev libexecinfo-dev openblas-dev"
  # PHP_EXT_ENABLE="$PHP_EXT_ENABLE tensor"
  # PECL="$PECL tensor"
fi

# xdbug
if [[ $(echo "$INSTALL_VERSION >= 7.2" | bc -l) == 1 ]]; then
  # git use in php-coveralls/php-coveralls
  PREPARE="$PREPARE git"
  PECL="$PECL xdebug-3.1.1"
  PHP_EXT_ENABLE="$PHP_EXT_ENABLE xdebug"
fi

# nodejs
PREPARE="$PREPARE nodejs"
if [[ $(echo "$INSTALL_VERSION == 7.0" | bc -l) == 1 ]]; then
  PREPARE="$PREPARE yarn"
elif [[ $(echo "$INSTALL_VERSION == 5.5" | bc -l) == 1 ]]; then
  PREPARE="$PREPARE ca-certificates"
else
  PREPARE="$PREPARE npm yarn"
fi

echo "Will install"
echo ""
echo $PREPARE
echo ""
echo "Will build package"
echo ""
echo $BUILD_DEPS
echo ""
echo "Will install PHP EXT"
echo ""
echo $PHP_EXT
echo ""
echo "Will enable PHP EXT"
echo ""
echo $PHP_EXT_ENABLE
echo ""
echo "Will install pecl"
echo ""
echo $PECL
echo ""

apk add --virtual .build-deps $BUILD_DEPS && apk add $PREPARE
docker-php-ext-install $PHP_EXT
if [ ! -z "$PECL" ]; then
  pecl install $PECL
fi
if [ ! -z "$PHP_EXT_ENABLE" ]; then
  docker-php-ext-enable $PHP_EXT_ENABLE
fi
apk del -f .build-deps && rm -rf /var/cache/apk/*
