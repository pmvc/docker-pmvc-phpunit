#!/bin/bash

PREPARE="postgresql-libs"

BUILD_DEPS="$PHPIZE_DEPS musl-dev build-base postgresql-dev"

PHP_EXT="pcntl sockets pdo_pgsql pdo_mysql"

PHP_EXT_ENABLE=""

PECL=""

if [ $(echo "$INSTALL_VERSION >= 8.0" | bc -l) == 1 ] \
  || [ $(echo "$INSTALL_VERSION == 5.6" | bc -l) == 1 ]; then
  PREPARE="$PREPARE freetype libjpeg-turbo libpng"
  BUILD_DEPS="$BUILD_DEPS freetype-dev libjpeg-turbo-dev libpng-dev zlib-dev"
  ENABLE_GD="on"
fi

if [[ $(echo "$INSTALL_VERSION == 8.0" | bc -l) == 1 ]]; then
  # svm librar (libgomp, libstdc++, libgcc)
  PREPARE="$PREPARE libgomp libstdc++ libgcc"

  ##
  # tensor
  # https://github.com/mlocati/docker-php-extension-installer#special-requirements-for-tensor
  # Not available in alpine3.15 docker images
  # ALT_VERSION=fpm-alpine3.14
  ##
  PREPARE="$PREPARE lapack libexecinfo openblas"
  BUILD_DEPS="$BUILD_DEPS lapack-dev libexecinfo-dev openblas-dev"
  PHP_EXT_ENABLE="$PHP_EXT_ENABLE tensor"
  PECL="$PECL tensor"
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

echo "###"
echo "# Will install"
echo "###"
echo ""
echo $PREPARE
echo ""
echo "###"
echo "# Will build package"
echo "###"
echo ""
echo $BUILD_DEPS
echo ""
echo "###"
echo "# Will install PHP EXT"
echo "###"
echo ""
echo $PHP_EXT
echo ""

apk add --virtual .build-deps $BUILD_DEPS && apk add $PREPARE

###
# workaround for php 8.0.15
# https://github.com/docker-library/php/issues/1245#issuecomment-1020475243
###
CFLAGS="$CFLAGS -D_GNU_SOURCE" docker-php-ext-install $PHP_EXT

if [ ! -z "$ENABLE_GD" ]; then
  if [[ $(echo "$INSTALL_VERSION >= 8.0" | bc -l) == 1 ]]; then
    docker-php-ext-configure gd --with-freetype --with-jpeg || exit 1
  else
    docker-php-ext-configure gd --with-freetype-dir=/usr/include --with-jpeg-dir=/usr/include --with-gd || exit 2
  fi
  docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) gd || exit 3
fi

if [ "x$PECL" != "x" ]; then
  echo "###"
  echo "# Will install pecl"
  echo "###"
  echo ""
  echo $PECL
  echo ""
  pecl install $PECL || exit 4
fi

if [ "x$PHP_EXT_ENABLE" != "x" ]; then
  echo "###"
  echo "# Will enable PHP EXT"
  echo "###"
  echo ""
  echo $PHP_EXT_ENABLE
  echo ""
  docker-php-ext-enable $PHP_EXT_ENABLE || exit 5
fi

apk del -f .build-deps && rm -rf /var/cache/apk/* || exit 6

exit 0
