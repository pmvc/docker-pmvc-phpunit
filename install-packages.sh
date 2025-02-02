#!/usr/bin/env sh

###
# Environment ${INSTALL_VERSION} pass from Dockerfile
###

BUILD_DEPS="$PHPIZE_DEPS musl-dev build-base postgresql-dev linux-headers"

INSTALL="postgresql-libs"

# https://github.com/mlocati/docker-php-extension-installer
PHP_EXT="pcntl sockets pdo_pgsql pdo_mysql"

PHP_EXT_ENABLE=""

PECL=""

if [ $(echo "$INSTALL_VERSION >= 8.0" | bc -l) == 1 ] \
  || [ $(echo "$INSTALL_VERSION == 5.6" | bc -l) == 1 ]; then
  BUILD_DEPS="$BUILD_DEPS freetype-dev libjpeg-turbo-dev libpng-dev libwebp-dev zlib-dev libvpx-dev"
  INSTALL="$INSTALL freetype libjpeg-turbo libpng libwebp libvpx"
  ENABLE_GD="on"
fi

###
# tensor
###
if [[ $(echo "$INSTALL_VERSION == 8.2" | bc -l) == 1 ]]; then
  # svm librar (libgomp, libstdc++, libgcc)
  INSTALL="$INSTALL libgomp libstdc++ libgcc"

  ##
  # tensor
  # https://github.com/mlocati/docker-php-extension-installer#special-requirements-for-tensor
  # Not available in alpine3.15 docker images
  # ALT_VERSION=fpm-alpine3.14
  ##
  BUILD_DEPS="$BUILD_DEPS lapack-dev openblas-dev"
  INSTALL="$INSTALL openblas lapack"
  PHP_EXT_ENABLE="$PHP_EXT_ENABLE tensor"
  PHP_EXT="$PHP_EXT mysqli"
  PECL="$PECL tensor"
fi

###
# xdbug
# https://xdebug.org/download
###

if [[ $(echo "$INSTALL_VERSION >= 7.2" | bc -l) == 1 ]]; then
  # git use in php-coveralls/php-coveralls
  INSTALL="$INSTALL git"
  if [[ $(echo "$INSTALL_VERSION >= 8.0" | bc -l) == 1 ]]; then
    PECL="$PECL xdebug-3.4.1"
  else
    PECL="$PECL xdebug-3.1.6"
  fi
  PHP_EXT_ENABLE="$PHP_EXT_ENABLE xdebug"
fi

# nodejs
INSTALL="$INSTALL nodejs"
if [[ $(echo "$INSTALL_VERSION == 7.0" | bc -l) == 1 ]]; then
  INSTALL="$INSTALL yarn"
elif [[ $(echo "$INSTALL_VERSION == 5.5" | bc -l) == 1 ]]; then
  INSTALL="$INSTALL ca-certificates"
else
  INSTALL="$INSTALL npm yarn"
fi

echo "###"
echo "# Will install build tool"
echo "###"
echo ""
echo $BUILD_DEPS
echo ""
echo "###"
echo "# Will install"
echo "###"
echo ""
echo $INSTALL
echo ""

apk add --virtual .build-deps $BUILD_DEPS && apk add $INSTALL || exit 7

#/* put your install code here */#

if test -e /usr/lib/liblapacke.so.3 && ! test -e /usr/lib/liblapacke.so; then
  ln -s /usr/lib/liblapacke.so.3 /usr/lib/liblapacke.so
fi

###
# workaround for php 8.0.15
# https://github.com/docker-library/php/issues/1245#issuecomment-1020475243
###
CFLAGS="$CFLAGS -D_GNU_SOURCE" docker-php-ext-install $PHP_EXT

if [ ! -z "$ENABLE_GD" ]; then
  if [[ $(echo "$INSTALL_VERSION >= 8.0" | bc -l) == 1 ]]; then
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp || exit 6
  else
    docker-php-ext-configure gd --with-freetype-dir=/usr/include --with-jpeg-dir=/usr/include --with-vpx-dir=/usr/include --with-gd || exit 5
  fi
  docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) gd || exit 4
fi

if [ "x$PECL" != "x" ]; then
  echo "###"
  echo "# Will install pecl"
  echo "###"
  echo ""
  echo $PECL
  echo ""
  pecl install $PECL || exit 3
fi

if [ "x$PHP_EXT_ENABLE" != "x" ]; then
  echo "###"
  echo "# Will enable PHP EXT"
  echo "###"
  echo ""
  echo $PHP_EXT_ENABLE
  echo ""
  docker-php-ext-enable $PHP_EXT_ENABLE || exit 2
fi

if [[ $(echo "$INSTALL_VERSION == 5.5" | bc -l) == 1 ]]; then update-ca-certificates; fi

apk del -f .build-deps && rm -rf /var/cache/apk/* || exit 1

exit 0
